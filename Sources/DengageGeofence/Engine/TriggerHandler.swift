import Foundation
import CoreLocation
import Dengage

/// OS region transition handler (doc 21 §6.5).
/// - Trigger type matcher: enter/exit/dwell → eşleşen kampanyalar gate'lenir.
/// - Online: event-signal v2 server'a gönderilir (server push'u orkestre eder).
/// - Offline: cache'lenen `offlinePushContent` ile local notification anında fire (K10) + event kuyruğa.
final class TriggerHandler {

    private let fenceRepository: FenceRepository
    private let deviceStateRepository: DeviceStateRepository
    private let eventQueue: EventQueueRepository
    private let notificationFirer: LocalNotificationFirer
    private let eventFlusher: EventQueueFlusher
    private let offlineQueueMaxSize: () -> Int

    init(fenceRepository: FenceRepository,
         deviceStateRepository: DeviceStateRepository,
         eventQueue: EventQueueRepository,
         notificationFirer: LocalNotificationFirer,
         eventFlusher: EventQueueFlusher,
         offlineQueueMaxSize: @escaping () -> Int) {
        self.fenceRepository = fenceRepository
        self.deviceStateRepository = deviceStateRepository
        self.eventQueue = eventQueue
        self.notificationFirer = notificationFirer
        self.eventFlusher = eventFlusher
        self.offlineQueueMaxSize = offlineQueueMaxSize
    }

    func handle(eventType: GeofenceEventType, requestId: String, location: CLLocation?) {
        guard let ids = EngineFence.parseRequestId(requestId),
              let fence = fenceRepository.findById(ids.geofenceId) else { return }
        guard fence.geofenceId > 0 else {
            Logger.log(message: "TriggerHandler -> skipping invalid fence (geofenceId<=0)")
            return
        }

        let now = Date().timeIntervalSince1970

        // Edge-detection / dedup: OS aynı fiziksel geçiş için birden fazla callback verebilir
        // (didEnterRegion + register sonrası requestState→didDetermineState(.inside), vb.).
        // Sadece gerçek durum değişikliğinde tetikle; aksi halde çift event-signal gider.
        let previous = deviceStateRepository.getState(geofenceId: fence.geofenceId)
        if isDuplicateTransition(eventType: eventType, previous: previous) {
            Logger.log(message: "TriggerHandler -> duplicate \(eventType.rawValue) for fence \(fence.geofenceId), skipping")
            return
        }

        updateDeviceState(fence: fence, eventType: eventType, now: now)

        // Davranış paritesi: enter'da host interceptor'ı tetikle (v1 ile aynı hook)
        if eventType == .enter {
            DispatchQueue.main.async {
                DengageGeofence.geofenceInterceptor?.onGeofenceEnter(
                    latitude: fence.latitude,
                    longitude: fence.longitude,
                    radius: fence.radiusM,
                    clusterId: fence.clusterId,
                    clusterName: nil,
                    geofenceItemId: fence.geofenceId,
                    geofenceItemName: fence.title
                )
            }
        }

        let matchingTrigger = trigger(for: eventType)
        let matchingCampaigns = fence.campaigns.filter { $0.triggerType == matchingTrigger }
        guard !matchingCampaigns.isEmpty else {
            Logger.log(message: "TriggerHandler -> no \(matchingTrigger.rawValue) campaign for fence \(fence.geofenceId)")
            return
        }

        let online = Reachability.isOnline()
        let lat = location?.coordinate.latitude ?? fence.latitude
        let lon = location?.coordinate.longitude ?? fence.longitude

        for campaign in matchingCampaigns {
            dispatch(fence: fence, campaign: campaign, eventType: eventType, lat: lat, lon: lon, now: now, online: online)
        }

        if online {
            eventFlusher.flush(batchSize: offlineQueueMaxSize())
        }
    }

    private func dispatch(fence: EngineFence,
                          campaign: SyncCampaign,
                          eventType: GeofenceEventType,
                          lat: Double, lon: Double,
                          now: TimeInterval,
                          online: Bool) {
        let event = QueuedEvent(
            idempotencyKey: UUID().uuidString,
            geofenceId: fence.geofenceId,
            clusterId: fence.clusterId,
            campaignId: campaign.campaignId,
            eventType: eventType,
            latitude: lat,
            longitude: lon,
            occurredAtMillis: now * 1000.0,
            createdAtMillis: now * 1000.0
        )

        if online {
            eventFlusher.sendOnline(event) { [weak self] success in
                guard let self = self, !success else { return }
                Logger.log(message: "TriggerHandler -> online send failed, queueing \(event.idempotencyKey)")
                self.eventQueue.enqueue(event, maxSize: self.offlineQueueMaxSize())
            }
        } else {
            // Offline: local notification anında (K10) + event kuyruğa
            if let content = campaign.offlinePushContent {
                notificationFirer.fire(content: content, geofenceId: fence.geofenceId, campaignId: campaign.campaignId)
            }
            eventQueue.enqueue(event, maxSize: offlineQueueMaxSize())
            Logger.log(message: "TriggerHandler -> offline trigger queued \(event.idempotencyKey)")
        }
    }

    private func updateDeviceState(fence: EngineFence, eventType: GeofenceEventType, now: TimeInterval) {
        switch eventType {
        case .enter:
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .inside,
                enteredAt: now, lastSeenAt: now, exitedAt: nil))
        case .dwell:
            let existing = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .inside,
                enteredAt: existing?.enteredAt ?? now, lastSeenAt: now, exitedAt: nil))
        case .exit:
            let existing = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .outside,
                enteredAt: existing?.enteredAt, lastSeenAt: now, exitedAt: now))
        }
    }

    /// Aynı geçiş için tekrarlanan OS callback'lerini ele: enter yalnızca cihaz `inside` değilken,
    /// exit yalnızca `inside`'ken gerçek geçiştir. Dwell explicit zamanlandığı için hariç.
    private func isDuplicateTransition(eventType: GeofenceEventType, previous: DeviceFenceState?) -> Bool {
        switch eventType {
        case .enter: return previous?.state == .inside
        case .exit:  return previous == nil || previous?.state == .outside
        case .dwell: return false
        }
    }

    private func trigger(for eventType: GeofenceEventType) -> GeofenceTriggerType {
        switch eventType {
        case .enter: return .enter
        case .exit: return .exit
        case .dwell: return .dwell
        }
    }

    /// Bir fence'in `dwell` kampanyası var mı (orchestrator dwell zamanlaması için)?
    func dwellMinutes(forFenceId geofenceId: Int) -> Int? {
        guard let fence = fenceRepository.findById(geofenceId) else { return nil }
        return fence.campaigns
            .filter { $0.triggerType == .dwell }
            .compactMap { $0.dwellMinutes }
            .max()
    }

    func isInside(geofenceId: Int) -> Bool {
        deviceStateRepository.getState(geofenceId: geofenceId)?.state == .inside
    }
}

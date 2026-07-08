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

    /// [completion] async event-signal gönderimleri (+ flush) bittiğinde çağrılır; orchestrator
    /// bunu background task assertion'ının `end()`'ine bağlar ki iOS uygulamayı POST bitmeden
    /// suspend edip push'u geciktirmesin.
    func handle(eventType: GeofenceEventType, requestId: String, location: CLLocation?, completion: @escaping () -> Void = {}) {
        guard let ids = EngineFence.parseRequestId(requestId),
              let fence = fenceRepository.findById(ids.geofenceId) else { completion(); return }
        guard fence.geofenceId > 0 else {
            Logger.log(message: "TriggerHandler -> skipping invalid fence (geofenceId<=0)")
            completion(); return
        }

        let now = Date().timeIntervalSince1970

        // Edge-detection / dedup: OS aynı fiziksel geçiş için birden fazla callback verebilir
        // (didEnterRegion + register sonrası requestState→didDetermineState(.inside), vb.).
        // Sadece gerçek durum değişikliğinde tetikle; aksi halde çift event-signal gider.
        let previous = deviceStateRepository.getState(geofenceId: fence.geofenceId)
        if isDuplicateTransition(eventType: eventType, previous: previous) {
            Logger.log(message: "TriggerHandler -> duplicate \(eventType.rawValue) for fence \(fence.geofenceId), skipping")
            completion(); return
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
            completion(); return
        }

        let online = Reachability.isOnline()
        let lat = location?.coordinate.latitude ?? fence.latitude
        let lon = location?.coordinate.longitude ?? fence.longitude

        // Async gönderimleri grupla; hepsi (+ flush) bitince completion → background task end.
        let group = DispatchGroup()
        for campaign in matchingCampaigns {
            group.enter()
            dispatch(fence: fence, campaign: campaign, eventType: eventType, lat: lat, lon: lon, now: now, online: online) {
                group.leave()
            }
        }

        if online {
            group.enter()
            eventFlusher.flush(batchSize: offlineQueueMaxSize()) { group.leave() }
        }

        group.notify(queue: DispatchQueue.global(qos: .utility)) { completion() }
    }

    private func dispatch(fence: EngineFence,
                          campaign: SyncCampaign,
                          eventType: GeofenceEventType,
                          lat: Double, lon: Double,
                          now: TimeInterval,
                          online: Bool,
                          completion: @escaping () -> Void) {
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
                defer { completion() }
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
            completion()
        }
    }

    private func updateDeviceState(fence: EngineFence, eventType: GeofenceEventType, now: TimeInterval) {
        switch eventType {
        case .enter:
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .inside,
                enteredAt: now, lastSeenAt: now, exitedAt: nil))
        case .dwell:
            // Dwell atıldı → `.dwellPending` = "inside ve bu ziyarette dwell zaten fire edildi".
            // Sonraki dwell callback'leri (biriken timer / OS tekrarı) böylece dedup edilir.
            let existing = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .dwellPending,
                enteredAt: existing?.enteredAt ?? now, lastSeenAt: now, exitedAt: nil))
        case .exit:
            let existing = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .outside,
                enteredAt: existing?.enteredAt, lastSeenAt: now, exitedAt: now))
        }
    }

    /// Aynı geçiş için tekrarlanan OS callback'lerini ele; her tetik tipi ziyaret başına en fazla bir kez fire eder.
    /// State makinesi: enter→inside, dwell→dwellPending (dwell atıldı), exit→outside.
    /// - enter: cihaz zaten fence içindeyse (inside veya dwellPending) yinelenmedir.
    /// - dwell: yalnızca taze `inside` iken bir kez; `dwellPending` (zaten atıldı) veya outside/nil (bayat timer) → yinelenmedir.
    /// - exit: cihaz zaten dışarıdaysa (outside/nil) yinelenmedir.
    private func isDuplicateTransition(eventType: GeofenceEventType, previous: DeviceFenceState?) -> Bool {
        let state = previous?.state
        switch eventType {
        case .enter: return state == .inside || state == .dwellPending
        case .exit:  return previous == nil || state == .outside
        case .dwell: return state != .inside
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

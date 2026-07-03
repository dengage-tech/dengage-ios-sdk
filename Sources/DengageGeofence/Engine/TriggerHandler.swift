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
              let fence = fenceRepository.findById(ids.fenceId) else { return }

        let now = Date().timeIntervalSince1970
        updateDeviceState(fence: fence, eventType: eventType, now: now)

        let matchingTrigger = trigger(for: eventType)
        let matchingCampaigns = fence.campaigns.filter { $0.triggerType == matchingTrigger }
        guard !matchingCampaigns.isEmpty else {
            Logger.log(message: "TriggerHandler -> no \(matchingTrigger.rawValue) campaign for fence \(fence.fenceId)")
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
            geofenceId: fence.fenceId,
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
                notificationFirer.fire(content: content, fenceId: fence.fenceId, campaignId: campaign.campaignId)
            }
            eventQueue.enqueue(event, maxSize: offlineQueueMaxSize())
            Logger.log(message: "TriggerHandler -> offline trigger queued \(event.idempotencyKey)")
        }
    }

    private func updateDeviceState(fence: EngineFence, eventType: GeofenceEventType, now: TimeInterval) {
        switch eventType {
        case .enter:
            deviceStateRepository.setState(DeviceFenceState(
                fenceId: fence.fenceId, clusterId: fence.clusterId, state: .inside,
                enteredAt: now, lastSeenAt: now, exitedAt: nil))
        case .dwell:
            let existing = deviceStateRepository.getState(fenceId: fence.fenceId)
            deviceStateRepository.setState(DeviceFenceState(
                fenceId: fence.fenceId, clusterId: fence.clusterId, state: .inside,
                enteredAt: existing?.enteredAt ?? now, lastSeenAt: now, exitedAt: nil))
        case .exit:
            let existing = deviceStateRepository.getState(fenceId: fence.fenceId)
            deviceStateRepository.setState(DeviceFenceState(
                fenceId: fence.fenceId, clusterId: fence.clusterId, state: .outside,
                enteredAt: existing?.enteredAt, lastSeenAt: now, exitedAt: now))
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
    func dwellMinutes(forFenceId fenceId: Int) -> Int? {
        guard let fence = fenceRepository.findById(fenceId) else { return nil }
        return fence.campaigns
            .filter { $0.triggerType == .dwell }
            .compactMap { $0.dwellMinutes }
            .max()
    }

    func isInside(fenceId: Int) -> Bool {
        deviceStateRepository.getState(fenceId: fenceId)?.state == .inside
    }
}

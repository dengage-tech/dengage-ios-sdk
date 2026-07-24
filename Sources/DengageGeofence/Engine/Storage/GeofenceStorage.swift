import Foundation

/// Engine storage erişim noktası. Default impl JSON/UserDefaults (doc 21 §6.2 alt impl, K5).
final class GeofenceStorage {
    let fenceRepository: FenceRepository
    let deviceStateRepository: DeviceStateRepository
    let eventQueueRepository: EventQueueRepository
    let syncMetadataRepository: SyncMetadataRepository
    let triggerHistoryRepository: TriggerHistoryRepository

    init() {
        let store = EngineDefaults()
        fenceRepository = DefaultFenceRepository(store: store)
        deviceStateRepository = DefaultDeviceStateRepository(store: store)
        eventQueueRepository = DefaultEventQueueRepository(store: store)
        syncMetadataRepository = DefaultSyncMetadataRepository(store: store)
        triggerHistoryRepository = DefaultTriggerHistoryRepository(store: store)
    }

    func clearAll() {
        fenceRepository.clear()
        deviceStateRepository.clear()
        eventQueueRepository.clear()
        triggerHistoryRepository.clear()
    }
}

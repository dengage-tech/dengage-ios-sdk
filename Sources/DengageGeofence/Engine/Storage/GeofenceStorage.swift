import Foundation

/// Engine storage erişim noktası. Default impl JSON/UserDefaults (doc 21 §6.2 alt impl, K5).
final class GeofenceStorage {
    let fenceRepository: FenceRepository
    let deviceStateRepository: DeviceStateRepository
    let eventQueueRepository: EventQueueRepository
    let syncMetadataRepository: SyncMetadataRepository

    init() {
        let store = EngineDefaults()
        fenceRepository = DefaultFenceRepository(store: store)
        deviceStateRepository = DefaultDeviceStateRepository(store: store)
        eventQueueRepository = DefaultEventQueueRepository(store: store)
        syncMetadataRepository = DefaultSyncMetadataRepository(store: store)
    }

    func clearAll() {
        fenceRepository.clear()
        deviceStateRepository.clear()
        eventQueueRepository.clear()
    }
}

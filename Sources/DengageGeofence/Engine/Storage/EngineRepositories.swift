import Foundation

/// Fence persist + spatial query (doc 21 §6.2). iOS default impl JSON/UserDefaults
/// (K5 dokümante edilmiş alternatif; SPM paketi harici bağımlılık içermediği için SQLite/R*Tree yerine).
protocol FenceRepository {
    func save(_ fences: [EngineFence])
    func loadAll() -> [EngineFence]
    /// Cihaz konumuna en yakın `limit` fence (haversine sort). `activeOnly` ise sadece activeNow.
    func nearest(lat: Double, lon: Double, limit: Int, activeOnly: Bool) -> [EngineFence]
    func findById(_ fenceId: Int) -> EngineFence?
    func clear()
}

/// Cihaz başına fence dwell/state tracking (doc 21 §6.2).
protocol DeviceStateRepository {
    func setState(_ state: DeviceFenceState)
    func getState(fenceId: Int) -> DeviceFenceState?
    func clear()
}

/// Offline event kuyruğu (doc 21 §6.2). Online olunca batch flush edilir.
protocol EventQueueRepository {
    func enqueue(_ event: QueuedEvent, maxSize: Int)
    func dequeueBatch(maxSize: Int) -> [QueuedEvent]
    func ack(idempotencyKeys: [String])
    func size() -> Int
    func clear()
}

/// Son ETag / sync zamanı / silent-push zamanı metadata'sı (doc 21 §6.2).
protocol SyncMetadataRepository: AnyObject {
    var lastETag: String? { get set }
    var lastSyncedAt: Double? { get set }
    var lastHeartbeatAt: Double? { get set }
    /// Silent push (sourceType=geofence) ile yapılan son resync zamanı (epoch seconds).
    var lastSilentPushAt: Double? { get set }
}

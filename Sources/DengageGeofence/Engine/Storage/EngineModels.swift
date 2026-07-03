import Foundation
import Dengage

let kEngineRequestIdPrefix = "dengage_v2"

/// Engine-içi flattened fence modeli. Sync response'taki `SyncFence` -> `EngineFence` map edilir,
/// JSON store'a persist edilir. (Android tarafındaki `Fence` ile eşdeğer.)
struct EngineFence: Codable {
    let fenceId: Int
    let clusterId: Int
    let latitude: Double
    let longitude: Double
    let radiusM: Double
    let title: String?
    let activeNow: Bool
    /// epoch millis (Codable kolaylığı için Double)
    let nextStateChangeAtMillis: Double?
    let nextStateChangeTo: String?
    let campaigns: [SyncCampaign]

    var requestId: String { EngineFence.requestId(clusterId: clusterId, fenceId: fenceId) }

    static func from(_ sync: SyncFence) -> EngineFence {
        let nextMillis = GeofenceIso.date(from: sync.nextStateChangeAt)?.timeIntervalSince1970
        return EngineFence(
            fenceId: sync.fenceId,
            clusterId: sync.clusterId,
            latitude: sync.latitude,
            longitude: sync.longitude,
            radiusM: sync.radiusM,
            title: sync.title,
            activeNow: sync.activeNow,
            nextStateChangeAtMillis: nextMillis.map { $0 * 1000.0 },
            nextStateChangeTo: sync.nextStateChangeTo,
            campaigns: sync.campaigns
        )
    }

    static func requestId(clusterId: Int, fenceId: Int) -> String {
        "\(kEngineRequestIdPrefix)_\(clusterId)_\(fenceId)"
    }

    /// requestId'den (clusterId, fenceId) çıkarır; geçersizse nil.
    static func parseRequestId(_ requestId: String?) -> (clusterId: Int, fenceId: Int)? {
        guard let requestId = requestId, requestId.hasPrefix(kEngineRequestIdPrefix) else { return nil }
        let parts = requestId.split(separator: "_")
        guard parts.count >= 3,
              let fenceId = Int(parts[parts.count - 1]),
              let clusterId = Int(parts[parts.count - 2]) else { return nil }
        return (clusterId, fenceId)
    }
}

/// Cihazın bir fence'e göre durumu (doc 21 §1.2 device_geofence_state.state).
enum FenceState: String, Codable {
    case inside
    case outside
    case dwellPending = "dwell_pending"
}

/// Cihaz başına fence state kaydı.
struct DeviceFenceState: Codable {
    let fenceId: Int
    let clusterId: Int
    var state: FenceState
    var enteredAt: Double?
    var lastSeenAt: Double?
    var exitedAt: Double?
}

/// Offline durumda kuyruklanan, online olunca `POST /event-signal` v2 ile flush edilen trigger.
struct QueuedEvent: Codable {
    let idempotencyKey: String
    let geofenceId: Int
    let clusterId: Int
    let campaignId: Int?
    let eventType: GeofenceEventType
    let latitude: Double
    let longitude: Double
    let occurredAtMillis: Double
    let createdAtMillis: Double
}

import Foundation
import Dengage

let kEngineRequestIdPrefix = "dengage_v2"

/// Wake-up cap pause penceresi boyunca kayıtlı tutulan yer-değiştirme dedektörü region'ı.
/// Kampanya fence'i DEĞİLDİR: SLC kapalıyken uygulamayı uyandıracak, process ölümünden sağ çıkan
/// tek kaynaktır (region monitoring, SLC'den bağımsız bir OS alt sistemidir).
let kWakeupBubbleIdentifier = "dengage_v2_wakeup_bubble"

/// Bubble yarıçapı. Küçük olursa pause boyunca sık uyanılır (cap'in amacı kaçar), büyük olursa
/// toparlanma yavaşlar. "Kullanıcı kayda değer biçimde yer değiştirdi" eşiği olarak seçildi.
let kWakeupBubbleRadiusMeters: Double = 3000

/// Engine-içi flattened fence modeli. Sync response'taki `SyncFence` -> `EngineFence` map edilir,
/// JSON store'a persist edilir. (Android tarafındaki `Fence` ile eşdeğer.)
struct EngineFence: Codable {
    let geofenceId: Int
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

    var requestId: String { EngineFence.requestId(clusterId: clusterId, geofenceId: geofenceId) }

    static func from(_ sync: SyncFence) -> EngineFence {
        let nextMillis = GeofenceIso.date(from: sync.nextStateChangeAt)?.timeIntervalSince1970
        return EngineFence(
            geofenceId: sync.geofenceId,
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

    static func requestId(clusterId: Int, geofenceId: Int) -> String {
        "\(kEngineRequestIdPrefix)_\(clusterId)_\(geofenceId)"
    }

    /// requestId'den (clusterId, geofenceId) çıkarır; geçersizse nil.
    static func parseRequestId(_ requestId: String?) -> (clusterId: Int, geofenceId: Int)? {
        guard let requestId = requestId, requestId.hasPrefix(kEngineRequestIdPrefix) else { return nil }
        let parts = requestId.split(separator: "_")
        guard parts.count >= 3,
              let geofenceId = Int(parts[parts.count - 1]),
              let clusterId = Int(parts[parts.count - 2]) else { return nil }
        return (clusterId, geofenceId)
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
    let geofenceId: Int
    let clusterId: Int
    var state: FenceState
    var enteredAt: Double?
    var lastSeenAt: Double?
    var exitedAt: Double?
}

/// Tetiklenen bir transition'ın geçmiş kaydı (teşhis/QA — `TriggerHistoryRepository`).
/// Dedup'tan geçmiş, yani *gerçekten* tetiklenmiş geçişleri temsil eder.
struct TriggerHistoryEntry: Codable {
    let geofenceId: Int
    let clusterId: Int
    let title: String?
    let eventType: GeofenceEventType
    /// epoch millis
    let occurredAtMillis: Double
    /// Geçiş anındaki yatay konum doğruluğu (metre); yoksa nil. Codable optional → eski kayıtlarda nil.
    let accuracyM: Double?
    /// Bu geçişle eşleşen kampanyalar; boşsa geçiş oldu ama kampanya eşleşmedi.
    let campaignIds: [Int]
    /// true → state-only reconcile (silent/sync-only reeval): state güncellendi ama kampanya atılmadı.
    /// Codable optional → eski kayıtlarda nil (false gibi ele alınır).
    let stateOnly: Bool?
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
    /// Yatay konum doğruluğu (metre); yoksa nil. Codable optional → eski kayıtlarda eksik key nil olur.
    let accuracyM: Double?
    let occurredAtMillis: Double
    let createdAtMillis: Double

    /// geofenceId <= 0 (ör. eski alan uyumsuzluğundan kalan bayat event'ler) geçersiz sayılır.
    var isValid: Bool { geofenceId > 0 }
}

import Foundation
import CoreLocation
import Dengage

/// OS'ta hâlen izlenen bir fence'in teşhis görünümü.
public struct MonitoredGeofenceInfo {
    public let geofenceId: Int
    public let clusterId: Int
    public let title: String?
    public let latitude: Double
    public let longitude: Double
    public let radiusM: Double
    /// `inside` / `outside` / `dwell_pending` / `unknown`
    public let state: String
}

/// Tetiklenmiş bir geçişin teşhis görünümü.
public struct TriggeredEventInfo {
    public let geofenceId: Int
    public let clusterId: Int
    public let title: String?
    /// `enter` / `exit` / `dwell`
    public let eventType: String
    public let occurredAt: Date
    /// Geçiş anındaki yatay konum doğruluğu (metre); yoksa nil.
    public let accuracyM: Double?
    /// Bu geçişle eşleşen kampanyalar; boşsa geçiş oldu ama kampanya eşleşmedi.
    public let campaignIds: [Int]
    /// true → state-only reconcile (silent/sync-only reeval): state güncellendi ama kampanya atılmadı.
    public let stateOnly: Bool
}

/// Geofence Engine v2 public API (doc 21 §6.4).
///
/// Mevcut `DengageGeofence` (v1) ile coexist eder; geçiş server feature-flag / `geofenceEnabled`
/// ile yönetilir. Faz 1'de organik sync kullanılır (push delivery + app lifecycle + movement) ve
/// `sourceType == geofence` silent push ile ad-hoc resync yapılır.
@objc(DengageGeofenceEngine)
public class DengageGeofenceEngine: NSObject, DengageGeofenceSilentPushBridging {

    @objc public static let shared = DengageGeofenceEngine()

    private let engine = GeofenceEngine()

    private override init() { super.init() }

    @objc public func start() {
        Logger.log(message: "DengageGeofenceEngine -> start")
        ensureStarted()
        engine.start()
    }

    @objc public func stop() {
        Logger.log(message: "DengageGeofenceEngine -> stop")
        engine.stop()
    }

    /// Server'dan sync, hareket bazlı reeval, OS register, event flush (force).
    @objc public func forceResync() {
        engine.forceResync()
    }

    /// Push delivery hook (organik sync, contract §5). `dgs_sync_check` opsiyonel opt-out hint'idir.
    /// - Returns: sync check tetiklendiyse true.
    @objc @discardableResult
    public func handlePushDelivered(_ userInfo: [AnyHashable: Any]) -> Bool {
        ensureStarted()
        return engine.handlePushDelivered(userInfo)
    }

    /// App foreground olduğunda organik sync + wake-up cap resume fırsatı.
    @objc public func onAppForeground() {
        engine.onAppForeground()
    }

    /// Konum iznini ister (notDetermined → WhenInUse, WhenInUse → Always).
    @objc public func requestLocationPermissions() {
        engine.requestLocationPermissions()
    }

    /// Silent push hook. `sourceType == geofence` ise fence'leri sunucudan yeniden çeker (force resync)
    /// ve son silent-push senkronizasyon zamanını kaydeder.
    @objc @discardableResult
    public func handleSilentPush(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard GeofenceSilentPushDispatcher.isGeofenceSilentPush(userInfo) else { return false }
        ensureStarted()
        Logger.log(message: "DengageGeofenceEngine -> silent push (sourceType=geofence) received")
        engine.onSilentPush()
        return true
    }

    /// Silent push ile yapılan son resync zamanı veya henüz yoksa nil.
    @objc public func lastSilentPushSyncDate() -> Date? {
        engine.lastSilentPushAt()
    }

    // MARK: - Diagnostics

    /// OS'ta o an aktif olarak izlenen fence'ler. Depodaki listenin tamamı değil — top-N seçimi
    /// ve OS'un region limiti sonrası gerçekten register edilmiş olanlar.
    public func monitoredGeofences() -> [MonitoredGeofenceInfo] {
        engine.monitoredGeofences()
    }

    /// Son tetiklenen geçişler (en yeniden eskiye). Kampanya eşleşmeyen geçişler de listelenir.
    public func recentTriggeredEvents(limit: Int = 50) -> [TriggeredEventInfo] {
        engine.recentTriggeredEvents(limit: limit)
    }

    private func ensureStarted() {
        if !Dengage.startCalled {
            let integrationKey = DengageLocalStorage.shared.value(for: .integrationKeySubscription) as? String ?? ""
            Dengage.start(apiKey: integrationKey, launchOptions: nil)
        }
    }

    // MARK: - DengageGeofenceSilentPushBridging (core'dan NSClassFromString ile çağrılır)

    @objc public static func dengage_handleSilentPush(_ userInfo: [AnyHashable: Any]) {
        shared.handleSilentPush(userInfo)
    }
}

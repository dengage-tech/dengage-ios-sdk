import Foundation
import CoreLocation
import Dengage

/// OS region register/unregister (doc 21 §6.5, K9).
/// iOS hard limit 20 region/app (K4). Register sonrası orchestrator `requestState(for:)` çağırır —
/// cihaz fence içindeyse anında enter (havalimanı senaryosu).
final class OsGeofenceRegistrar {

    private let manager: CLLocationManager

    init(manager: CLLocationManager) {
        self.manager = manager
    }

    /// iOS uygulama başına 20 region izleyebilir (K4). Wake-up bubble kayıtlıysa bir slot yer.
    private let osRegionLimit = 20

    /// Register modu (doc 23 İş 1):
    /// - `diff`: `monitoredRegions` gerçeğin kaynağı — hedefte olmayan region'lar bırakılır, aynı
    ///   id + aynı geometriyle izlenen region'a DOKUNULMAZ (SDK dwell timer'ı ve `requestState`
    ///   churn'ü tetiklenmez), yeni/değişenler `startMonitoring` ile eklenir (aynı id replace olur).
    /// - `full`: remove-all + tam re-register (eski davranış). Tamir kanalı: forceResync/silent push.
    enum RegisterMode { case diff, full }

    func register(_ fences: [EngineFence], mode: RegisterMode = .diff) {
        // Bubble'a dokunma: pause penceresindeki tek uyandırma kaynağıdır.
        if mode == .full { removeAllFences() }
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            Logger.log(message: "OsGeofenceRegistrar -> region monitoring unavailable")
            return
        }
        let available = osRegionLimit - (isBubbleRegistered ? 1 : 0)
        let target = Array(fences.prefix(available))
        let targetIds = Set(target.map { $0.requestId })

        // Full modda removeAllFences sonrası boş kalır → tüm hedef eklenir (eski davranışla aynı).
        let current = manager.monitoredRegions.filter {
            $0.identifier.hasPrefix(kEngineRequestIdPrefix) && $0.identifier != kWakeupBubbleIdentifier
        }
        for region in current where !targetIds.contains(region.identifier) {
            manager.stopMonitoring(for: region)
        }
        let currentById = Dictionary(
            current.compactMap { $0 as? CLCircularRegion }.map { ($0.identifier, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var added = 0
        for fence in target {
            let radius = min(fence.radiusM, manager.maximumRegionMonitoringDistance)
            // Aynı id + aynı geometri zaten izleniyorsa dokunma: startMonitoring replace edip
            // didStartMonitoringFor→requestState→didDetermineState(.inside) churn'ü üretmesin.
            if let existing = currentById[fence.requestId],
               abs(existing.center.latitude - fence.latitude) < 1e-6,
               abs(existing.center.longitude - fence.longitude) < 1e-6,
               abs(existing.radius - radius) < 0.5 {
                continue
            }
            let center = CLLocationCoordinate2D(latitude: fence.latitude, longitude: fence.longitude)
            let region = CLCircularRegion(center: center, radius: radius, identifier: fence.requestId)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
            added += 1
        }
        Logger.log(message: "OsGeofenceRegistrar -> registered +\(added) =\(target.count - added) regions (mode: \(mode))")
    }

    /// OS'ta hâlen izlenen kampanya region'larının requestId'leri (wake-up bubble hariç).
    var monitoredFenceRequestIds: [String] {
        manager.monitoredRegions
            .map { $0.identifier }
            .filter { $0.hasPrefix(kEngineRequestIdPrefix) && $0 != kWakeupBubbleIdentifier }
    }

    /// Kampanya region'larını kaldırır, wake-up bubble'ı korur.
    func removeAllFences() {
        for region in manager.monitoredRegions
        where isDengageRegion(region.identifier) && region.identifier != kWakeupBubbleIdentifier {
            manager.stopMonitoring(for: region)
        }
    }

    /// Bubble dahil tüm Dengage region'larını kaldırır (engine `stop()`).
    func removeAll() {
        // v2 (dengage_v2_*) + eski modülle (v1) oluşturulmuş region'ları da temizler
        // (dengage_geofence_*, dengage_bubble_*). Hepsi `kIdentifierPrefix` = "dengage_" ile başlar.
        // Aksi halde v1 leftover region'ları iOS 20-region limitini yer ve boş uyandırma üretir.
        for region in manager.monitoredRegions where isDengageRegion(region.identifier) {
            manager.stopMonitoring(for: region)
        }
    }

    // MARK: - Wake-up bubble

    var isBubbleRegistered: Bool {
        manager.monitoredRegions.contains { $0.identifier == kWakeupBubbleIdentifier }
    }

    /// Pause penceresi için yer-değiştirme dedektörü. Yalnızca çıkışta uyandırır (`notifyOnEntry = false`).
    func registerBubble(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        removeBubble()
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        let clamped = min(radius, manager.maximumRegionMonitoringDistance)
        let region = CLCircularRegion(center: center, radius: clamped, identifier: kWakeupBubbleIdentifier)
        region.notifyOnEntry = false
        region.notifyOnExit = true
        manager.startMonitoring(for: region)
        Logger.log(message: "OsGeofenceRegistrar -> wake-up bubble registered (r=\(Int(clamped))m)")
    }

    func removeBubble() {
        for region in manager.monitoredRegions where region.identifier == kWakeupBubbleIdentifier {
            manager.stopMonitoring(for: region)
        }
    }

    private func isDengageRegion(_ identifier: String) -> Bool {
        identifier.hasPrefix(kEngineRequestIdPrefix) ||          // v2: dengage_v2_* (bubble dahil)
            identifier.hasPrefix(kSyncGeofenceIdentifierPrefix) || // v1 synced: dengage_geofence_*
            identifier.hasPrefix(kBubbleGeofenceIdentifierPrefix)  // v1 bubble: dengage_bubble_*
    }
}

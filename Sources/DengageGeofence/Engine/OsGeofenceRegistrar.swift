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

    func register(_ fences: [EngineFence]) {
        // Bubble'a dokunma: pause penceresindeki tek uyandırma kaynağıdır.
        removeAllFences()
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            Logger.log(message: "OsGeofenceRegistrar -> region monitoring unavailable")
            return
        }
        let available = osRegionLimit - (isBubbleRegistered ? 1 : 0)
        for fence in fences.prefix(available) {
            let center = CLLocationCoordinate2D(latitude: fence.latitude, longitude: fence.longitude)
            let radius = min(fence.radiusM, manager.maximumRegionMonitoringDistance)
            let region = CLCircularRegion(center: center, radius: radius, identifier: fence.requestId)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
        Logger.log(message: "OsGeofenceRegistrar -> registered \(min(fences.count, available)) regions")
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

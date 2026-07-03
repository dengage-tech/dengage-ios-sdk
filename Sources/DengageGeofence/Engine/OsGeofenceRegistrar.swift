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

    func register(_ fences: [EngineFence]) {
        removeAll()
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            Logger.log(message: "OsGeofenceRegistrar -> region monitoring unavailable")
            return
        }
        // iOS 20 region cap
        for fence in fences.prefix(20) {
            let center = CLLocationCoordinate2D(latitude: fence.latitude, longitude: fence.longitude)
            let radius = min(fence.radiusM, manager.maximumRegionMonitoringDistance)
            let region = CLCircularRegion(center: center, radius: radius, identifier: fence.requestId)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
        Logger.log(message: "OsGeofenceRegistrar -> registered \(min(fences.count, 20)) regions")
    }

    func removeAll() {
        // v2 (dengage_v2_*) + eski modülle (v1) oluşturulmuş region'ları da temizler
        // (dengage_geofence_*, dengage_bubble_*). Hepsi `kIdentifierPrefix` = "dengage_" ile başlar.
        // Aksi halde v1 leftover region'ları iOS 20-region limitini yer ve boş uyandırma üretir.
        for region in manager.monitoredRegions where isDengageRegion(region.identifier) {
            manager.stopMonitoring(for: region)
        }
    }

    private func isDengageRegion(_ identifier: String) -> Bool {
        identifier.hasPrefix(kEngineRequestIdPrefix) ||          // v2: dengage_v2_*
            identifier.hasPrefix(kSyncGeofenceIdentifierPrefix) || // v1 synced: dengage_geofence_*
            identifier.hasPrefix(kBubbleGeofenceIdentifierPrefix)  // v1 bubble: dengage_bubble_*
    }
}

import Foundation
import CoreLocation
import Dengage

/// Hareket dinleyici (doc 21 §6.5). iOS'ta Significant Location Change (SLC) — cell+WiFi tabanlı,
/// uçak modu sonrası ilk fix mobil veri gerektirmez; düşük pil. Displacement/adaptif eşik
/// orchestrator'da `didUpdateLocations` üzerinden uygulanır.
final class MovementListener {

    private let manager: CLLocationManager
    private(set) var isActive = false

    init(manager: CLLocationManager) {
        self.manager = manager
    }

    func start() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {
            Logger.log(message: "MovementListener -> SLC unavailable")
            return
        }
        manager.startMonitoringSignificantLocationChanges()
        isActive = true
        Logger.log(message: "MovementListener -> started (SLC)")
    }

    func stop() {
        manager.stopMonitoringSignificantLocationChanges()
        isActive = false
        Logger.log(message: "MovementListener -> stopped (SLC)")
    }
}

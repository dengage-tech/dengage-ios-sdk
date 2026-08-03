import Foundation
import CoreLocation

/// Cihaz konumuna göre OS'a register edilecek top-N fence seçimi (doc 21 §6.5).
/// `activeNow == true` olanlar + 1 saat içinde aktif olacaklar (pre-warm) dahil; en yakın N tanesi.
final class TopNSelector {

    private let preWarmWindow: TimeInterval = 60 * 60

    func select(fences: [EngineFence],
                lat: Double,
                lon: Double,
                topN: Int,
                now: TimeInterval = Date().timeIntervalSince1970) -> [EngineFence] {
        let origin = CLLocation(latitude: lat, longitude: lon)
        return fences
            .filter { isActiveOrPreWarm($0, now: now) }
            .sorted {
                origin.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude)) <
                origin.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
            }
            .prefix(topN)
            .map { $0 }
    }

    private func isActiveOrPreWarm(_ fence: EngineFence, now: TimeInterval) -> Bool {
        if fence.activeNow { return true }
        guard let nextMillis = fence.nextStateChangeAtMillis else { return false }
        let nextSeconds = nextMillis / 1000.0
        let becomesActive = fence.nextStateChangeTo == nil || fence.nextStateChangeTo == "active"
        return becomesActive && nextSeconds >= now && nextSeconds <= (now + preWarmWindow)
    }
}

import Foundation
import CoreLocation
import Dengage

/// Synthetic transitions — local containment check on every wake (doc 22 §2.1).
///
/// Instead of waiting for the OS geofence callback, the device's current location is compared
/// against the stored fences, and a transition is produced wherever the state table disagrees.
/// What this buys us:
/// - **Missed EXIT repair:** if the OS never delivers an exit, the state stays `inside` forever and
///   `TriggerHandler`'s dedup swallows every subsequent enter. Only a comparison against the real
///   location can detect this.
/// - **Events the OS never produces:** with a small radius at high speed the OS may not sample
///   inside the fence at all; we still catch it if the location is inside at wake time.
/// - **Beyond the 20-region limit:** iterating `loadAll()` also covers fences that could not be
///   registered with the OS.
///
/// Produced transitions go through the normal `TriggerHandler.handle` path: `occurredAt = now`
/// (genuinely fresh) and the existing `source` semantics are preserved (online, or replay when
/// offline). If one races an OS callback, `isDuplicateTransition` swallows the loser.
final class ContainmentReconciler {

    /// Exit hysteresis: no exit is produced until the device is beyond `radius × 1.5`,
    /// so that location error near the boundary cannot cause enter/exit flapping.
    private let exitHysteresisFactor: Double = 1.5

    private let fenceRepository: FenceRepository
    private let deviceStateRepository: DeviceStateRepository

    init(fenceRepository: FenceRepository, deviceStateRepository: DeviceStateRepository) {
        self.fenceRepository = fenceRepository
        self.deviceStateRepository = deviceStateRepository
    }

    /// Compares the location against the state table and returns the transitions that should fire.
    /// Pure computation — it neither sends events nor writes state; both are `TriggerHandler`'s job.
    ///
    /// Accuracy-aware: `horizontalAccuracy` is the fix's uncertainty radius, so it is used as a
    /// confidence margin. The reconciler only acts when the fix is confident enough; the uncertain
    /// band is left to the OS (which has its own buffer and multiple samples). This kills
    /// accuracy-blind false transitions from a coarse fix.
    func reconcile(location: CLLocation) -> [(fence: EngineFence, eventType: GeofenceEventType)] {
        // Accuracy yok/geçersizse tüm konum belirsiz sayılır → hiçbir fence için karar verme.
        guard location.horizontalAccuracy > 0 else {
            Logger.log(message: "ContainmentReconciler -> skipped: location accuracy unknown")
            return []
        }
        let accuracy = location.horizontalAccuracy
        var pending: [(fence: EngineFence, eventType: GeofenceEventType)] = []

        for fence in fenceRepository.loadAll() where fence.geofenceId > 0 {
            let distance = location.distance(from: CLLocation(latitude: fence.latitude, longitude: fence.longitude))
            let state = deviceStateRepository.getState(geofenceId: fence.geofenceId)?.state
            let deviceThinksInside = isInsideState(state)

            if distance + accuracy <= fence.radiusM {
                // Kesin içeride (en kötü uzak nokta bile radius'ta) ama tablo bilmiyor → geç/eksik enter.
                if !deviceThinksInside {
                    pending.append((fence, .enter))
                }
            } else if deviceThinksInside, distance - accuracy > fence.radiusM * exitHysteresisFactor {
                // Kesin dışarıda (en kötü yakın nokta bile histerezis sınırının ötesinde) → kaçan exit.
                pending.append((fence, .exit))
            }
            // Aradaki belirsiz band → dokunma, OS'a bırak.
        }

        if !pending.isEmpty {
            Logger.log(message: "ContainmentReconciler -> \(pending.count) synthetic transition(s)")
        }
        return pending
    }

    /// `dwellPending` also means the device is inside (inside + dwell already fired).
    private func isInsideState(_ state: FenceState?) -> Bool {
        state == .inside || state == .dwellPending
    }
}

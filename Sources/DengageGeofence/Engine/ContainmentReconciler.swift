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

    /// Hard cap on fix age. Past this the staleness penalty would swamp any realistic fence radius
    /// anyway, so we skip outright instead of pretending to compute something.
    private let maxTrustedFixAge: TimeInterval = 15 * 60

    /// Distance-per-second charged against an aging fix when the real speed is unknown
    /// (~walking pace). Combined with the cap this tops out at ~1.3km of extra uncertainty.
    private let assumedSpeedMps: Double = 1.5

    private let fenceRepository: FenceRepository
    private let deviceStateRepository: DeviceStateRepository

    init(fenceRepository: FenceRepository, deviceStateRepository: DeviceStateRepository) {
        self.fenceRepository = fenceRepository
        self.deviceStateRepository = deviceStateRepository
    }

    /// Compares the location against the state table and returns the transitions that should fire.
    /// Pure computation — it neither sends events nor writes state; both are `TriggerHandler`'s job.
    ///
    /// Confidence has two dimensions, and both feed the same margin:
    /// - **Spatial:** `horizontalAccuracy` is the fix's uncertainty radius.
    /// - **Temporal:** a cached fix describes where the device *was*. Every second since then is
    ///   distance the device may have covered unobserved, so the age is converted into extra
    ///   uncertainty via `assumedSpeedMps` and added on top of the accuracy.
    ///
    /// The reconciler only acts outside that combined margin; the uncertain band is left to the OS
    /// (which has its own buffer and multiple samples). This kills both accuracy-blind false
    /// transitions from a coarse fix and staleness-blind ones from a cached fix — the latter matters
    /// because the wake path feeds us `locationManager.location` (or our own `lastReevalLocation`),
    /// neither of which carries any freshness guarantee.
    ///
    /// `now` is injectable for tests.
    func reconcile(location: CLLocation, now: Date = Date()) -> [(fence: EngineFence, eventType: GeofenceEventType)] {
        // Accuracy yok/geçersizse tüm konum belirsiz sayılır → hiçbir fence için karar verme.
        guard location.horizontalAccuracy > 0 else {
            Logger.log(message: "ContainmentReconciler -> skipped: location accuracy unknown")
            return []
        }
        // A fix older than the cap is not worth reasoning about at any margin; leave it to the OS.
        // A negative age means clock skew, not a fix from the future — treat it as fresh.
        let ageSeconds = max(0, now.timeIntervalSince(location.timestamp))
        guard ageSeconds <= maxTrustedFixAge else {
            Logger.log(message: "ContainmentReconciler -> skipped: fix is \(Int(ageSeconds))s old")
            return []
        }

        // Staleness penalty. A known speed only ever widens the margin (a moving device covers more
        // ground than the walking assumption); it never shrinks it below the assumed floor, because
        // the speed at fix time does not promise the device stayed that slow afterwards.
        let speedMps = location.speed > 0 ? max(location.speed, assumedSpeedMps) : assumedSpeedMps
        let margin = location.horizontalAccuracy + ageSeconds * speedMps
        var pending: [(fence: EngineFence, eventType: GeofenceEventType)] = []

        for fence in fenceRepository.loadAll() where fence.geofenceId > 0 {
            let distance = location.distance(from: CLLocation(latitude: fence.latitude, longitude: fence.longitude))
            let record = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            let state = record?.state
            let deviceThinksInside = isInsideState(state)

            if distance + margin <= fence.radiusM {
                // Kesin içeride (en kötü uzak nokta bile radius'ta) ama tablo bilmiyor → geç/eksik enter.
                if !deviceThinksInside {
                    pending.append((fence, .enter))
                } else if state == .inside,
                          let enteredAt = record?.enteredAt,
                          let dwellMinutes = fence.campaigns
                              .filter({ $0.triggerType == .dwell })
                              .compactMap({ $0.dwellMinutes })
                              .max(),
                          dwellMinutes > 0,
                          now.timeIntervalSince1970 - enteredAt >= Double(dwellMinutes * 60) {
                    // Dwell repair (doc 23 İş 2): process suspend'inde ölen in-memory dwell timer'ının
                    // kalıcı ağı — persist edilen enteredAt üzerinden dwell tamamlanır. `.inside` şartı
                    // `.dwellPending`'i (bu ziyarette zaten atıldı) dışlar; dedup da aynı kuralı uygular.
                    pending.append((fence, .dwell))
                }
            } else if deviceThinksInside, distance - margin > fence.radiusM * exitHysteresisFactor {
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

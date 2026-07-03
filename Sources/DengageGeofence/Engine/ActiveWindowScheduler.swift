import Foundation
import Dengage

/// `next_state_change_at` için boundary scheduling (doc 21 §6.5).
/// En yakın gelecekteki aktiflik durum değişimine bir reeval planlar (best-effort, process canlıyken).
/// Not: Arka planda garanti tetikleme için host app `BGAppRefreshTask` kaydı gerekir (Faz 2).
final class ActiveWindowScheduler {

    private var pendingWork: DispatchWorkItem?
    private let onFire: () -> Void
    private let minDelay: TimeInterval = 60

    init(onFire: @escaping () -> Void) {
        self.onFire = onFire
    }

    func schedule(fences: [EngineFence], now: TimeInterval = Date().timeIntervalSince1970) {
        cancel()
        let nextBoundarySeconds = fences
            .compactMap { $0.nextStateChangeAtMillis.map { $0 / 1000.0 } }
            .filter { $0 > now }
            .min()

        guard let next = nextBoundarySeconds else { return }
        let delay = max(next - now, minDelay)

        let work = DispatchWorkItem { [weak self] in self?.onFire() }
        pendingWork = work
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + delay, execute: work)
        Logger.log(message: "ActiveWindowScheduler -> scheduled reeval in \(Int(delay))s")
    }

    func cancel() {
        pendingWork?.cancel()
        pendingWork = nil
    }
}

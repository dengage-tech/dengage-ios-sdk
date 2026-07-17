import Foundation
import Dengage

/// Wake-up cap + SLC pause/resume (K13, doc 21 §11.5).
/// OS'un periyodik konum izin dialog'unu tetiklememek için saatlik wake-up sayısına hard cap uygular.
/// Cap aşılınca SLC pause edilir; çoklu fırsatçı kanaldan biri `attemptResume` çağırır.
final class WakeupCapController {

    enum Action { case proceed, skipPaused, pauseAndSkip }

    private let configProvider: () -> WakeupCapConfig
    private let onPause: () -> Void
    private let onResume: () -> Void
    private let scheduleResume: (_ delayMinutes: Int) -> Void
    private let syncMetadata: SyncMetadataRepository

    private var timestamps: [TimeInterval] = []
    private(set) var isPaused = false
    private var pausedAt: TimeInterval = 0
    private let lock = NSLock()

    init(configProvider: @escaping () -> WakeupCapConfig,
         onPause: @escaping () -> Void,
         onResume: @escaping () -> Void,
         scheduleResume: @escaping (_ delayMinutes: Int) -> Void,
         syncMetadata: SyncMetadataRepository) {
        self.configProvider = configProvider
        self.onPause = onPause
        self.onResume = onResume
        self.scheduleResume = scheduleResume
        self.syncMetadata = syncMetadata

        // Taze process: pause durumunu diskten hidrate et. Aksi halde `isPaused = false` sanılır,
        // `attemptResume()` erken döner ve OS seviyesinde kapatılmış SLC bir daha açılmaz.
        if let persisted = syncMetadata.wakeupPausedAt, persisted > 0 {
            isPaused = true
            pausedAt = persisted
        }
    }

    /// Her SLC wake-up'ta çağrılır. Cap aşıldıysa pause başlatır.
    func recordWakeup(now: TimeInterval = Date().timeIntervalSince1970) -> Action {
        lock.lock(); defer { lock.unlock() }
        let config = configProvider()
        purgeOldTimestamps(now: now, config: config)

        if isPaused { return .skipPaused }

        timestamps.append(now)
        if timestamps.count > config.hourlyMax {
            pause(now: now, config: config)
            return .pauseAndSkip
        }
        return .proceed
    }

    /// Worker/push/foreground/region callback'lerinden çağrılır.
    func attemptResume(now: TimeInterval = Date().timeIntervalSince1970) {
        lock.lock()
        guard isPaused else { lock.unlock(); return }
        let config = configProvider()
        if now - pausedAt < Double(config.pauseMinutes * 60) {
            lock.unlock()
            return
        }
        isPaused = false
        timestamps.removeAll()
        syncMetadata.wakeupPausedAt = nil
        lock.unlock()
        Logger.log(message: "WakeupCap -> resume")
        onResume()
    }

    func reset() {
        lock.lock(); defer { lock.unlock() }
        isPaused = false
        timestamps.removeAll()
        pausedAt = 0
        syncMetadata.wakeupPausedAt = nil
    }

    private func pause(now: TimeInterval, config: WakeupCapConfig) {
        isPaused = true
        pausedAt = now
        syncMetadata.wakeupPausedAt = now
        Logger.log(message: "WakeupCap -> cap exceeded, pausing for \(config.pauseMinutes)min")
        onPause()
        scheduleResume(config.pauseMinutes)
    }

    private func purgeOldTimestamps(now: TimeInterval, config: WakeupCapConfig) {
        let cutoff = now - Double(config.slidingWindowMinutes * 60)
        timestamps.removeAll { $0 < cutoff }
    }
}

import Foundation
import CoreLocation
import Dengage

/// Adaptif hareket eşiği (K12, doc 19 §12 / doc 21 §12.6).
/// Cihazın anlık hızına göre reeval mesafe eşiğini ayarlar; cooldown ve transit modu uygular.
final class AdaptiveThresholdCalculator {

    enum Decision {
        /// syncAllowed: transit modunda değilsek server sync yapılabilir.
        case reeval(syncAllowed: Bool)
        case skip(reason: SkipReason)
    }
    enum SkipReason { case cooldown, belowThreshold }

    private struct SpeedSample { let timestamp: TimeInterval; let speedKmh: Double }

    private let configProvider: () -> AdaptiveThresholdConfig
    private var speedSamples: [SpeedSample] = []
    private var lastReevalAt: TimeInterval = 0
    private(set) var isTransitMode = false
    private var transitEnterCandidateSince: TimeInterval?
    private var transitExitCandidateSince: TimeInterval?
    private let lock = NSLock()

    init(configProvider: @escaping () -> AdaptiveThresholdConfig) {
        self.configProvider = configProvider
    }

    func shouldReeval(current: CLLocation,
                      lastReevalLocation: CLLocation?,
                      now: TimeInterval = Date().timeIntervalSince1970) -> Decision {
        lock.lock(); defer { lock.unlock() }
        let config = configProvider()

        // 1. Anlık hız örneği (m/s -> km/h). speed geçersizse (negatif) 0 say.
        let speedKmh = max(0, current.speed) * 3.6
        speedSamples.append(SpeedSample(timestamp: now, speedKmh: speedKmh))
        purgeOldSamples(now: now, config: config)

        // 2. Cooldown
        if lastReevalAt != 0, (now - lastReevalAt) < Double(config.cooldownSeconds) {
            return .skip(reason: .cooldown)
        }

        // 3. Transit modu
        evaluateTransitMode(now: now, config: config)

        // 4. Hıza göre mesafe eşiği
        let threshold = currentThresholdMeters(speedKmh: speedKmh, config: config)
        guard let last = lastReevalLocation else {
            return reeval(now: now)
        }
        if current.distance(from: last) < Double(threshold) {
            return .skip(reason: .belowThreshold)
        }
        return reeval(now: now)
    }

    func reset() {
        lock.lock(); defer { lock.unlock() }
        speedSamples.removeAll()
        lastReevalAt = 0
        isTransitMode = false
        transitEnterCandidateSince = nil
        transitExitCandidateSince = nil
    }

    private func reeval(now: TimeInterval) -> Decision {
        lastReevalAt = now
        return .reeval(syncAllowed: !isTransitMode)
    }

    private func currentThresholdMeters(speedKmh: Double, config: AdaptiveThresholdConfig) -> Int {
        var threshold = config.tiers.first?.thresholdMeters
            ?? AdaptiveThresholdConfig.defaultTiers.first!.thresholdMeters
        for tier in config.tiers { // tiers clamp'te artan minSpeedKmh sıralı
            if speedKmh >= Double(tier.minSpeedKmh) { threshold = tier.thresholdMeters } else { break }
        }
        return threshold
    }

    private func evaluateTransitMode(now: TimeInterval, config: AdaptiveThresholdConfig) {
        // En güncel hız. Candidate-since timer "sustained for N minutes" semantiğini sağlar.
        let currentSpeedKmh = speedSamples.last?.speedKmh ?? 0

        if !isTransitMode {
            if currentSpeedKmh > Double(config.transitModeEntrySpeedKmh) {
                if transitEnterCandidateSince == nil { transitEnterCandidateSince = now }
                if now - (transitEnterCandidateSince ?? now) >= Double(config.transitModeEntryMinutes * 60) {
                    isTransitMode = true
                    transitExitCandidateSince = nil
                    Logger.log(message: "AdaptiveThreshold -> transit mode ENTER")
                }
            } else {
                transitEnterCandidateSince = nil
            }
        } else {
            if currentSpeedKmh <= Double(config.transitModeExitSpeedKmh) {
                if transitExitCandidateSince == nil { transitExitCandidateSince = now }
                if now - (transitExitCandidateSince ?? now) >= Double(config.transitModeExitMinutes * 60) {
                    isTransitMode = false
                    transitEnterCandidateSince = nil
                    Logger.log(message: "AdaptiveThreshold -> transit mode EXIT")
                }
            } else {
                transitExitCandidateSince = nil
            }
        }
    }

    private func purgeOldSamples(now: TimeInterval, config: AdaptiveThresholdConfig) {
        let maxWindow = Double(max(config.transitModeEntryMinutes, config.transitModeExitMinutes) * 60 + 60)
        let cutoff = now - maxWindow
        speedSamples.removeAll { $0.timestamp < cutoff }
    }
}

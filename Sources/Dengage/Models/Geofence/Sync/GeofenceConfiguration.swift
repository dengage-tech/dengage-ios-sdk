import Foundation

/// Geofence tuning config'i. Sync response'ta DEĞİL; merkezi `SdkParameters.geofence` bloğunda gelir
/// (contract §4). SDK okurken aralık dışı değerleri min/max'a clamp eder ([clamped]).
public struct GeofenceConfiguration: Codable {
    public let reevaluationDistanceMeters: Int
    public let topN: Int
    public let syncHorizonHours: Int
    public let heartbeatIntervalMinutes: Int
    public let offlineQueueMaxSize: Int
    public let adaptiveThreshold: AdaptiveThresholdConfig
    public let wakeupCap: WakeupCapConfig

    public init(reevaluationDistanceMeters: Int = 1000,
                topN: Int = 20,
                syncHorizonHours: Int = 25,
                heartbeatIntervalMinutes: Int = 60,
                offlineQueueMaxSize: Int = 100,
                adaptiveThreshold: AdaptiveThresholdConfig = AdaptiveThresholdConfig(),
                wakeupCap: WakeupCapConfig = WakeupCapConfig()) {
        self.reevaluationDistanceMeters = reevaluationDistanceMeters
        self.topN = topN
        self.syncHorizonHours = syncHorizonHours
        self.heartbeatIntervalMinutes = heartbeatIntervalMinutes
        self.offlineQueueMaxSize = offlineQueueMaxSize
        self.adaptiveThreshold = adaptiveThreshold
        self.wakeupCap = wakeupCap
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        reevaluationDistanceMeters = (try? c.decode(Int.self, forKey: .reevaluationDistanceMeters)) ?? 1000
        topN = (try? c.decode(Int.self, forKey: .topN)) ?? 20
        syncHorizonHours = (try? c.decode(Int.self, forKey: .syncHorizonHours)) ?? 25
        heartbeatIntervalMinutes = (try? c.decode(Int.self, forKey: .heartbeatIntervalMinutes)) ?? 60
        offlineQueueMaxSize = (try? c.decode(Int.self, forKey: .offlineQueueMaxSize)) ?? 100
        adaptiveThreshold = (try? c.decode(AdaptiveThresholdConfig.self, forKey: .adaptiveThreshold)) ?? AdaptiveThresholdConfig()
        wakeupCap = (try? c.decode(WakeupCapConfig.self, forKey: .wakeupCap)) ?? WakeupCapConfig()
    }

    enum CodingKeys: String, CodingKey {
        case reevaluationDistanceMeters, topN, syncHorizonHours, heartbeatIntervalMinutes
        case offlineQueueMaxSize, adaptiveThreshold, wakeupCap
    }

    /// Tüm alanları contract §4 min/max aralığına clamp edilmiş bir kopya.
    public func clamped() -> GeofenceConfiguration {
        GeofenceConfiguration(
            reevaluationDistanceMeters: min(max(reevaluationDistanceMeters, 100), 50000),
            topN: min(max(topN, 5), 100),
            syncHorizonHours: min(max(syncHorizonHours, 12), 168),
            heartbeatIntervalMinutes: min(max(heartbeatIntervalMinutes, 15), 1440),
            offlineQueueMaxSize: min(max(offlineQueueMaxSize, 10), 1000),
            adaptiveThreshold: adaptiveThreshold.clamped(),
            wakeupCap: wakeupCap.clamped()
        )
    }
}

public struct AdaptiveThresholdConfig: Codable {
    public let tiers: [AdaptiveTier]
    public let cooldownSeconds: Int
    public let transitModeEntryMinutes: Int
    public let transitModeEntrySpeedKmh: Int
    public let transitModeExitMinutes: Int
    public let transitModeExitSpeedKmh: Int

    public init(tiers: [AdaptiveTier] = AdaptiveThresholdConfig.defaultTiers,
                cooldownSeconds: Int = 60,
                transitModeEntryMinutes: Int = 5,
                transitModeEntrySpeedKmh: Int = 20,
                transitModeExitMinutes: Int = 3,
                transitModeExitSpeedKmh: Int = 5) {
        self.tiers = tiers
        self.cooldownSeconds = cooldownSeconds
        self.transitModeEntryMinutes = transitModeEntryMinutes
        self.transitModeEntrySpeedKmh = transitModeEntrySpeedKmh
        self.transitModeExitMinutes = transitModeExitMinutes
        self.transitModeExitSpeedKmh = transitModeExitSpeedKmh
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let decodedTiers = (try? c.decode([AdaptiveTier].self, forKey: .tiers)) ?? []
        tiers = decodedTiers.isEmpty ? AdaptiveThresholdConfig.defaultTiers : decodedTiers
        cooldownSeconds = (try? c.decode(Int.self, forKey: .cooldownSeconds)) ?? 60
        transitModeEntryMinutes = (try? c.decode(Int.self, forKey: .transitModeEntryMinutes)) ?? 5
        transitModeEntrySpeedKmh = (try? c.decode(Int.self, forKey: .transitModeEntrySpeedKmh)) ?? 20
        transitModeExitMinutes = (try? c.decode(Int.self, forKey: .transitModeExitMinutes)) ?? 3
        transitModeExitSpeedKmh = (try? c.decode(Int.self, forKey: .transitModeExitSpeedKmh)) ?? 5
    }

    enum CodingKeys: String, CodingKey {
        case tiers, cooldownSeconds, transitModeEntryMinutes, transitModeEntrySpeedKmh
        case transitModeExitMinutes, transitModeExitSpeedKmh
    }

    public func clamped() -> AdaptiveThresholdConfig {
        AdaptiveThresholdConfig(
            tiers: tiers.sorted { $0.minSpeedKmh < $1.minSpeedKmh },
            cooldownSeconds: min(max(cooldownSeconds, 10), 600),
            transitModeEntryMinutes: min(max(transitModeEntryMinutes, 1), 30),
            transitModeEntrySpeedKmh: min(max(transitModeEntrySpeedKmh, 5), 100),
            transitModeExitMinutes: min(max(transitModeExitMinutes, 1), 30),
            transitModeExitSpeedKmh: min(max(transitModeExitSpeedKmh, 1), 50)
        )
    }

    public static let defaultTiers: [AdaptiveTier] = [
        AdaptiveTier(minSpeedKmh: 0, thresholdMeters: 1000),
        AdaptiveTier(minSpeedKmh: 20, thresholdMeters: 2000),
        AdaptiveTier(minSpeedKmh: 60, thresholdMeters: 5000),
        AdaptiveTier(minSpeedKmh: 150, thresholdMeters: 20000)
    ]
}

public struct AdaptiveTier: Codable {
    public let minSpeedKmh: Int
    public let thresholdMeters: Int

    public init(minSpeedKmh: Int, thresholdMeters: Int) {
        self.minSpeedKmh = minSpeedKmh
        self.thresholdMeters = thresholdMeters
    }
}

public struct WakeupCapConfig: Codable {
    public let hourlyMax: Int
    public let pauseMinutes: Int
    public let slidingWindowMinutes: Int

    public init(hourlyMax: Int = 6, pauseMinutes: Int = 30, slidingWindowMinutes: Int = 60) {
        self.hourlyMax = hourlyMax
        self.pauseMinutes = pauseMinutes
        self.slidingWindowMinutes = slidingWindowMinutes
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hourlyMax = (try? c.decode(Int.self, forKey: .hourlyMax)) ?? 6
        pauseMinutes = (try? c.decode(Int.self, forKey: .pauseMinutes)) ?? 30
        slidingWindowMinutes = (try? c.decode(Int.self, forKey: .slidingWindowMinutes)) ?? 60
    }

    enum CodingKeys: String, CodingKey {
        case hourlyMax, pauseMinutes, slidingWindowMinutes
    }

    public func clamped() -> WakeupCapConfig {
        WakeupCapConfig(
            hourlyMax: min(max(hourlyMax, 3), 30),
            pauseMinutes: min(max(pauseMinutes, 5), 240),
            slidingWindowMinutes: min(max(slidingWindowMinutes, 30), 360)
        )
    }
}

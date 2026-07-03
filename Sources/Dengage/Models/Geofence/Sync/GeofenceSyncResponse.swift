import Foundation

/// `GET /geofences/sync/{integrationKey}` cevabının kökü (contract §1).
///
/// Tuning/remote config (topN, reevaluationDistanceMeters, adaptiveThreshold ...) bu cevapta DEĞİLDİR;
/// merkezi `SdkParameters.geofence` bloğundan okunur (contract §4).
public struct GeofenceSyncResponse: Codable {
    public let etag: String?
    public let syncedAt: String?
    public let horizonUntil: String?
    public let geofences: [SyncFence]

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        etag = try? c.decode(String.self, forKey: .etag)
        syncedAt = try? c.decode(String.self, forKey: .syncedAt)
        horizonUntil = try? c.decode(String.self, forKey: .horizonUntil)
        geofences = (try? c.decode([SyncFence].self, forKey: .geofences)) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case etag, syncedAt, horizonUntil, geofences
    }
}

/// Cihazın izlemesi gereken tek bir fence (contract §1 `SyncFence`).
public struct SyncFence: Codable {
    public let fenceId: Int
    public let clusterId: Int
    public let latitude: Double
    public let longitude: Double
    public let radiusM: Double
    public let title: String?
    public let activeNow: Bool
    public let nextStateChangeAt: String?
    public let nextStateChangeTo: String?
    public let campaigns: [SyncCampaign]

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        fenceId = (try? c.decode(Int.self, forKey: .fenceId)) ?? 0
        clusterId = (try? c.decode(Int.self, forKey: .clusterId)) ?? 0
        latitude = (try? c.decode(Double.self, forKey: .latitude)) ?? 0
        longitude = (try? c.decode(Double.self, forKey: .longitude)) ?? 0
        radiusM = (try? c.decode(Double.self, forKey: .radiusM)) ?? 0
        title = try? c.decode(String.self, forKey: .title)
        activeNow = (try? c.decode(Bool.self, forKey: .activeNow)) ?? false
        nextStateChangeAt = try? c.decode(String.self, forKey: .nextStateChangeAt)
        nextStateChangeTo = try? c.decode(String.self, forKey: .nextStateChangeTo)
        campaigns = (try? c.decode([SyncCampaign].self, forKey: .campaigns)) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case fenceId, clusterId, latitude, longitude, radiusM, title
        case activeNow, nextStateChangeAt, nextStateChangeTo, campaigns
    }
}

/// Bir fence'e bağlı kampanya metadata'sı (contract §1 `SyncCampaign`).
public struct SyncCampaign: Codable {
    public let campaignId: Int
    public let campaignPublicId: String?
    public let triggerType: GeofenceTriggerType
    public let dwellMinutes: Int?
    public let activeNow: Bool
    public let nextStateChangeAt: String?
    public let offlinePushContent: OfflinePushContent?

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        campaignId = (try? c.decode(Int.self, forKey: .campaignId)) ?? 0
        campaignPublicId = try? c.decode(String.self, forKey: .campaignPublicId)
        triggerType = GeofenceTriggerType.from((try? c.decode(String.self, forKey: .triggerType)))
        dwellMinutes = try? c.decode(Int.self, forKey: .dwellMinutes)
        activeNow = (try? c.decode(Bool.self, forKey: .activeNow)) ?? false
        nextStateChangeAt = try? c.decode(String.self, forKey: .nextStateChangeAt)
        offlinePushContent = try? c.decode(OfflinePushContent.self, forKey: .offlinePushContent)
    }

    enum CodingKeys: String, CodingKey {
        case campaignId, campaignPublicId, triggerType, dwellMinutes
        case activeNow, nextStateChangeAt, offlinePushContent
    }
}

/// Fence ile birlikte cache'lenen offline push içeriği (K10/K11, contract §1).
/// Offline trigger anında local notification network olmadan gösterilir.
public struct OfflinePushContent: Codable {
    public let title: String?
    public let body: String?
    public let imageUrl: String?
    public let deepLink: String?
    public let customParams: [String: String]?

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = try? c.decode(String.self, forKey: .title)
        body = try? c.decode(String.self, forKey: .body)
        imageUrl = try? c.decode(String.self, forKey: .imageUrl)
        deepLink = try? c.decode(String.self, forKey: .deepLink)
        customParams = try? c.decode([String: String].self, forKey: .customParams)
    }

    public init(title: String?, body: String?, imageUrl: String?, deepLink: String?, customParams: [String: String]?) {
        self.title = title
        self.body = body
        self.imageUrl = imageUrl
        self.deepLink = deepLink
        self.customParams = customParams
    }

    enum CodingKeys: String, CodingKey {
        case title, body, imageUrl, deepLink, customParams
    }
}

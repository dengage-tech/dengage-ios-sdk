import Foundation
struct GetSDKParamsResponse: Codable {
    let accountName: String?
    let eventsEnabled: Bool
    let inboxEnabled: Bool
    let inAppEnabled: Bool
    let subscriptionEnabled: Bool
    let realTimeInAppEnabled: Bool
    let realTimeInAppSessionTimeoutMinutes: Int
    let appId: String?
    
    private let inAppFetchIntervalInMin: Int
    private let inAppMinSecBetweenMessages: Int
    
    var fetchIntervalInMin: Double{
        Double(inAppFetchIntervalInMin * 60000)
    }
    
    var minSecBetweenMessages: Double{
        Double(inAppMinSecBetweenMessages * 1000)
    }
    
    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountName = try? container.decode(String.self, forKey: .accountName)
        appId = try? container.decode(String.self, forKey: .appId)

        eventsEnabled = (try? container.decode(Bool.self, forKey: .eventsEnabled)) ?? false
        inboxEnabled = (try? container.decode(Bool.self, forKey: .inboxEnabled)) ?? false
        inAppEnabled = (try? container.decode(Bool.self, forKey: .inAppEnabled)) ?? false
        subscriptionEnabled = (try? container.decode(Bool.self, forKey: .subscriptionEnabled)) ?? false
        inAppFetchIntervalInMin = (try? container.decode(Int.self, forKey: .inAppFetchIntervalInMin)) ?? 0
        inAppMinSecBetweenMessages = (try? container.decode(Int.self, forKey: .inAppMinSecBetweenMessages)) ?? 0
        realTimeInAppEnabled = (try? container.decode(Bool.self, forKey: .realTimeInAppEnabled)) ?? false
        realTimeInAppSessionTimeoutMinutes = (try? container.decode(Int.self, forKey: .realTimeInAppSessionTimeoutMinutes)) ?? 1800
    }
    
    enum CodingKeys: String, CodingKey {
        case accountName
        case appId
        case eventsEnabled
        case inboxEnabled
        case inAppEnabled
        case subscriptionEnabled
        case inAppFetchIntervalInMin
        case inAppMinSecBetweenMessages
        case realTimeInAppEnabled
        case realTimeInAppSessionTimeoutMinutes
    }
}

import Foundation

public struct GetSDKParamsResponse: Codable {
    let accountName: String?
    let eventsEnabled: Bool
    let inboxEnabled: Bool
    let inAppEnabled: Bool
    let subscriptionEnabled: Bool
    let appId: String?
    let realTimeInAppEnabled: Bool
    let realTimeInAppSessionTimeoutMinutes: Int
    public let eventMappings: [EventMapping]
    let debugDeviceIds: [String]?
    
    private let inAppFetchIntervalInMin: Int
    private let inAppMinSecBetweenMessages: Int
    private let expiredMessagesFetchIntervalInMin: Int
    
    var fetchIntervalInMin: Double {
        Double(inAppFetchIntervalInMin * 60000)
    }
    
    var fetchexpiredMessagesFetchIntervalInMin: Double {
        Double(expiredMessagesFetchIntervalInMin * 60000)
    }
    
    var minSecBetweenMessages: Double {
        Double(inAppMinSecBetweenMessages * 1000)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountName = try? container.decode(String.self, forKey: .accountName)
        eventsEnabled = (try? container.decode(Bool.self, forKey: .eventsEnabled)) ?? false
        inboxEnabled = (try? container.decode(Bool.self, forKey: .inboxEnabled)) ?? false
        inAppEnabled = (try? container.decode(Bool.self, forKey: .inAppEnabled)) ?? false
        subscriptionEnabled = (try? container.decode(Bool.self, forKey: .subscriptionEnabled)) ?? false
        inAppFetchIntervalInMin = (try? container.decode(Int.self, forKey: .inAppFetchIntervalInMin)) ?? 0
        inAppMinSecBetweenMessages = (try? container.decode(Int.self, forKey: .inAppMinSecBetweenMessages)) ?? 0
        expiredMessagesFetchIntervalInMin = (try? container.decode(Int.self, forKey: .expiredMessagesFetchIntervalInMin)) ?? 0
        appId = try? container.decode(String.self, forKey: .appId)
        realTimeInAppEnabled = (try? container.decode(Bool.self, forKey: .realTimeInAppEnabled)) ?? false
        realTimeInAppSessionTimeoutMinutes = (try? container.decode(Int.self, forKey: .realTimeInAppSessionTimeoutMinutes)) ?? 1800
        eventMappings = (try? container.decode([EventMapping].self, forKey: .eventMappings)) ?? []
        debugDeviceIds = try? container.decode([String].self, forKey: .debugDeviceIds)
    }
    
    enum CodingKeys: String, CodingKey {
        case accountName
        case eventsEnabled
        case inboxEnabled
        case inAppEnabled
        case subscriptionEnabled
        case inAppFetchIntervalInMin
        case inAppMinSecBetweenMessages
        case expiredMessagesFetchIntervalInMin
        case appId
        case realTimeInAppEnabled
        case realTimeInAppSessionTimeoutMinutes
        case eventMappings
        case debugDeviceIds
    }
}

// MARK: - EventMapping Models

public struct EventMapping: Codable {
    public let eventTableName: String?
    public let eventTypeDefinitions: [EventTypeDefinition]?
}

public struct EventTypeDefinition: Codable {
    public let eventTypeId: Int?
    public let eventType: String?
    public let logicOperator: String?
    public let filterConditions: [FilterCondition]?
    public let enableClientHistory: Bool?
    public let clientHistoryOptions: ClientHistoryOptions?
    public let attributes: [EventAttribute]?
}

public struct FilterCondition: Codable {
    public let fieldName: String?
    public let `operator`: String?
    public let values: [String]?
    
    enum CodingKeys: String, CodingKey {
        case fieldName
        case `operator` = "operator"
        case values
    }
}

public struct ClientHistoryOptions: Codable {
    public let maxEventCount: Int?
    public let timeWindowInMinutes: Int?
}

public struct EventAttribute: Codable {
    public let name: String?
    public let dataType: String?
    public let tableColumnName: String?
}

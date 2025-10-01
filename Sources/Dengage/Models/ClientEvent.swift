import Foundation

struct ClientEvent: Codable {
    let tableName: String
    let eventType: String
    let key: String?
    let eventDetails: [String: Any]
    let timestamp: TimeInterval
    let sessionId: String?
    
    init(tableName: String, eventType: String, key: String?, eventDetails: [String: Any], timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000) {
        self.tableName = tableName
        self.eventType = eventType
        self.key = key
        self.eventDetails = eventDetails
        self.timestamp = timestamp
        self.sessionId = eventDetails["session_id"] as? String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tableName = try container.decode(String.self, forKey: .tableName)
        eventType = try container.decode(String.self, forKey: .eventType)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        let eventDetailsData = try container.decode(Data.self, forKey: .eventDetails)
        eventDetails = try JSONSerialization.jsonObject(with: eventDetailsData) as? [String: Any] ?? [:]
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tableName, forKey: .tableName)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(key, forKey: .key)
        try container.encode(timestamp, forKey: .timestamp)
        let eventDetailsData = try JSONSerialization.data(withJSONObject: eventDetails)
        try container.encode(eventDetailsData, forKey: .eventDetails)
        try container.encodeIfPresent(sessionId, forKey: .sessionId)
    }
    
    enum CodingKeys: String, CodingKey {
        case tableName, eventType, key, eventDetails, timestamp, sessionId
    }
}

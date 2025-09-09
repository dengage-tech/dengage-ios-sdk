import Foundation

struct ClientEvent: Codable {
    let tableName: String
    let key: String?
    let eventDetails: [String: Any]
    let timestamp: TimeInterval
    
    init(tableName: String, key: String?, eventDetails: [String: Any], timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.tableName = tableName
        self.key = key
        self.eventDetails = eventDetails
        self.timestamp = timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tableName = try container.decode(String.self, forKey: .tableName)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        
        let eventDetailsData = try container.decode(Data.self, forKey: .eventDetails)
        eventDetails = try JSONSerialization.jsonObject(with: eventDetailsData) as? [String: Any] ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tableName, forKey: .tableName)
        try container.encodeIfPresent(key, forKey: .key)
        try container.encode(timestamp, forKey: .timestamp)
        
        let eventDetailsData = try JSONSerialization.data(withJSONObject: eventDetails)
        try container.encode(eventDetailsData, forKey: .eventDetails)
    }
    
    enum CodingKeys: String, CodingKey {
        case tableName, key, eventDetails, timestamp
    }
}

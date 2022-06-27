import Foundation

@objc public class DengageGeofenceHistory: NSObject, Codable {
    public var lastLat: Double
    public var lastLon: Double
    public var lastFetchTime: Date
    public var fetchHistory: [Date: [DengageGeofenceCluster]]
    public var eventHistory: [String: [Date: DengageGeofenceEvent]]

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastLat = (try? container.decode(Double.self, forKey: .lastLat)) ?? 0.0
        lastLon = (try? container.decode(Double.self, forKey: .lastLon)) ?? 0.0
        lastFetchTime = (try? container.decode(Date.self, forKey: .lastFetchTime)) ?? Date.distantPast
        fetchHistory = (try? container.decode([Date: [DengageGeofenceCluster]].self, forKey: .fetchHistory))
        ?? [Date: [DengageGeofenceCluster]]()
        eventHistory = (try? container.decode([String: [Date: DengageGeofenceEvent]].self, forKey: .eventHistory))
        ?? [String: [Date: DengageGeofenceEvent]]()
    }

    public override init() {
        lastLat = 0.0
        lastLon = 0.0
        lastFetchTime = Date.distantPast
        fetchHistory = [Date: [DengageGeofenceCluster]]()
        eventHistory = [String: [Date: DengageGeofenceEvent]]()
    }

    enum CodingKeys: String, CodingKey {
        case lastLat, lastLon, lastFetchTime, fetchHistory, eventHistory
    }

}

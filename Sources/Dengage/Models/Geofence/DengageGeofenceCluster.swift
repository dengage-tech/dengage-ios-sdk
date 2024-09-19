import Foundation

@objc public class DengageGeofenceCluster: NSObject, Codable {
    public let id: Int
    public let geofences: [DengageGeofenceItem]?

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        geofences = try? container.decode([DengageGeofenceItem].self, forKey: .geofences)
    }

    enum CodingKeys: String, CodingKey {
        case id, geofences
    }
}

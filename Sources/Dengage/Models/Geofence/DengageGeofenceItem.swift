import Foundation

@objc public class DengageGeofenceItem: NSObject, Codable {
    public let id: Int
    public let lat: Double
    public let lon: Double
    public let radius: Double

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        radius = try container.decode(Double.self, forKey: .radius)
    }

    enum CodingKeys: String, CodingKey {
        case id, lat, lon = "long", radius
    }
}

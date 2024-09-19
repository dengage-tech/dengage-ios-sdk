import Foundation

@objc public class DengageGeofenceEvent: NSObject, Codable {
    public let identifier: String
    public let cid: Int
    public let geoid: Int
    public let type: String
    public let et: Date
    public let pp: Bool
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        cid = try container.decode(Int.self, forKey: .cid)
        geoid = try container.decode(Int.self, forKey: .geoid)
        type = try container.decode(String.self, forKey: .type)
        et = try container.decode(Date.self, forKey: .et)
        pp = (try? container.decode(Bool.self, forKey: .pp)) ?? true
    }
    
    public init(identifier: String,
                cid: Int,
                geoid: Int,
                type: String,
                et: Date,
                pushPermit: Bool) {
        self.identifier = identifier
        self.cid = cid
        self.geoid = geoid
        self.type = type
        self.et = et
        self.pp = pushPermit
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier, cid, geoid, type, et, pp
    }
}



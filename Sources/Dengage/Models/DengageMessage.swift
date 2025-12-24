
import Foundation
@objc public class DengageMessage: NSObject, Codable {
    
    public let id: String
    public let title: String?
    public let message: String?
    public let mediaURL: String?
    public let targetUrl: String?
    public let receiveDate: Date?
    public var isClicked: Bool
    public let carouselItems: [CarouselItem]?
    public let customParameters: [CustomParameters]?
    
    public var isDeleted = false
    
    required public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        isClicked = try container.decode(Bool.self, forKey: .isClicked)
        carouselItems = try? container.decode([CarouselItem].self, forKey: .carouselItems)
        let messageJson = try container.decode(String.self, forKey: .message)
        let data = Data(messageJson.utf8)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        self.title = json["title"] as? String
        self.message = json["message"] as? String
        let iosMediaUrl = json["iosMediaUrl"] as? String
        self.mediaURL = iosMediaUrl ?? json["mediaUrl"] as? String
        let iosTargetUrl = json["iosTargetUrl"] as? String
        self.targetUrl = iosTargetUrl ?? json["targetUrl"] as? String
        let receiveDateString = json["receiveDate"] as! String
        self.receiveDate = Utilities.convertDate(to: receiveDateString)
        if let customParamsArray = json["customParameters"] as? [[String: Any]] {
            let customData = try JSONSerialization.data(withJSONObject: customParamsArray, options: [])
            self.customParameters = try JSONDecoder().decode([CustomParameters].self, from: customData)
        } else {
            self.customParameters = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "smsg_id"
        case isClicked = "is_clicked"
        case message = "message_json"
        case carouselItems = "iosCarouselContent"
        case customParameters
    }
}

@objc public class DengageLocalInboxMessage: NSObject, Codable {
    
    public let id: String
    public let title: String?
    public let message: String?
    public let mediaURL: String?
    public let targetUrl: String?
    public let receiveDate: Date?
    public var isClicked: Bool
    public let carouselItems: [CarouselItem]?
    public let customParameters: [CustomParameters]?
    public var isDeleted = false
    
    public init(id: String, title: String?, message: String?, mediaURL: String?,
                targetUrl: String?, receiveDate: Date?, isClicked: Bool = false,
                carouselItems: [CarouselItem]?, customParameters : [CustomParameters]?,
                isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.message = message
        self.mediaURL = mediaURL
        self.targetUrl = targetUrl
        self.receiveDate = receiveDate
        self.isClicked = isClicked
        self.carouselItems = carouselItems
        self.customParameters = customParameters
        self.isDeleted = false
    }
}

struct InboxMessageCache: Codable {
    public var id: String
    public var isClicked: Bool
    public var isDeleted: Bool
    public var receiveDate: Date?
}

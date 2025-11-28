
import Foundation
public struct CarouselItem: Codable {
    public let id: String
    public let title: String
    public let descriptionText: String
    public let mediaUrl: String
    public let targetUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, descriptionText = "desc", mediaUrl, targetUrl
    }
}

public struct CustomParameters: Codable {
    public let key: String
    public let value: String
  
    
    enum CodingKeys: String, CodingKey {
        case key, value
    }
}

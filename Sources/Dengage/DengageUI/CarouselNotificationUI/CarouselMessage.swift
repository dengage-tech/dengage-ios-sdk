import Foundation
struct CarouselMessage: Decodable{
    let image: String?
    let title: String?
    let description: String?
    let targetUrl: String?
    
    init?(with dictionary:NSDictionary){
        image = dictionary["mediaUrl"] as? String
        title = dictionary["title"] as? String
        description = dictionary["desc"] as? String
        targetUrl = dictionary["targetUrl"] as? String
        guard image != nil && title != nil else { return nil }
    }
}

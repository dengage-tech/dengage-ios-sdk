import Foundation
struct VisitorInfo: Codable {
    let segments: [Int]?
    let tags: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case segments = "Segments"
        case tags = "Tags"
    }
}

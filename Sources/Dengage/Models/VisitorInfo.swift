import Foundation
struct VisitorInfo: Codable {
    let segments: [Int]?
    let tags: [Int]?
    let Attrs : JSON?
    
    enum CodingKeys: String, CodingKey {
        case segments = "Segments"
        case tags = "Tags"
        case Attrs = "Attrs"

    }
}

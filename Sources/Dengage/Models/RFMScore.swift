
import Foundation
public struct RFMScore: Codable {
    public let categoryId: String
    public let score: Double
    
    public init(categoryId: String, score: Double) {
        self.categoryId = categoryId
        self.score = max(min(score, 1.0), 0.0)
    }
}

public protocol RFMItemProtocol {
    var id: String { get }
    var categoryId: String { get }
    var personalized: Bool { get }
    var gender: RFMGender { get }
    var sequence: Int { get }
}

public enum RFMGender {
    case male
    case female
    case neutral
}

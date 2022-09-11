import Foundation
import UIKit
struct ContentParams: Codable {
    let position: ContentPosition
    let shouldAnimate: Bool
    let html: String?
    let maxWidth: CGFloat?
    let radius: Int?
    let marginTop: CGFloat?
    let marginBottom: CGFloat?
    let marginLeft: CGFloat?
    let marginRight: CGFloat?
    let dismissOnTouchOutside: Bool
}

enum ContentPosition: String, Codable {
    case top = "TOP"
    case middle = "MIDDLE"
    case bottom = "BOTTOM"
    case full = "FULL"
}

enum ContentType:String, Codable{
    case small = "SMALL"
    case smallButton = "SMALL_BUTTON"
    case popOutModal = "POP_OUT_MODAL"
    case fullScreen = "FULL_SCREEN"
    case html = "HTML"
}

struct ScreenDataFilter: Codable{
        let dataName: String
        let type: String
        let operatorType: ComparisonType
        let value: String
    
    enum CodingKeys: String, CodingKey {
        case operatorType = "operator"
        case dataName
        case type
        case value
    }
}

struct ScreenNameFilter: Codable{
    let operatorType: ComparisonType
    let value: [String]
    
    enum CodingKeys: String, CodingKey {
        case operatorType = "operator"
        case value
    }
}

struct DisplayCondition: Codable{
    let screenNameFilters: [ScreenNameFilter]?
    let ruleSet: RuleSet?
}
struct RuleSet: Codable {
    let logicOperator: RulesOperatorType
    let rules: [Rule]
}

struct Rule: Codable {
    let logicOperatorBetweenCriterions: RulesOperatorType
    let criterions: [Criterion]
}

struct Criterion: Codable {
    let id: Int
    let parameter: String
    let dataType: CriterionDataType
    let comparison: ComparisonType
    let values: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        parameter = try container.decode(String.self, forKey: .parameter)
        comparison = try container.decode(ComparisonType.self, forKey: .comparison)
        values = try container.decode([String].self, forKey: .values)
        dataType = (try? container.decode(CriterionDataType.self, forKey: .dataType)) ?? .TEXT
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parameter
        case dataType
        case comparison
        case values
    }
}

enum CriterionDataType: String, Codable {
    case DATETIME
    case INT
    case TEXT
    case TEXTLIST
    case INTRANGE
    case BOOL
    case VISITCOUNTPASTXDAYS
}

struct DisplayTiming: Codable{
    let delay: Int?
    let showEveryXMinutes: Int?
}

enum ComparisonType: String, Codable {
    case EQUALS
    case NOT_EQUALS
    case LIKE
    case NOT_LIKE
    case STARTS_WITH
    case NOT_STARTS_WITH
    case ENDS_WITH
    case NOT_ENDS_WITH
    case IN
    case NOT_IN
    case GREATER_THAN
    case GREATER_EQUAL
    case LESS_THAN
    case LESS_EQUAL
    case BETWEEN
}

enum RulesOperatorType: String, Codable {
    case AND
    case OR
}

enum Priority: Int, Codable {
    case high = 1
    case medium = 2
    case low = 3
}

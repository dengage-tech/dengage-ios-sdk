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
    let backgroundColor : String?
    
    enum CodingKeys: String, CodingKey {
        case position
        case shouldAnimate
        case html
        case maxWidth
        case radius
        case marginTop
        case marginBottom
        case marginLeft
        case marginRight
        case dismissOnTouchOutside
        case backgroundColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = (try? container.decode(ContentPosition.self, forKey: .position)) ?? .top
        shouldAnimate = (try? container.decode(Bool.self, forKey: .shouldAnimate)) ?? true
        html = try? container.decode(String.self, forKey: .html)
        maxWidth = try? container.decode(CGFloat.self, forKey: .maxWidth)
        radius = try? container.decode(Int.self, forKey: .radius)
        marginTop = try? container.decode(CGFloat.self, forKey: .marginTop)
        marginBottom = try? container.decode(CGFloat.self, forKey: .marginBottom)
        marginLeft = try? container.decode(CGFloat.self, forKey: .marginLeft)
        marginRight = try? container.decode(CGFloat.self, forKey: .marginRight)
        dismissOnTouchOutside = (try? container.decode(Bool.self, forKey: .dismissOnTouchOutside)) ?? true
        backgroundColor = try? container.decode(String.self, forKey: .backgroundColor)
    }
    
    init(position: ContentPosition, shouldAnimate: Bool, html: String?, maxWidth: CGFloat?, radius: Int?, marginTop: CGFloat?, marginBottom: CGFloat?, marginLeft: CGFloat?, marginRight: CGFloat?, dismissOnTouchOutside: Bool , backgroundColor : String) {
        self.position = position
        self.shouldAnimate = shouldAnimate
        self.html = html
        self.maxWidth = maxWidth
        self.radius = radius
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginLeft = marginLeft
        self.marginRight = marginRight
        self.dismissOnTouchOutside = dismissOnTouchOutside
        self.backgroundColor = backgroundColor
    }
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
    case inAppBrowser = "inAppBrowser"
    case banner = "BANNER"

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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        operatorType = try container.decode(ComparisonType.self, forKey: .operatorType)
        value = (try? container.decode([String].self, forKey: .value)) ?? []
    }
}

struct DisplayCondition: Codable{
    let screenNameFilters: [ScreenNameFilter]?
    let screenNameFilterLogicOperator : RulesOperatorType?
    let ruleSet: RuleSet?

    var hasRules: Bool {
        return !(ruleSet?.rules ?? []).isEmpty
    }
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
    let valueSource : String
    let values: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        parameter = try container.decode(String.self, forKey: .parameter)
        comparison = try container.decode(ComparisonType.self, forKey: .comparison)
        dataType = (try? container.decode(CriterionDataType.self, forKey: .dataType)) ?? .TEXT
        values = try container.decode([String].self, forKey: .values)
        valueSource = try container.decode(String.self, forKey: .valueSource)

    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parameter
        case dataType
        case comparison
        case values
        case valueSource
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
    let maxShowCount: Int?
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
    case LATER_THAN
    case LATER_EQUAL

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

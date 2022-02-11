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
        let operatorType: OperatorType
        let value: String
    
    enum CodingKeys: String, CodingKey {
        case operatorType = "operator"
        case dataName
        case type
        case value
    }
}

struct ScreenNameFilter: Codable{
    let operatorType: OperatorType
    let value: [String]
    
    enum CodingKeys: String, CodingKey {
        case operatorType = "operator"
        case value
    }
}

struct DisplayCondition: Codable{
    let screenNameFilters: [ScreenNameFilter]?
//    let screenDataFilters:[ScreenDataFilter]?
}

struct DisplayTiming: Codable{
    let triggerBy: TriggerBy
    let delay: Int?
    let showEveryXMinutes: Int?
}

enum OperatorType: String, Codable {
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
}

enum Priority: Int, Codable {
    case high = 1
    case medium = 2
    case low = 3
}

enum TriggerBy: String, Codable {
    case navigation = "NAVIGATION"
    case event = "EVENT"
}

import Foundation
import UIKit


enum StorySetFontWeight: String, Codable {
    case normal, bold
}

class StorySetHeaderTitle: Codable {
    
    static let defaultTextColor = "#1C2C48"
    static let defaultTextAlign = "left"
    static let defaultFontSize = 16
    static let defaultFontWeight = StorySetFontWeight.normal

    let textColor: String
    let textAlign: String
    let fontSize: Int
    let fontWeight: StorySetFontWeight
    
    var textUIColor: UIColor {
        return UIColor(hex: textColor) ?? UIColor.black
    }
    
    var textAlignment: NSTextAlignment {
        if textAlign.lowercased() == "right" {
            return .right
        } else if textAlign.lowercased() == "center" {
            return .center
        } else {
            return .left
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        textColor = (try? container.decode(String.self, forKey: .textColor)) ?? StorySetHeaderTitle.defaultTextColor
        textAlign = (try? container.decode(String.self, forKey: .textAlign)) ?? StorySetHeaderTitle.defaultTextAlign
        fontSize = (try? container.decode(Int.self, forKey: .fontSize)) ?? StorySetHeaderTitle.defaultFontSize
        fontWeight = (try? container.decode(StorySetFontWeight.self, forKey: .fontWeight)) ?? StorySetHeaderTitle.defaultFontWeight
    }

    init() {
        self.textColor = StorySetHeaderTitle.defaultTextColor
        self.textAlign = StorySetHeaderTitle.defaultTextAlign
        self.fontSize = StorySetHeaderTitle.defaultFontSize
        self.fontWeight = StorySetHeaderTitle.defaultFontWeight
    }

    enum CodingKeys: String, CodingKey {
        case textColor, textAlign, fontSize, fontWeight
    }
}

class StorySetHeaderCover: Codable {
    
    let size: Int
    let gap: Int
    let textColor: String
    let fontSize: Int
    let fontWeight: StorySetFontWeight
    let borderRadius: String
    let borderWidth: Int
    let fillerAngle: Int
    let fillerColors: [String]
    let passiveColor: String
    
    
    var textUIColor: UIColor {
        return UIColor(hex: textColor) ?? UIColor.black
    }
    
    var fillerUIColors: [UIColor] {
        let c = Array(fillerColors.compactMap {UIColor(hex: $0)}.prefix(2))
        return c
    }
    
    var passiveUIColor: UIColor {
        return UIColor(hex: passiveColor) ?? UIColor.lightGray
    }
    
    var borderRadiusDouble: Double {
        let cleanedBorderRadiusString = borderRadius.replacingOccurrences(of: "%", with: "")
        if let percentageValue = Double(cleanedBorderRadiusString) {
            return percentageValue / 100
        } else {
            return 0.5
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        size = (try? container.decode(Int.self, forKey: .size)) ?? 16
        gap = (try? container.decode(Int.self, forKey: .gap)) ?? 8
        textColor = (try? container.decode(String.self, forKey: .textColor)) ?? "#1C2C48"
        fontSize = (try? container.decode(Int.self, forKey: .fontSize)) ?? 12
        fontWeight = (try? container.decode(StorySetFontWeight.self, forKey: .fontWeight)) ?? .normal
        borderRadius = (try? container.decode(String.self, forKey: .borderRadius)) ?? "50%"
        borderWidth = (try? container.decode(Int.self, forKey: .borderWidth)) ?? 6
        fillerAngle = (try? container.decode(Int.self, forKey: .fillerAngle)) ?? 45
        fillerColors = (try? container.decode([String].self, forKey: .fillerColors)) ?? ["#f09433", "#dc2743"]
        passiveColor = (try? container.decode(String.self, forKey: .passiveColor)) ?? "#A0A0AD"
    }

    init() {
        self.size = 80
        self.gap = 8
        self.textColor = "#1C2C48"
        self.fontSize = 12
        self.fontWeight = .normal
        self.borderRadius = "50%"
        self.borderWidth = 6
        self.fillerAngle = 45
        self.fillerColors = ["#f09433", "#dc2743"]
        self.passiveColor = "#A0A0AD"
    }
    
    enum CodingKeys: String, CodingKey {
        case size, gap, textColor, fontSize, fontWeight, borderRadius, borderWidth, fillerAngle, fillerColors, passiveColor
    }
}

class StorySetStyling: Codable {
    
    let fontFamily: String
    let mobileOverlayColor: String
    let headerTitle: StorySetHeaderTitle
    let headerCover: StorySetHeaderCover
    
    var mobileOverlayUIColor: UIColor {
        return UIColor.clear
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontFamily = (try? container.decode(String.self, forKey: .fontFamily)) ?? ""
        mobileOverlayColor = ""
        headerTitle = (try? container.decode(StorySetHeaderTitle.self, forKey: .headerTitle)) ?? StorySetHeaderTitle()
        headerCover = (try? container.decode(StorySetHeaderCover.self, forKey: .headerCover)) ?? StorySetHeaderCover()
    }
    
    init() {
        fontFamily = ""
        mobileOverlayColor = "#fff"
        headerTitle = StorySetHeaderTitle()
        headerCover = StorySetHeaderCover()
    }
    
    
    enum CodingKeys: String, CodingKey {
        case fontFamily, mobileOverlayColor, headerTitle, headerCover
    }
}

class StorySet: Codable {
    let id: String
    let title: String
    let styling: StorySetStyling
    var covers: [StoryCover]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        styling = (try? container.decode(StorySetStyling.self, forKey: .styling)) ?? StorySetStyling()
        covers = (try? container.decode([StoryCover].self, forKey: .covers)) ?? []
    }
    
    init() {
        id = ""
        title = ""
        styling = StorySetStyling()
        covers = []
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case styling = "styling"
        case covers = "covers"
    }
    func copy() throws -> StorySet {
        let data = try JSONEncoder().encode(self)
        let copy = try JSONDecoder().decode(StorySet.self, from: data)
        return copy
    }
}



class StoryCover: Codable {
    public var storiesCount: Int {
        return coverStories.count
    }
    var coverStories: [Story] {
        return stories
    }
    
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    var shown = false
    
    let id: String
    let name: String
    let mediaUrl: String?
    let stories: [Story]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        stories = (try? container.decode([Story].self, forKey: .stories)) ?? []
        //lastPlayedSnapIndex = 0
        //isCompletelyVisible = false
        //isCancelledAbruptly = false
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case mediaUrl = "mediaUrl"
        case stories = "stories"
        //case snapsCount = "snaps_count"
        //case _snaps = "snaps"
        //case lastUpdated = "last_updated"
        //case picture = "picture"
    }
}

extension StoryCover: Equatable {
    public static func == (lhs: StoryCover, rhs: StoryCover) -> Bool {
        return lhs.id == rhs.id
    }
}

class Story: Codable {
    
    public var gradColors: [UIColor] {
        if let bgColors = bgColors {
            let c = bgColors.compactMap {UIColor(hex: $0)}
            return c
        }
        return []
    }
    
    
    public var kind: MimeType {
        switch type {
        case MimeType.image.rawValue:
            return MimeType.image
        case MimeType.video.rawValue:
            return MimeType.video
        default:
            return MimeType.unknown
        }
    }
    
    let id: String
    let name: String
    let mediaUrl: String?
    let type: String?
    let bgColors: [String]?
    let cta: StoryCta?

    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        type = try? container.decode(String.self, forKey: .type)
        bgColors = try? container.decode([String].self, forKey: .bgColors)
        cta = try? container.decode(StoryCta.self, forKey: .cta)
    }

    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case mediaUrl = "mediaUrl"
        case type = "type"
        case bgColors = "bgColors"
        case cta = "cta"
        
    }
}


class StoryCta: Codable {
    let isEnabled: Bool
    let iosLink: String
    let label: String
    let bgColor: String
    let textColor: String
    
    
    var bgUIColor: UIColor {
        return UIColor(hex: bgColor) ?? .systemBlue
    }
    
    var textUIColor: UIColor {
        return UIColor(hex: textColor) ?? .lightGray
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = (try? container.decode(Bool.self, forKey: .isEnabled)) ?? false
        iosLink = (try? container.decode(String.self, forKey: .iosLink)) ?? ""
        label = (try? container.decode(String.self, forKey: .label)) ?? ""
        bgColor = (try? container.decode(String.self, forKey: .bgColor)) ?? ""
        textColor = (try? container.decode(String.self, forKey: .textColor)) ?? ""
        
    }
    
    enum CodingKeys: String, CodingKey {
        case isEnabled, iosLink, label, bgColor, textColor
    }
    
}



public enum MimeType: String {
    case image
    case video
    case unknown
}


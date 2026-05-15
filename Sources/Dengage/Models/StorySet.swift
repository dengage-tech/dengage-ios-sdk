import Foundation
import UIKit


enum StorySetFontWeight: String, Codable {
    case normal, bold
}

enum StorySetImagePositioning: String, Codable {
    case fit
    case fill

    static func from(_ raw: String?) -> StorySetImagePositioning? {
        guard let raw = raw?.lowercased() else { return nil }
        return StorySetImagePositioning(rawValue: raw)
    }
}

class StorySetPadding: Codable {
    let left: Int
    let top: Int
    let right: Int
    let bottom: Int

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        left = (try? container.decode(Int.self, forKey: .left)) ?? 0
        top = (try? container.decode(Int.self, forKey: .top)) ?? 0
        right = (try? container.decode(Int.self, forKey: .right)) ?? 0
        bottom = (try? container.decode(Int.self, forKey: .bottom)) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case left, top, right, bottom
    }
}

class StorySetButtonTitle: Codable {
    let fontFamily: String?
    let fontWeight: StorySetFontWeight?
    let textAlign: String?
    let fontSize: Int?
    let fontColor: String?

    var fontUIColor: UIColor? {
        guard let fontColor = fontColor else { return nil }
        return UIColor(hex: fontColor)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontFamily = try? container.decode(String.self, forKey: .fontFamily)
        fontWeight = try? container.decode(StorySetFontWeight.self, forKey: .fontWeight)
        textAlign = try? container.decode(String.self, forKey: .textAlign)
        fontSize = try? container.decode(Int.self, forKey: .fontSize)
        fontColor = try? container.decode(String.self, forKey: .fontColor)
    }

    enum CodingKeys: String, CodingKey {
        case fontFamily, fontWeight, textAlign, fontSize, fontColor
    }
}

class StorySetButton: Codable {
    let backgroundColor: String?
    let borderColor: String?
    let borderRadius: Int?
    let height: Int?
    let padding: StorySetPadding?
    let fitContent: Bool?

    var backgroundUIColor: UIColor? {
        guard let backgroundColor = backgroundColor else { return nil }
        return UIColor(hex: backgroundColor)
    }

    var borderUIColor: UIColor? {
        guard let borderColor = borderColor else { return nil }
        return UIColor(hex: borderColor)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try? container.decode(String.self, forKey: .backgroundColor)
        borderColor = try? container.decode(String.self, forKey: .borderColor)
        borderRadius = try? container.decode(Int.self, forKey: .borderRadius)
        height = try? container.decode(Int.self, forKey: .height)
        padding = try? container.decode(StorySetPadding.self, forKey: .padding)
        fitContent = try? container.decode(Bool.self, forKey: .fitContent)
    }

    enum CodingKeys: String, CodingKey {
        case backgroundColor, borderColor, borderRadius, height, padding, fitContent
    }
}

class StorySetDark: Codable {
    let storyBackgroundColor: String?
    let buttonTitle: StorySetButtonTitle?
    let button: StorySetButton?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storyBackgroundColor = try? container.decode(String.self, forKey: .storyBackgroundColor)
        buttonTitle = try? container.decode(StorySetButtonTitle.self, forKey: .buttonTitle)
        button = try? container.decode(StorySetButton.self, forKey: .button)
    }

    enum CodingKeys: String, CodingKey {
        case storyBackgroundColor, buttonTitle, button
    }
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
    let iosFontFamily: String?
    let androidFontFamily: String?
    let headerTitle: StorySetHeaderTitle
    let headerCover: StorySetHeaderCover
    let storyBackgroundColor: String?
    let buttonTitle: StorySetButtonTitle?
    let button: StorySetButton?
    let dark: StorySetDark?

    var mobileOverlayUIColor: UIColor {
        return UIColor.clear
    }

    /// iOS platform font family with legacy `fontFamily` fallback.
    var effectiveFontFamily: String? {
        if let iosFontFamily, !iosFontFamily.isEmpty { return iosFontFamily }
        if !fontFamily.isEmpty { return fontFamily }
        return nil
    }

    /// Resolves story background color per the migration guide chain:
    /// `dark.storyBackgroundColor` (when dark) → `storyBackgroundColor` → `story.bgColors[0]`.
    func resolvedStoryBackgroundColor(for story: Story, isDarkMode: Bool) -> UIColor? {
        if isDarkMode, let dark = dark?.storyBackgroundColor, !dark.isEmpty {
            return UIColor(hex: dark)
        }
        if let light = storyBackgroundColor, !light.isEmpty {
            return UIColor(hex: light)
        }
        return story.bgColors?.first.flatMap { UIColor(hex: $0) }
    }

    func resolvedButtonBackgroundColor(cta: StoryCta?, isDarkMode: Bool) -> UIColor? {
        if isDarkMode, let c = dark?.button?.backgroundColor, !c.isEmpty { return UIColor(hex: c) }
        if let c = button?.backgroundColor, !c.isEmpty { return UIColor(hex: c) }
        if let c = cta?.bgColor, !c.isEmpty { return UIColor(hex: c) }
        return nil
    }

    func resolvedButtonTextColor(cta: StoryCta?, isDarkMode: Bool) -> UIColor? {
        if isDarkMode, let c = dark?.buttonTitle?.fontColor, !c.isEmpty { return UIColor(hex: c) }
        if let c = buttonTitle?.fontColor, !c.isEmpty { return UIColor(hex: c) }
        if let c = cta?.textColor, !c.isEmpty { return UIColor(hex: c) }
        return nil
    }

    func resolvedButtonBorderColor(isDarkMode: Bool) -> UIColor? {
        if isDarkMode, let c = dark?.button?.borderColor, !c.isEmpty { return UIColor(hex: c) }
        if let c = button?.borderColor, !c.isEmpty { return UIColor(hex: c) }
        return nil
    }

    func resolvedButton(isDarkMode: Bool) -> StorySetButton? {
        if isDarkMode, let d = dark?.button { return d }
        return button
    }

    func resolvedButtonTitle(isDarkMode: Bool) -> StorySetButtonTitle? {
        if isDarkMode, let d = dark?.buttonTitle { return d }
        return buttonTitle
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontFamily = (try? container.decode(String.self, forKey: .fontFamily)) ?? ""
        mobileOverlayColor = ""
        iosFontFamily = try? container.decode(String.self, forKey: .iosFontFamily)
        androidFontFamily = try? container.decode(String.self, forKey: .androidFontFamily)
        headerTitle = (try? container.decode(StorySetHeaderTitle.self, forKey: .headerTitle)) ?? StorySetHeaderTitle()
        headerCover = (try? container.decode(StorySetHeaderCover.self, forKey: .headerCover)) ?? StorySetHeaderCover()
        storyBackgroundColor = try? container.decode(String.self, forKey: .storyBackgroundColor)
        buttonTitle = try? container.decode(StorySetButtonTitle.self, forKey: .buttonTitle)
        button = try? container.decode(StorySetButton.self, forKey: .button)
        dark = try? container.decode(StorySetDark.self, forKey: .dark)
    }

    init() {
        fontFamily = ""
        mobileOverlayColor = "#fff"
        iosFontFamily = nil
        androidFontFamily = nil
        headerTitle = StorySetHeaderTitle()
        headerCover = StorySetHeaderCover()
        storyBackgroundColor = nil
        buttonTitle = nil
        button = nil
        dark = nil
    }


    enum CodingKeys: String, CodingKey {
        case fontFamily, mobileOverlayColor, iosFontFamily, androidFontFamily,
             headerTitle, headerCover, storyBackgroundColor, buttonTitle, button, dark
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
    let imagePositioning: String?
    let stories: [Story]

    var imagePositioningEnum: StorySetImagePositioning? {
        return StorySetImagePositioning.from(imagePositioning)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        imagePositioning = try? container.decode(String.self, forKey: .imagePositioning)
        stories = (try? container.decode([Story].self, forKey: .stories)) ?? []
        //lastPlayedSnapIndex = 0
        //isCompletelyVisible = false
        //isCancelledAbruptly = false
    }


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case mediaUrl = "mediaUrl"
        case imagePositioning = "imagePositioning"
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
    let imagePositioning: String?
    let duration: Int?
    let cta: StoryCta?

    var imagePositioningEnum: StorySetImagePositioning? {
        return StorySetImagePositioning.from(imagePositioning)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        type = try? container.decode(String.self, forKey: .type)
        bgColors = try? container.decode([String].self, forKey: .bgColors)
        imagePositioning = try? container.decode(String.self, forKey: .imagePositioning)
        duration = try? container.decode(Int.self, forKey: .duration)
        let decodedCta = try? container.decode(StoryCta.self, forKey: .cta)
        cta = decodedCta?.isEnabled == true ? decodedCta : nil
    }


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case mediaUrl = "mediaUrl"
        case type = "type"
        case bgColors = "bgColors"
        case imagePositioning = "imagePositioning"
        case duration = "duration"
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


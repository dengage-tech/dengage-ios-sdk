import Foundation

/// A single Inbox Channel message returned by /api/inbox/getMessages.
public struct DengageInboxChannelMessage: Decodable {

    public let id: String
    public var isRead: Bool
    public let priority: Int
    public let data: DengageInboxChannelMessageData

    enum CodingKeys: String, CodingKey {
        case id = "smsgId"
        case isRead
        case priority
        case data = "messageJson"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        isRead = (try? container.decode(Bool.self, forKey: .isRead)) ?? false
        priority = (try? container.decode(Int.self, forKey: .priority)) ?? 0
        data = try container.decode(DengageInboxChannelMessageData.self, forKey: .data)
    }
}

/// Content payload of an Inbox Channel message (the "messageJson" object).
public struct DengageInboxChannelMessageData: Decodable {

    public let title: String?
    public let message: String?
    public let imageUrl: String?
    public let ctaButtons: [DengageInboxChannelCTAButton]?
    public let isPinned: Bool
    /// Raw UTC date string as returned by the server (receiveDateUTC).
    public let receiveDate: String?
    /// Opaque token that must be echoed back in the messageDetails field of
    /// every /inbox/events request for this message.
    public let messageDetails: String?

    public var receiveDateValue: Date? {
        Utilities.convertDate(to: receiveDate)
    }

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case imageUrl
        case ctaButtons
        case isPinned
        case receiveDate = "receiveDateUTC"
        case messageDetails
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        message = try? container.decode(String.self, forKey: .message)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        ctaButtons = try? container.decode([DengageInboxChannelCTAButton].self, forKey: .ctaButtons)
        isPinned = (try? container.decode(Bool.self, forKey: .isPinned)) ?? false
        receiveDate = try? container.decode(String.self, forKey: .receiveDate)
        messageDetails = try? container.decode(String.self, forKey: .messageDetails)
    }
}

public struct DengageInboxChannelCTAButton: Decodable {
    public let buttonId: String?
    public let label: String?
    public let iosDeeplink: String?
    public let androidDeeplink: String?
    public let webUrl: String?
}

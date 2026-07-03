import Foundation

/// Event types accepted by the Inbox Channel /inbox/events endpoint.
/// The raw value is the short code that gets sent to the server.
public enum DengageInboxChannelEventType: String {
    case impression = "IM"
    case open = "OP"
    case click = "CL"
    case delete = "DT"
}

/// A single Inbox Channel interaction that the host app wants to report.
/// Multiple events can be sent together (bulk) in one /inbox/events request.
public struct DengageInboxChannelEvent {

    public let eventType: DengageInboxChannelEventType
    public let messageId: String
    public let messageDetails: String?

    /// - Parameters:
    ///   - eventType: one of impression (IM), open (OP), click (CL), delete (DT)
    ///   - messageId: the `DengageInboxChannelMessage.id` (smsgId) the event belongs to
    ///   - messageDetails: the opaque token from `DengageInboxChannelMessageData.messageDetails`
    public init(eventType: DengageInboxChannelEventType,
                messageId: String,
                messageDetails: String?) {
        self.eventType = eventType
        self.messageId = messageId
        self.messageDetails = messageDetails
    }
}

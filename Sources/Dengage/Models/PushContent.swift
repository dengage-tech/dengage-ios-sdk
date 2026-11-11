
import Foundation
import UserNotifications

struct PushContent: Decodable{
    let messageSource: String?
    let targetUrl: String?
    let messageId: Int?
    let messageDetails: String?
    let transactionId: String?
    let actionButtons: [PushAction]?
    let title: String?
    let subtitle: String?
    let urlImageString: String?
    let addToInbox: Bool?
    let muted: Bool?
    let notificationIcon: String?
    let aps: APS?

    struct PushAction: Decodable{
        let id: String?
        let targetUrl: String?
        let text: String?
    }

    /// Never throws, so an unexpected `aps` value cannot make the whole `PushContent` fail to decode.
    struct APS: Decodable {
        let badge: Int?
        let isIncrementalBadge: Bool

        private enum CodingKeys: String, CodingKey {
            case badge, isIncrementalBadge
        }

        init(from decoder: Decoder) {
            let container = try? decoder.container(keyedBy: CodingKeys.self)
            badge = container?.lenientInt(forKey: .badge)
            isIncrementalBadge = container?.lenientBool(forKey: .isIncrementalBadge) ?? false
        }
    }
}

private extension KeyedDecodingContainer {
    /// Accepts 1/0, true/false and their string forms; the panel sends `isIncrementalBadge` as a number.
    func lenientBool(forKey key: Key) -> Bool? {
        if let value = try? decode(Bool.self, forKey: key) { return value }
        if let value = try? decode(Int.self, forKey: key) { return value != 0 }
        if let value = try? decode(String.self, forKey: key) {
            return ["1", "true", "yes"].contains(value.lowercased())
        }
        return nil
    }

    func lenientInt(forKey key: Key) -> Int? {
        if let value = try? decode(Int.self, forKey: key) { return value }
        if let value = try? decode(String.self, forKey: key) { return Int(value) }
        return nil
    }
}

extension UNNotificationContent {
    var message: PushContent? {
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return nil }
        return try? JSONDecoder().decode(PushContent.self, from: data)
    }
}

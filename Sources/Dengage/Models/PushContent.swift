
import Foundation
import UserNotifications

struct PushContent: Decodable{
    let messageSource: String?
    let targetURL: String?
    let messageId: Int?
    let messageDetails: String?
    let transactionId: String?
    let actionButtons: [PushAction]?
    let title: String?
    let subtitle: String?
    let urlImageString: String?
    
    struct PushAction: Decodable{
        let id: String?
        let targetURL: String?
        let text: String?
    }
}

extension UNNotificationContent {
    var message: PushContent? {
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return nil }
        return try? JSONDecoder().decode(PushContent.self, from: data)
    }
}

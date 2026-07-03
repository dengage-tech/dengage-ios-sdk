import Foundation
import UserNotifications
import Dengage

/// Offline trigger anında cache'lenen `OfflinePushContent` ile local notification gösterir (K10).
/// Network gerekmez — title/body/deeplink fence ile birlikte cache'lenmiştir.
final class LocalNotificationFirer {

    func fire(content: OfflinePushContent, fenceId: Int, campaignId: Int?) {
        let title = content.title ?? ""
        let body = content.body ?? ""
        if title.isEmpty && body.isEmpty {
            Logger.log(message: "LocalNotificationFirer -> empty content, skipping")
            return
        }

        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.body = body
        notification.sound = .default
        var userInfo: [String: Any] = ["dengage_geofence_fence_id": fenceId]
        if let campaignId = campaignId { userInfo["dengage_geofence_campaign_id"] = campaignId }
        if let deepLink = content.deepLink { userInfo["targetUrl"] = deepLink }
        if let customParams = content.customParams {
            for (k, v) in customParams { userInfo[k] = v }
        }
        notification.userInfo = userInfo

        let identifier = "dengage_geofence_\(campaignId ?? fenceId)"
        let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.log(message: "LocalNotificationFirer_ERROR", argument: error.localizedDescription)
            } else {
                Logger.log(message: "LocalNotificationFirer -> fired (fence=\(fenceId))")
            }
        }
    }
}

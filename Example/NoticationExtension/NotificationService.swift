import UserNotifications
import Dengage
class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if #available(iOS 15.0, *) {
            bestAttemptContent?.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        let bsif = "_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_"
        
        // egemen-ios-dev-test
        let test = "uCwvO25ucX34F1_p_l_DOZjW55uri_p_l_sMxg0rJpbsJ4d8We00Be_p_l_eJMb5R3auwdYD6rUuM7M5NftuA5NNu7mV2H_s_l_rGa9Z6y3EqaV_p_l_PTgPyyimmbtDw237bhBjPEpiz5TXzXLHlTD8OEzGXOJ6r65xtOdE0Q_e_q__e_q_"
        
        //let option = DengageOptions(disableOpenURL: false, badgeCountReset: true, disableRegisterForRemoteNotifications: false, enableGeofence: true)
        let option = DengageOptions(disableOpenURL: false, badgeCountReset: true, disableRegisterForRemoteNotifications: false)

        
        //Dengage.start(apiKey: bsif, launchOptions: [:], dengageOptions: option)
        //let deviceToken = Dengage.getDeviceToken()
        Dengage.didReceiveNotificationRequest(bestAttemptContent, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

import UIKit
import UserNotifications
import UserNotificationsUI
import Dengage
@objc(NotificationViewController)

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    let carouselView = DengageNotificationCarouselView.create()
    
    func didReceive(_ notification: UNNotification) {
        let bsif = "_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_"
        //dev-app.dengage.com: egemen-ios-dev-sandbox-test
        let test = "7xWJ4ZN3MBF8WueuygcslkO4tbCn_s_l_CzDrTJJxVChxVH2usO_s_l_w310K_s_l_KphZVJD97FUCiSjaaysA51_s_l_GO_s_l_S7YGzD_p_l_RUuYwqzNBI5_p_l_i7Qml_p_l_rOC_p_l_7W_s_l_Nm3pGbCqAgqecsthxiH16a13SJDJALI50mgCHQ_e_q__e_q_"
        
        let option = DengageOptions(disableOpenURL: false, badgeCountReset: true, disableRegisterForRemoteNotifications: true)
        Dengage.start(apiKey: test, application: nil, launchOptions: [:], dengageOptions: option)
        Dengage.setLog(isVisible: true)
        
        Dengage.setDevelopmentStatus(isDebug: true)
        carouselView.didReceive(notification)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        carouselView.didReceive(response, completionHandler: completion)
    }
    
    override func loadView() {
        self.view = carouselView
    }
}

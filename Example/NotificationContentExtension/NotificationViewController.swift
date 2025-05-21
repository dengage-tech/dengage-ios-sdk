import UIKit
import UserNotifications
import UserNotificationsUI
import Dengage
@objc(NotificationViewController)

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    let carouselView = DengageNotificationCarouselView.create()
    
    func didReceive(_ notification: UNNotification) {
        
        
        //app.dengage.com: priya ios testflight
        let bfsi_testflight = "A80DAdoQta4rOzTlSbRO2_s_l_xJaTDNpZAGZnWS94zp8BpmXugFZMwtJFwUVsW6Ny2xGNMvqGpBjPrqIL8dAcpnsMFhDxo5Qm105bbkjg8E3D7LckvR1to4iLVitGr7lNijV4uXX2i47UqsEYi1I2Ptzg_e_q__e_q_"

        //app.dengage.com: Priya iOS Test New SDk
        let bfsi_sandbox = "_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_"
        
        //dev-app.dengage.com: egemen-ios-dev-test
        let test_testflight = "g9XU6x_p_l__p_l__s_l_AnsEBUgVC4F5uGQHpg7PFa1PIfxtOZG4bku0AxtvUMjBqF_s_l_Q0x37TkR1_p_l_vV_s_l_mYwcKHWB7YPNjAClyPViBqp1iRw3zqbtCBZlnapkD7pLGTGMKHGvPreNWf5kPPjZC0og67hsTfSkYBLfA_e_q__e_q_"
        
        //dev-app.dengage.com: egemen-ios-dev-sandbox-test
        let test_sandbox = "7xWJ4ZN3MBF8WueuygcslkO4tbCn_s_l_CzDrTJJxVChxVH2usO_s_l_w310K_s_l_KphZVJD97FUCiSjaaysA51_s_l_GO_s_l_S7YGzD_p_l_RUuYwqzNBI5_p_l_i7Qml_p_l_rOC_p_l_7W_s_l_Nm3pGbCqAgqecsthxiH16a13SJDJALI50mgCHQ_e_q__e_q_"
        
        DengageLocalStorage.shared.setAppGroupsUserDefaults(appGroupName: "group.com.dengage.Example.dengage")
        Dengage.setIntegrationKey(key: test_sandbox)
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

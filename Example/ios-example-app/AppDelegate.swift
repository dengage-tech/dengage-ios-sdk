import UIKit
import Dengage


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // dev
        //"YF2_p_l_NN4KRoXaSDN4BTp4Nr4K03bE00JoMQnbUh3HMadY_p_l_n30hGw_p_l_PhKypwxdE5kATWY_s_l_jKlrRHTSOAC5rC4ptsk0w0BwE94H8N940O79fIGjXwL23cnAb5RjA9432isGw3gv4J4e3J5_s_l_lRo3_s_l__p_l_IQaw_e_q__e_q_"
        // us
        //hVt7KpAkwbJXRO_s_l_p6To_p_l_9lIaG3HyOp2pYtPwnpzML4D5AGhv88nXj4tdG1MJOsDk0rE072ewsGRGyxdt7V7UAEO_s_l_mN01MRl6iQDiCbx_s_l_ndwua1_s_l_5KL8MXzpLiGbjvFol
        
        //BSIF
       //_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_
        
        Dengage.setLog(isVisible: true)


        Dengage.start(apiKey: "_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_", application: application, launchOptions: launchOptions, dengageOptions: DengageOptions())
        
        UNUserNotificationCenter.current().delegate = self
       
      
        
        Dengage.setDevelopmentStatus(isDebug: true)
        
        Dengage.set(deviceId: "priya@19281426099785658767678464374667236473673246236237673246.jkjkkj")
        
        Dengage.promptForPushNotifications { isUserGranted in
            
            
        }
        
        Dengage.handleNotificationActionBlock { notificationResponse in
            
            
            print(notificationResponse.notification.request.content.userInfo)
        }
        
     //  Dengage.setLanguage(language: "eu")
        
//        Dengage.inAppLinkConfiguration(deeplink: "pazarama.app://")
//        
//        
      //  Dengage.set(contactKey: "sdcdsdd")
//        
//        Dengage.setContactKey(contactKey: "rrrrr")
//               
//        
        
      // Dengage.setPartnerDeviceId(adid: "783278iydukjqe")
//
//        
//        Dengage.sendDeviceIdToServer(route: "V1/dengage/sync/mobile/customerData", token: "cti234bdj1ev4u4c0pk2l1z370vmgtah")
        
 
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        Dengage.register(deviceToken: deviceToken)
    }

    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
        print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(userInfo: userInfo))")
        
        Dengage.didReceive(with: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void){
        
        print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(response: response))")

        
        Dengage.didReceivePush(center, response, withCompletionHandler: completionHandler)
    }

    final func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Dengage.didReceive(with: notification.request.content.userInfo)
        completionHandler([.alert, .sound, .badge])
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //dengage://inboxmessage/?dn_send_id=13097&dn_channel=push
    
        print("UIApplication.OpenURLOptionsKey \(url.host ?? "")")
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("UIApplication.OpenURLOptionsKey \(url.host ?? "")")
        
        return true
    }
}

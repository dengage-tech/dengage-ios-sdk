import UIKit
import Dengage


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // dev
        //"2OVaZb0_s_l_h7R2Zhuu_p_l_ulM_p_l_08v_p_l_E7WGT_p_l_Pr1O_p_l_Y7pWZ7cpT2SJD8_s_l_u53v0O8_s_l__s_l_EXomKP84Tx1NVKJ7dB8h64j2lxDXxH_p_l_tNnOpsB672ZlXU6lf3MhSovvLPOgABYAMkMhEzc7ipjndOn_p_l_aeXA5qyDaFA_e_q__e_q_"
        // us
        //hVt7KpAkwbJXRO_s_l_p6To_p_l_9lIaG3HyOp2pYtPwnpzML4D5AGhv88nXj4tdG1MJOsDk0rE072ewsGRGyxdt7V7UAEO_s_l_mN01MRl6iQDiCbx_s_l_ndwua1_s_l_5KL8MXzpLiGbjvFol
        
        //BSIF
       //_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_
        
        //demo
//        APw9RpIb8xEEVjxNfN8h_s_l_Xknsll3fFa88j6DjEYlo9ZncoMxrLXr2wZcafHPDlAllnV23eAG8sUr9Co4rfs5D67VMc9o_p_l_ovvhwCKF2zTjPh4at_p_l_OZWBxYqhAq2eop_s_l_VOnskTofJnsvTDJ7n5ZR0tzQ_e_q__e_q_


        
        Dengage.setLog(isVisible: true)

        let dengageOptions = DengageOptions.init(disableOpenURL: false)

        Dengage.start(apiKey: "_s_l_gJiLHWiLdjpYMf4jlhRN2wemFgwft4oIy_s_l_QpEcwPBfQWNyC22E397SlnX2Rt51QPv4fWH9c_s_l_M7yFH74iPSsUBgzpc6iUsIFw3waNyMau1xttwfOwQ9oJ9PZyBseS30U34vo1bSElJSrhGrwIkCUCw_e_q__e_q_", application: application, launchOptions: launchOptions, dengageOptions: dengageOptions)
        
        UNUserNotificationCenter.current().delegate = self
       
        Dengage.setDevelopmentStatus(isDebug: true)
                
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
        
        Dengage.set(permission: true)
        
        if let url = launchOptions?[.url] as? URL {
               // Handle the URL here
               print("Launch with URL: \(url)")
           }
        
 
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
        
        
       // print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(userInfo: userInfo))")
        
        Dengage.didReceive(with: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void){
        
      //  print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(response: response))")

        
        Dengage.didReceivePush(center, response, withCompletionHandler: completionHandler)
    }

    final func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Dengage.didReceive(with: notification.request.content.userInfo)
        completionHandler([.alert, .sound, .badge])
    }
    
   
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("UIApplication.OpenURLOptionsKey \(url.host ?? "")")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return false }

        if components.host == "dengage://" {
            
            
            if #available(iOS 13.0, *) {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    
                    sd.window?.rootViewController?.navigationController?.pushViewController(ContactKeyViewController(), animated: true)
                }
            } else {
                // Fallback on earlier versions
            }
            
            
        }
        return true
    }

}

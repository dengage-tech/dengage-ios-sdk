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
        
        //op
//        ISF1SkvnJTgrVE1NWgfsF3TU_p_l_I3t_s_l_uVF7i_s_l_C1EGES0rB0HcToRYRCY_s_l_ioPhbsdIY22SfKjLKK8F5x2cZgtCvLILmbZH2fy6tNQD1BqKHyQZ2VZhExl7_s_l_jRes6Sqf_p_l_cI3


        //op2
//        2YtmAkaGNiiY4u3CN_s_l_d2oowwIa2YjMDnEnk7g7Dh5MFcUdkV_s_l_H0ECdHEeZvK_s_l_pNkNOJ2b3XMNkvBcZ43UvPW2ULSLkyNLGXFoCR_p_l_xVxYr4x_s_l_ypeE_p_l_XcbwtifyFyLBQVB
        

        
        
        let option = DengageOptions(disableOpenURL: false, badgeCountReset: true, disableRegisterForRemoteNotifications: false, enableGeofence: true)
        
        Dengage.start(apiKey: "o5r8xJa8eyBUGSmwXdskiIx0Um1oacEGoowX1_p_l_chY5_p_l_cVGTBC4m4jWgohN6vS3X3FG1cUbmToIAyVQfXAFDShKgqChrmLTMwnae_s_l_mqgXMNgkIG2gsAkOidM1znE1lIypsr_p_l_p9VrPR6OKSDdvF_s_l_3krw_e_q__e_q_", application: application, launchOptions: [:], dengageOptions: option)
                
        UNUserNotificationCenter.current().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = RootViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        Dengage.promptForPushNotifications { isUserGranted in
            
            
        }
        Dengage.setLog(isVisible: true)
        
        Dengage.setDevelopmentStatus(isDebug: true)
        
        Dengage.handleNotificationActionBlock { notificationResponse in
            
            print(notificationResponse)
        }
                
       // Dengage.set(deviceId: "123456")
        
       // Dengage.syncSDK()
        
       
       
        
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Dengage.register(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(userInfo: userInfo))")

        
        Dengage.didReceive(with: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
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

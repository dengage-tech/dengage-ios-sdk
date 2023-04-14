import UIKit
import Dengage


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        _p_l_AvDJy5os_s_l_CWOx_p_l_wSaoGA4BtNDjxnqO_p_l_Go_p_l_WSu6VdnlIUNi1Yb7C9FhsfeAbwUg9uH9vLXaG_s_l_0UqGh2yBjRYY6RK15NahUFP9J8JI1D6FcphiLPskqz8HqUKRAxvG_p_l_Ks7g0_p_l_LNkG97N_p_l_oc3PjTegYw_e_q__e_q_
        
        //"TvSgLCc7Q_p_l_evpAK_p_l_MNdkk1fRoucLOyMyV2z2FN4_p_l_XXfZeriWBjg8KcDnAbCaZ2AOZiV_p_l_x5OvwvH2c9Kd2Ox7_s_l_HVMwtxCgqmonYKTIRTFP_p_l_BECGbjSLr_s_l_keumauwEqB_p_l_eU_p_l_RQ1FEYI5qMzHqg1NyPPA_e_q__e_q_"
        
        Dengage.start(apiKey: "hVt7KpAkwbJXRO_s_l_p6To_p_l_9lIaG3HyOp2pYtPwnpzML4D5AGhv88nXj4tdG1MJOsDk0rE072ewsGRGyxdt7V7UAEO_s_l_mN01MRl6iQDiCbx_s_l_ndwua1_s_l_5KL8MXzpLiGbjvFol", application: application, launchOptions: launchOptions, dengageOptions: DengageOptions())
        UNUserNotificationCenter.current().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = RootViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
      
        Dengage.setLog(isVisible: true)
        
        Dengage.promptForPushNotifications { isUserGranted in
            
            
        }
        
//        Dengage.inAppLinkConfiguration(deeplink: "pazarama.app://")
//        
//        
//        Dengage.set(contactKey: "rtrtyr")
//        
//        Dengage.setContactKey(contactKey: "rrrrr")
//               
//        
//        Dengage.set(deviceId: "kkkhjghfg")
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

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Dengage.didReceive(with: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void){
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

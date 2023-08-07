import UIKit
import Dengage


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // dev
        //"EpuJhCp_p_l_pbbW6PotMSlkGvLj3D7RC92vlqsjjFc356SbzZcAWktjxs3YxEd9_p_l_FHl0rjYn7P5Qt9f7o7gb5DQTfzON8g5AyFvH0_s_l_oRbo2OsF_s_l_siYlbb9hor0ksG6Q4b52lLS9ijP5mE7PZyisi_s_l_uH9w_e_q__e_q_"
        // us
        //xk_s_l__s_l_n38df8Skfi0ldgf4mPxACJpkMOBU5YyrSkKMENx_p_l_YWIZJ2wvlCfcTzgozezJdHqokHGmiJIs_s_l_wwsa7iI8fUqdqX0rCU50ZZvJlnKQjmIAvfew4qtAyUOfkUWAna5
        
        Dengage.start(apiKey: "EpuJhCp_p_l_pbbW6PotMSlkGvLj3D7RC92vlqsjjFc356SbzZcAWktjxs3YxEd9_p_l_FHl0rjYn7P5Qt9f7o7gb5DQTfzON8g5AyFvH0_s_l_oRbo2OsF_s_l_siYlbb9hor0ksG6Q4b52lLS9ijP5mE7PZyisi_s_l_uH9w_e_q__e_q_", application: application, launchOptions: launchOptions, dengageOptions: DengageOptions())
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
        
        Dengage.setDevelopmentStatus(isDebug: true)
        
        Dengage.promptForPushNotifications { isUserGranted in
            
            
        }
        
        Dengage.inAppLinkConfiguration(deeplink: "pazarama.app://")
//        
//        
//        Dengage.set(contactKey: "rtrtyr")
//        
//        Dengage.setContactKey(contactKey: "rrrrr")
//               
//        
       Dengage.set(deviceId: "kkkhjghfg")
        
      //  Dengage.setPartnerDeviceId(adid: <#T##String?#>)
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
        Dengage.didReceive(with: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void){
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

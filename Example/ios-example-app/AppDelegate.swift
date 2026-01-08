import UIKit
import UserNotifications
import Dengage
import DengageGeofence
import WidgetKit
import ActivityKit

// MARK: - Globals
var liveActivityPushTokenString = ""

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    var window: UIWindow?
    
    // MARK: - Lifecycle
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: RootViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        if #available(iOS 13.0, *) { window?.overrideUserInterfaceStyle = .light }
        UNUserNotificationCenter.current().delegate = self
        configureDengage(application: application)
        return true
    }
}

// MARK: - Configuration
private extension AppDelegate {
    
    func configureDengage(application: UIApplication) {
        // MARK: API Keys
        // app.dengage.com: priya ios testflight
        // let bfsi_testflight = "A80DAdoQta4rOzTlSbRO2_s_l_xJaTDNpZAGZnWS94zp8BpmXugFZMwtJFwUVsW6Ny2xGNMvqGpBjPrqIL8dAcpnsMFhDxo5Qm105bbkjg8E3D7LckvR1to4iLVitGr7lNijV4uXX2i47UqsEYi1I2Ptzg_e_q__e_q_"
        //app.dengage.com: Priya-iOS-Sandbox
        // let bfsi_sandbox = "QE8P6DlqusV4g21EnkO3dk8NVjmqzlRjoLouXpHVTFehUa3wToBlADQqLpacXQ1ySqD3VJVM9Zx9JXsHHasCrqT5s4_s_l_K3wSMc_s_l_S3BZDrs6gJo_p_l_DdSirLDnvHQHC51gcEkYbZrxAjhzgo6kuYQIsfIg_e_q__e_q_"
        //dev-app.dengage.com: egemen-ios-dev-test
        //let test_testflight = "g9XU6x_p_l__p_l__s_l_AnsEBUgVC4F5uGQHpg7PFa1PIfxtOZG4bku0AxtvUMjBqF_s_l_Q0x37TkR1_p_l_vV_s_l_mYwcKHWB7YPNjAClyPViBqp1iRw3zqbtCBZlnapkD7pLGTGMKHGvPreNWf5kPPjZC0og67hsTfSkYBLfA_e_q__e_q_"
        //dev-app.dengage.com: egemen-ios-dev-sandbox-test
        let test_sandbox = "7xWJ4ZN3MBF8WueuygcslkO4tbCn_s_l_CzDrTJJxVChxVH2usO_s_l_w310K_s_l_KphZVJD97FUCiSjaaysA51_s_l_GO_s_l_S7YGzD_p_l_RUuYwqzNBI5_p_l_i7Qml_p_l_rOC_p_l_7W_s_l_Nm3pGbCqAgqecsthxiH16a13SJDJALI50mgCHQ_e_q__e_q_"
        
        let apiUrlConfig = ApiUrlConfiguration(
            denEventApiUrl: "https://dev-push.dengage.com",
            denPushApiUrl: "https://dev-push.dengage.com",
            denInAppApiUrl: "https://dev-push.dengage.com",
            denGeofenceApiUrl: "https://dev-push.dengage.com/geoapi/",
            fetchRealTimeInAppApiUrl: "https://dev-inapp.lib.dengage.com",
            denLiveActivityApiUrl: "http://localhost:3000" // Local test server for Live Activities
        )
        
        let options = DengageOptions(
            disableOpenURL: false,
            badgeCountReset: true,
            disableRegisterForRemoteNotifications: false,
            appGroupsKey: "group.com.dengage.Example.dengage",
            localInboxManager: false
        )
        
        Dengage.setLog(isVisible: true)
        Dengage.setDevelopmentStatus(isDebug: true)
        Dengage.start(
            apiKey: test_sandbox,
            application: application,
            launchOptions: [:],
            dengageOptions: options,
            apiUrlConfiguration: apiUrlConfig
        )
        Dengage.promptForPushNotifications { isUserGranted in
            print("Dengage.promptForPushNotifications isUserGranted: \(isUserGranted)")
        }
        Dengage.inAppLinkConfiguration(deeplink: "dengagelink://")
        Dengage.handleNotificationActionBlock { response in
            print(response)
        }
        
        /*
         guard let sdkParameters = Dengage.getSdkParameters() else { return }
         for mapping in sdkParameters.eventMappings {
         print(mapping.eventTableName ?? "None")
         guard let defs = mapping.eventTypeDefinitions else { continue }
         for def in defs {
         print(def.eventType ?? "None")
         guard let attrs = def.attributes else { continue }
         for attr in attrs {
         print(attr.name ?? "None")
         print(attr.tableColumnName ?? "None")
         print(attr.dataType ?? "None")
         }
         }
         }
         */
        
        DengageGeofence.startGeofence()
        
        // Initialize Live Activities
        if #available(iOS 16.1, *) {
            DengageLiveActivityController.start()
        }
    }
}

// MARK: - Push Registration
extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Dengage.register(deviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
        print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(userInfo: userInfo))")
        Dengage.didReceive(with: userInfo)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("TEST SILENT PUSH VARIABLE \(Dengage.isPushSilent(response: response))")
        Dengage.didReceivePush(center, response, withCompletionHandler: completionHandler)
    }
}

// MARK: - URL Handling
extension AppDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("UIApplication.OpenURLOptionsKey \(url.host ?? "")")
        return true
    }
}

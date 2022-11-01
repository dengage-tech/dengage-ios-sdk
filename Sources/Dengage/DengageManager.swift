import Foundation
import UserNotifications
import UIKit
public class DengageManager {

    var config: DengageConfiguration
    var application: UIApplication?
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var options: DengageOptions?
    var threadContainer = ThreadSafeContainer(label: "DengageMainLock")
    var apiClient: DengageNetworking
    var eventManager: DengageEventProtocolInterface
    var sessionManager: DengageSessionManagerInterface
    var inboxManager: DengageInboxManagerInterface
    var inAppManager: DengageInAppMessageManagerInterface
    var notificationManager: DengageNotificationManagerInterface
    var dengageRFMManager: DengageRFMManager
    
    var testPageWindow: UIWindow?
    
    init(with apiKey: String,
         application: UIApplication,
         launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
         dengageOptions options: DengageOptions) {
        
        config = DengageConfiguration(integrationKey: apiKey, options: options)
        
        // keychain ve userdefaults da daha once kayit edilenler confige eklenmiyor
        self.application = application
        self.launchOptions = launchOptions
        self.options = options
        self.apiClient = DengageNetworking(config: config)
        self.sessionManager = DengageSessionManager()
        self.inboxManager = DengageInboxManager(config: config, service: apiClient)
        self.eventManager = DengageEventManager(config: config,
                                                service: apiClient,
                                                sessionManager: sessionManager)
        self.inAppManager = DengageInAppMessageManager.init(config: config,
                                                            service: apiClient)
        
        self.notificationManager = DengageNotificationManager(config: config,
                                                              service: apiClient,
                                                              eventManager: eventManager,
                                                              launchOptions: launchOptions)
        self.dengageRFMManager = DengageRFMManager()
        
        sync()
        getSDKParams()
    }
}

extension DengageManager {
    func register(_ deviceToken: Data) {
        Logger.log(message: "Register Token")
        var token = "";
        if #available(iOS 13.0, *){
            token = deviceToken.map { String(format: "%02x", $0) }.joined()
        } else{
            token = deviceToken.map { data in String(format: "%02.2hhx", data) }.joined()
        }
        
        threadContainer.write { [weak self] in
            self?.config.set(token: token)
            Logger.log(message: "sync Started token", argument: token)
        }
        
        Dengage.syncSubscription()
    }
    
    func set(_ contactKey: String?){
        let previous = self.config.getContactKey()
        if previous != contactKey {
            let newKey = (contactKey?.isEmpty ?? true) ? nil : contactKey
            DengageLocalStorage.shared.set(value: newKey, for: .contactKey)
            Dengage.syncSubscription()
        }
    }
    
    func set(_ deviceId: String){
        let previous = self.config.applicationIdentifier
        if previous != deviceId {
            self.config.set(deviceId: deviceId)
            Dengage.syncSubscription()
        }
    }
    
    func set(_ permission: Bool){
        let previous = self.config.permission
        if previous != permission {
            self.config.set(permission: permission)
            Dengage.syncSubscription()
        }
    }
    
    func sync(){
        eventManager.eventSessionStart()
        let request = MakeSubscriptionRequest(config: config)
        Logger.log(message: "sync Started")
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                Logger.log(message: "sync success")
            case .failure(_):
                Logger.log(message: "sync error")
            }
        }
    }
    
    func set(_ tags: [TagItem]){
        guard let remoteConfig = config.remoteConfiguration else { return }
        guard let accountName = remoteConfig.accountName else { return }
        let request = TagsRequest(accountName: accountName,
                                  key: config.applicationIdentifier,
                                  tags: tags)
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                break
            case .failure:
                Logger.log(message: "SDK SetTags Method Error")
            }
        }
    }
}

//MARK: - Private
extension DengageManager {
    private func getSDKParams() {
        Logger.log(message: "getSDKParams Started")

        if let date = (DengageLocalStorage.shared.value(for: .lastFetchedConfigTime) as? Date),
           let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour,
           diff > SDKPARAMS_FETCH_INTERVAL {
            fetchSDK()
        }else if (DengageLocalStorage.shared.value(for: .lastFetchedConfigTime) as? Date) == nil {
            fetchSDK()
        }
        
        inAppManager.fetchInAppMessages()
    }
    
    private func fetchSDK(){
        Logger.log(message: "fetchSDK Started")
        let request = GetSDKParamsRequest(integrationKey: config.integrationKey,
                                          deviceId: config.applicationIdentifier)
        apiClient.send(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DengageLocalStorage.shared.saveConfig(with: response)
                DengageLocalStorage.shared.set(value: Date(), for: .lastFetchedConfigTime)
                self.inAppManager.fetchInAppMessages()
                self.inAppManager.fetchInAppExpiredMessages()

            case .failure:
                Logger.log(message: "SDK PARAMS Config fetchin failed")
            }
        }
    }
    
    func dengageDeviceIdSendToServer(token : String){
        Logger.log(message: "dengageDeviceIdSendToServer Started")
        let request = DeviceIdApiRequest.init(device_id:config.applicationIdentifier, token: token)
        apiClient.send(request: request) { result in
            switch result {
            case .success(let response):
                
                Logger.log(message: "dengageDeviceIdSendToServer \(response)")
                
            case .failure:
                Logger.log(message: "SDK PARAMS Config fetchin failed")
            }
        }
    }
}

@objc public class DengageOptions: NSObject {
    let disableOpenURL: Bool
    let badgeCountReset: Bool
    let disableRegisterForRemoteNotifications: Bool
    public init(disableOpenURL: Bool = false,
                badgeCountReset: Bool = false,
                disableRegisterForRemoteNotifications: Bool = false) {
        self.disableOpenURL = disableOpenURL
        self.badgeCountReset = badgeCountReset
        self.disableRegisterForRemoteNotifications = disableRegisterForRemoteNotifications
    }
}

extension DengageOptions:Encodable{}

extension DengageManager {
    func showTestPage(){
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        testPageWindow = UIWindow(frame: frame)
        testPageWindow?.rootViewController = UINavigationController(rootViewController: TestPageViewController())
        testPageWindow?.windowLevel = UIWindow.Level(rawValue: 2)
        testPageWindow?.makeKeyAndVisible()
    }
}

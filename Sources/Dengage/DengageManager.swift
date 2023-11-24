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
    var inboxManager: DengageInboxManager
    var inAppManager: DengageInAppMessageManager
    var notificationManager: DengageNotificationManagerInterface
    var dengageRFMManager: DengageRFMManager
    var testPageWindow: UIWindow?
    
    init(with apiKey: String,
         application: UIApplication?,
         launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
         dengageOptions options: DengageOptions) {
        
        config = DengageConfiguration(integrationKey: apiKey, options: options)
        
        // keychain ve userdefaults da daha once kayit edilenler confige eklenmiyor
        self.application = application
        self.launchOptions = launchOptions
        self.options = options
        self.apiClient = DengageNetworking(config: config)
        self.sessionManager = DengageSessionManager(config: config)
        self.inboxManager = DengageInboxManager(config: config, service: apiClient)
        self.eventManager = DengageEventManager(config: config,
                                                service: apiClient,
                                                sessionManager: sessionManager)
        self.inAppManager = DengageInAppMessageManager.init(config: config,
                                                            service: apiClient,
                                                            sessionManager: sessionManager)

        self.notificationManager = DengageNotificationManager(config: config,
                                                              service: apiClient,
                                                              eventManager: eventManager,
                                                              launchOptions: launchOptions)
        self.dengageRFMManager = DengageRFMManager()
        
        sync()
        
        getSDKParams()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: {
            
            self.inAppManager.getVisitorInfo()
            
        })
     
        
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
        
        let previous = self.config.deviceToken
        if previous != token {
            self.config.set(token: token)
            Logger.log(message: "sync Started token", argument: token)
            Dengage.syncSubscription()
        }
        
    }
    
    func set(_ contactKey: String?){
        let previous = self.config.getContactKey()
        if previous != contactKey {
            let newKey = (contactKey?.isEmpty ?? true) ? nil : contactKey
            DengageLocalStorage.shared.set(value: newKey, for: .contactKey)
            inboxManager.inboxMessages.removeAll()
            inboxManager.inboxMessages = []
            _ = sessionManager.createSession(force: true)
            resetUsageStats()
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
            
        let integrationKeySubscription = DengageLocalStorage.shared.value(for: .integrationKeySubscription) as? String
        let tokenSubscription = DengageLocalStorage.shared.value(for: .tokenSubscription) as? String
        let contactKeySubscription = DengageLocalStorage.shared.value(for: .contactKeySubscription) as? String
        let permissionSubscription = DengageLocalStorage.shared.value(for: .permissionSubscription) as? Bool
        let udidSubscription = DengageLocalStorage.shared.value(for: .udidSubscription) as? String
        let carrierIdSubscription = DengageLocalStorage.shared.value(for: .carrierIdSubscription) as? String
        let appVersionSubscription = DengageLocalStorage.shared.value(for: .appVersionSubscription) as? String
        let sdkVersionSubscription = DengageLocalStorage.shared.value(for: .sdkVersionSubscription) as? String
        let countrySubscription = DengageLocalStorage.shared.value(for: .countrySubscription) as? String
        let languageSubscription = DengageLocalStorage.shared.value(for: .languageSubscription) as? String
        let timezoneSubscription = DengageLocalStorage.shared.value(for: .timezoneSubscription) as? String
        let partner_device_idSubscription = DengageLocalStorage.shared.value(for: .partner_device_idSubscription) as? String
        let advertisingIdSubscription = DengageLocalStorage.shared.value(for: .advertisingIdSubscription) as? String
        
        let integrationKey = self.config.integrationKey
        let token = self.config.deviceToken
        let contactKey = self.config.getContactKey()
        let userPermission = self.config.permission
        let udid = self.config.applicationIdentifier
        let carrierId = self.config.getCarrierIdentifier
        let appVersion = self.config.appVersion
        let sdkVersion = SDK_VERSION
        let country = self.config.deviceCountryCode
        let language = self.config.deviceLanguage
        let timezone = self.config.deviceTimeZone
        var PartnerDeviceId = ""
        
        if let partnerId = DengageLocalStorage.shared.value(for: .PartnerDeviceId) as? String
        {
            PartnerDeviceId = partnerId
        }
        let advertisingId = self.config.advertisingIdentifier
        
        if (integrationKeySubscription != nil) && (integrationKeySubscription != integrationKey)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (tokenSubscription != nil) && (token != tokenSubscription)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (contactKey != nil) &&  (contactKey != contactKeySubscription)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (permissionSubscription != nil) &&  (userPermission != permissionSubscription)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (udidSubscription != nil) &&  (udidSubscription != udid)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (carrierIdSubscription != nil) && (carrierIdSubscription != carrierId)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (appVersionSubscription != nil) && (appVersionSubscription != appVersion)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (sdkVersionSubscription != nil) && (sdkVersionSubscription != sdkVersion)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (countrySubscription != nil) && (countrySubscription != country)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (languageSubscription != nil) && (language != languageSubscription)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (timezoneSubscription != nil) && timezone != timezoneSubscription
        {
            makeSubscriptionRequestAPICall()

        }
        else if (partner_device_idSubscription != nil) &&  (PartnerDeviceId != partner_device_idSubscription)
        {
            makeSubscriptionRequestAPICall()

        }
        else if (advertisingIdSubscription != nil) &&  advertisingIdSubscription != advertisingId
        {
            makeSubscriptionRequestAPICall()

        }
        
        if let lastSyncedSubscription = DengageLocalStorage.shared.value(for: .lastSyncdSubscription) as? Date
        {
            let nextSyncedSubscription = lastSyncedSubscription.addingTimeInterval(1200)
            let currentSyncedSubscription = Date()
            
            if currentSyncedSubscription > nextSyncedSubscription
            {
                DengageLocalStorage.shared.set(value: Date(), for: .lastSyncdSubscription)

                makeSubscriptionRequestAPICall()
            }

        }
        else
        {
            DengageLocalStorage.shared.set(value: Date(), for: .lastSyncdSubscription)
            makeSubscriptionRequestAPICall()
        }
    
        
    }
    
    func makeSubscriptionRequestAPICall()
    {
        // eventManager.eventSessionStart()
        let request = MakeSubscriptionRequest(config: config)
        Logger.log(message: "sync Started")
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                Logger.log(message: "sync success")
                
                
                DengageLocalStorage.shared.set(value: self.config.integrationKey, for: .integrationKeySubscription)
                DengageLocalStorage.shared.set(value: self.config.deviceToken, for: .tokenSubscription)
                DengageLocalStorage.shared.set(value: self.config.getContactKey() ?? "", for: .contactKeySubscription)
                DengageLocalStorage.shared.set(value: self.config.permission, for: .permissionSubscription)
                DengageLocalStorage.shared.set(value: self.config.applicationIdentifier, for: .udidSubscription)
                DengageLocalStorage.shared.set(value: self.config.getCarrierIdentifier, for: .carrierIdSubscription)
                DengageLocalStorage.shared.set(value: self.config.appVersion, for: .appVersionSubscription)
                DengageLocalStorage.shared.set(value: SDK_VERSION, for: .sdkVersionSubscription)
                DengageLocalStorage.shared.set(value: self.config.deviceCountryCode, for: .countrySubscription)
                DengageLocalStorage.shared.set(value: self.config.deviceLanguage, for: .languageSubscription)
                DengageLocalStorage.shared.set(value: self.config.deviceTimeZone, for: .timezoneSubscription)
                DengageLocalStorage.shared.set(value: self.config.getPartnerDeviceID() ?? "", for: .partner_device_idSubscription)
                DengageLocalStorage.shared.set(value: self.config.advertisingIdentifier, for: .advertisingIdSubscription)

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
        else
        {
            inAppManager.fetchInAppMessages()

        }
        
    }
    
    func fetchSDK(){
        
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
                self.sendFirstLaunchTimeIfNeeded()
                self.inAppManager.fetchInAppExpiredMessages()

            case .failure:
                Logger.log(message: "SDK PARAMS Config fetchin failed")
            }
        }
    }
    
    
    private func resetUsageStats() {
        DengageLocalStorage.shared.set(value: nil, for: .visitCounts)
        DengageLocalStorage.shared.set(value: nil, for: .lastSessionStartTime)
        DengageLocalStorage.shared.set(value: nil, for: .lastVisitTime)
        DengageLocalStorage.shared.set(value: nil, for: .lastSessionDuration)
    }
    
    private func sendFirstLaunchTimeIfNeeded() {
        guard (DengageLocalStorage.shared.value(for: .firstLaunchTime) as? Double) == nil else { return }
        guard
            let accountName = config.remoteConfiguration?.accountName,
            let appId = config.remoteConfiguration?.appId
        else {
            return
        }
        let request = FirstLaunchEventRequest(sessionId: sessionManager.currentSessionId,
                                              contactKey: config.contactKey.key,
                                              deviceId: config.applicationIdentifier,
                                              accountName: accountName,
                                              appId: appId)
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                DengageLocalStorage.shared.set(value: Date().timeIntervalSince1970,
                                               for: .firstLaunchTime)
                Logger.log(message: "FirstLaunchTime success")
            case .failure:
                Logger.log(message: "FirstLaunchTime failed")
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
                Logger.log(message: "Sending dengage device id to server failed")
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

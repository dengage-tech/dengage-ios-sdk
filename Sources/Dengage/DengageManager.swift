import Foundation
import UserNotifications
import UIKit
public class DengageManager {

    public var config: DengageConfiguration
    var application: UIApplication?
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var options: DengageOptions?
    var threadContainer = ThreadSafeContainer(label: "DengageMainLock")
    public var apiClient: DengageNetworking
    var eventManager: DengageEventProtocolInterface
    var sessionManager: DengageSessionManagerInterface
    var inboxManager: DengageInboxManager
    var inAppManager: DengageInAppMessageManager
    var notificationManager: DengageNotificationManagerInterface
    var dengageRFMManager: DengageRFMManager
    var subscriptionQueue: DengageSubscriptionQueue

    var testPageWindow: UIWindow?
    
    init(with apiKey: String,
         application: UIApplication?,
         launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
         dengageOptions options: DengageOptions,
         apiUrlConfiguration: ApiUrlConfiguration? = nil) {
        
        DengageLocalStorage.shared.saveApiUrlConfiguration(apiUrlConfiguration)
        DengageLocalStorage.shared.saveLocalInboxManagerEnabled(options.localInboxManager)
        
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
        
        self.subscriptionQueue = DengageSubscriptionQueue(apiClient: apiClient, config: config)
        
        syncSubscription()
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
    
    func set(contactKey: String?){
        let previous = self.config.getContactKey()
        if previous != contactKey {
            let newKey = (contactKey?.isEmpty ?? true) ? nil : contactKey
            DengageLocalStorage.shared.set(value: newKey, for: .contactKey)
            inboxManager.inboxMessages.removeAll()
            inboxManager.inboxMessages = []
            let messages = [InboxMessageCache]()
            DengageLocalStorage.shared.save(messages)
            _ = sessionManager.createSession(force: true)
            resetUsageStats()
            Dengage.syncSubscription()
        }
    }
    
    func set(deviceId: String) {
        let previous = self.config.applicationIdentifier
        if previous != deviceId {
            self.config.set(deviceId: deviceId)
            Dengage.syncSubscription()
        }
    }
    
    func set(permission: Bool) {
        let previous = self.config.permission
        if previous != permission {
            self.config.set(permission: permission)
            Dengage.syncSubscription()
        }
    }
    
    func set(locationPermission: String) {
        let previous = self.config.getLocationPermission()
        if previous != locationPermission {
            DengageLocalStorage.shared.set(value: locationPermission, for: .locationPermission)
            Dengage.syncSubscription()
        }
    }
    
    private func shouldMakeSubscriptionRequestBasedOnTime() -> Bool {
        if let lastSyncedSubscription = DengageLocalStorage.shared.value(for: .lastSyncdSubscription) as? Date {
            let nextSyncedSubscription = lastSyncedSubscription.addingTimeInterval(1200) // 20 minutes
            let now = Date()
            if now > nextSyncedSubscription {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    private func shouldMakeSubscriptionRequest() -> Bool {
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
        let partnerDeviceIdSubscription = DengageLocalStorage.shared.value(for: .partner_device_idSubscription) as? String
        let advertisingIdSubscription = DengageLocalStorage.shared.value(for: .advertisingIdSubscription) as? String
        let locationPermissionSubscription = DengageLocalStorage.shared.value(for: .locationPermissionSubscription) as? String
        
        let integrationKey = self.config.integrationKey
        let token = self.config.deviceToken
        let contactKey = self.config.getContactKey()
        let userPermission = self.config.permission
        let udid = self.config.applicationIdentifier
        let carrierId = self.config.getCarrierIdentifier
        let appVersion = self.config.appVersion
        let sdkVersion = SDK_VERSION
        let country = self.config.deviceCountryCode
        let language = self.config.getLanguage()
        let timezone = self.config.deviceTimeZone
        let partnerDeviceId = self.config.getPartnerDeviceID() ?? ""
        let advertisingId = self.config.advertisingIdentifier
        let locationPermission = self.config.locationPermission
        
        if integrationKeySubscription != integrationKey {
            return true
        } else if tokenSubscription != token {
            return true
        } else if contactKeySubscription != contactKey {
            return true
        } else if permissionSubscription != userPermission {
            return true
        } else if udidSubscription != udid {
            return true
        } else if carrierIdSubscription != carrierId {
            return true
        } else if appVersionSubscription != appVersion {
            return true
        } else if sdkVersionSubscription != sdkVersion {
            return true
        } else if countrySubscription != country {
            return true
        } else if languageSubscription != language {
            return true
        } else if timezoneSubscription != timezone {
            return true
        } else if partnerDeviceIdSubscription != partnerDeviceId {
            return true
        } else if advertisingIdSubscription != advertisingId {
            return true
        } else if locationPermissionSubscription != locationPermission {
            return true
        }
        
        return false
    }
    
    func syncSubscription() {
        if !Utilities.isiOSAppExtension() {
            if shouldMakeSubscriptionRequest() || shouldMakeSubscriptionRequestBasedOnTime() {
                subscriptionQueue.enqueueSubscription()
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
        
        let hasRemoteConfig = config.remoteConfiguration != nil
        let lastFetchedDate = DengageLocalStorage.shared.value(for: .lastFetchedConfigTime) as? Date
        
        // If no remote configuration, fetch immediately
        if !hasRemoteConfig {
            fetchSDK()
            return
        }
        
        // Check if we need to fetch based on time (1 minute interval)
        if let fetchedDate = lastFetchedDate {
            let timeSinceLastFetch = Date().timeIntervalSince(fetchedDate)
            if timeSinceLastFetch < 60 { // 1 minute in seconds
                inAppManager.fetchInAppMessages()
                return
            }
        }
        
        // Add random delay between 0-60 seconds before fetching
        let randomDelay = Double.random(in: 0...60)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) { [weak self] in
            self?.fetchSDK()
        }
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
                self.sendFirstLaunchTimeIfNeeded()
                self.inAppManager.fetchInAppExpiredMessageIds()
                self.eventManager.cleanupClientEvents()

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

@objc public class DengageOptions: NSObject,Codable {
    public let disableOpenURL: Bool
    public let badgeCountReset: Bool
    public let disableRegisterForRemoteNotifications: Bool
    public let appGroupsKey: String?
    public let localInboxManager: Bool
    public init(disableOpenURL: Bool = false,
                badgeCountReset: Bool = false,
                disableRegisterForRemoteNotifications: Bool = false,
                appGroupsKey: String? = nil,
                localInboxManager: Bool = false) {
        self.disableOpenURL = disableOpenURL
        self.badgeCountReset = badgeCountReset
        self.disableRegisterForRemoteNotifications = disableRegisterForRemoteNotifications
        self.appGroupsKey = appGroupsKey
        self.localInboxManager = localInboxManager
        
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disableOpenURL = try container.decode(Bool.self, forKey: .disableOpenURL)
        badgeCountReset = try container.decode(Bool.self, forKey: .badgeCountReset)
        disableRegisterForRemoteNotifications = try container.decode(Bool.self, forKey: .disableRegisterForRemoteNotifications)
        appGroupsKey = try? container.decode(String.self, forKey: .appGroupsKey)
        localInboxManager = try container.decode(Bool.self, forKey: .localInboxManager)
    }
    
    enum CodingKeys: String, CodingKey {
        case disableOpenURL, badgeCountReset, disableRegisterForRemoteNotifications, appGroupsKey, localInboxManager
    }
}

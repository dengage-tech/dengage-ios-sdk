import Foundation

final public class DengageLocalStorage: NSObject {
    
    public static let shared = DengageLocalStorage(suitName: SUIT_NAME)
    
    var userDefaults: UserDefaults
    var appGroupUserDefaults: UserDefaults?
    
    
    init(suitName: String) {
        userDefaults = UserDefaults(suiteName: suitName)!
    }
    
    public func setAppGroupsUserDefaults(appGroupName: String) {
        appGroupUserDefaults = UserDefaults(suiteName: appGroupName)
    }
    
    
    public func set(value: Any?, for key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    public func value(for key: Key) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    public enum Key: String{
        case contactKey = "ContactKey"
        case token = "Token"
        case PartnerDeviceId = "PartnerDeviceId"
        case integrationKey = "integrationKey"
        case userPermission = "userPermission"
        case inboxMessages = "inboxMessages"
        case configParams = "configParams"
        case lastFetchedConfigTime = "lastFetchedConfigTime"
        case lastFetchedInAppMessageTime = "lastFetchedInAppMessageTime"
        case inAppMessages = "inAppMessages"
        case inAppMessageShowTime = "inAppMessageShowTime"
        case lastFetchedRealTimeInAppMessageTime = "lastFetchedRealTimeInAppMessageTime"

        case rfmScores = "rfmScores"
        case options = "options"
        case apiKey = "apiKey"
        case geofenceHistory = "geofenceHistory"
        case geofenceEnabled = "geofenceEnabled"
        case geofenceClusters = "geofenceClusters"
        case geofenceLastLocation = "geofenceLastLocation"
        case geofenceLastMovedLocation = "geofenceLastMovedLocation"
        case geofenceLastMovedAt = "geofenceLastMovedAt"
        case geofenceStopped = "geofenceStopped"
        case geofenceLastSentAt = "geofenceLastSentAt"
        case geofenceLastFailedStoppedLocation = "geofenceLastFailedStoppedLocation"
        case expiredMessagesFetchIntervalInMin = "expiredMessagesFetchIntervalInMin"
        case deviceIdRoute = "deviceIdRoute"
        case session = "session"
        case firstLaunchTime = "firstLaunchTime"
        case lastSessionStartTime = "lastSessionStartTime"
        case lastSessionDuration = "lastSessionDuration"
        case lastVisitTime = "lastVisitTime"
        case visitCounts = "visitCounts"
        case visitorInfo = "visitorInfo"
        case openInAppBrowser = "openInAppBrowser"
        case retrieveLinkOnSameScreen = "retrieveLinkOnSameScreen"
        case deeplink = "deeplink"
        case integrationKeySubscription = "integrationKeySubscription"
        case tokenSubscription = "tokenSubscription"
        case contactKeySubscription = "contactKeySubscription"
        case permissionSubscription = "permissionSubscription"
        case udidSubscription = "udidSubscription"
        case carrierIdSubscription = "carrierIdSubscription"
        case appVersionSubscription = "appVersionSubscription"
        case sdkVersionSubscription = "sdkVersionSubscription"
        case tokenTypeSubscription = "tokenTypeSubscription"
        case countrySubscription = "countrySubscription"
        case carrierlanguage = "carrierlanguage"
        case timezoneSubscription = "timezoneSubscription"
        case partner_device_idSubscription = "partner_device_idSubscription"
        case advertisingIdSubscription = "advertisingIdSubscription"
        case languageSubscription = "languageSubscription"
        case lastSyncdSubscription = "lastSyncdSubscription"
        case lastPushPayload = "lastPushPayload"
        case cancelInAppMessage = "cancelInAppMessage"
        case appEnvironment = "appEnvironment"
        case hybridAppEnvironment = "hybridAppEnvironment"
        case delayForInAppMessage = "delayForInAppMessage"
        case language = "language"

        case shownStoryCoverDic = "shownStoryCoverDic"
        case inAppDeviceInfo = "inAppDeviceInfo"
        case apiUrlConfiguration = "apiUrlConfiguration"
        case locationPermission = "locationPermission"
        case locationPermissionSubscription = "locationPermissionSubscription"
        
        case localInboxManagerEnabled = "localInboxManagerEnabled"
        case localInboxMessages = "localInboxMessages"
        case clientEvents = "clientEvents"
        case clientCart = "clientCart"

    }
}

extension DengageLocalStorage {
    
    func getConfig() -> GetSDKParamsResponse? {
        guard let configData = userDefaults.object(forKey: Key.configParams.rawValue) as? Data else { return nil }
        let decoder = JSONDecoder()
        do {
            let config = try decoder.decode(GetSDKParamsResponse.self, from: configData)
            return config
        } catch {
            Logger.log(message: "getConfig fail")
            return nil
        }
    }
    
    func saveConfig(with response: GetSDKParamsResponse) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(response)
            userDefaults.setValue(encoded, forKey: Key.configParams.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving inbox message fail")
        }
    }
    
    func getInAppMessages() -> [InAppMessage] {
        guard let messagesData = userDefaults.object(forKey: Key.inAppMessages.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let messages = try decoder.decode([InAppMessage].self, from: messagesData)
            return messages
        } catch {
            Logger.log(message: "getInAppMessages fail")
            return []
        }
    }
    
    func save(_ inappMessages:[InAppMessage]){
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(inappMessages)
            userDefaults.set(encoded, forKey: Key.inAppMessages.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving inapp message fail")
        }
    }
    
    func save(_ session: Session?){
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(session)
            userDefaults.set(encoded, forKey: Key.session.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "session record fail")
        }
    }
    
    func getSession() -> Session? {
        guard
            let sessionData = userDefaults.object(forKey: Key.session.rawValue) as? Data
        else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let session = try decoder.decode(Session.self, from: sessionData)
            return session
        } catch {
            Logger.log(message: "session not found")
            return nil
        }
    }
    
    func save(_ visitCounts: [VisitCountItem]) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(visitCounts)
            userDefaults.set(encoded, forKey: Key.visitCounts.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "VisitCounts save fail")
        }
    }
    
    func getVisitCounts() -> [VisitCountItem] {
        guard let messagesData = userDefaults.object(forKey: Key.visitCounts.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let messages = try decoder.decode([VisitCountItem].self, from: messagesData)
            return messages
        } catch {
            Logger.log(message: "VisitCounts get fail")
            return []
        }
    }
    
    func save(_ visitorInfo: VisitorInfo) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(visitorInfo)
            userDefaults.set(encoded, forKey: Key.visitorInfo.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "VisitorInfo fail")
        }
    }
    
    func getVisitorInfo() -> VisitorInfo? {
        guard
            let infoData = userDefaults.object(forKey: Key.visitorInfo.rawValue) as? Data
        else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let info = try decoder.decode(VisitorInfo.self, from: infoData)
            return info
        } catch {
            Logger.log(message: "VisitorInfo not found")
            return nil
        }
    }
    
    
    func getrfmScores() -> [RFMScore] {
        guard let messagesData = userDefaults.object(forKey: Key.rfmScores.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let messages = try decoder.decode([RFMScore].self, from: messagesData)
            return messages
        } catch {
            Logger.log(message: "RFMScore fail")
            return []
        }
    }
    
    func save(_ rfmScores: [RFMScore]){
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(rfmScores)
            userDefaults.set(encoded, forKey: Key.rfmScores.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "rfmScores fail")
        }
    }
    
    public func getOptions() -> DengageOptions? {
        guard let optionsData = userDefaults.object(forKey: Key.options.rawValue) as? Data else { return nil }
        let decoder = JSONDecoder()
        do {
            let options = try decoder.decode(DengageOptions.self, from: optionsData)
            return options
        } catch {
            Logger.log(message: "getOptions fail")
            return nil
        }
    }
    
    
    func saveOptions(_ options: DengageOptions) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(options)
            userDefaults.setValue(encoded, forKey: Key.options.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving options fail")
        }
    }
    
    func getInboxMessages() -> [InboxMessageCache] {

        guard let messagesData = userDefaults.object(forKey: Key.inboxMessages.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let inboxMessages = try decoder.decode([InboxMessageCache].self, from: messagesData)
            return inboxMessages
        } catch {
            Logger.log(message: "getInboxMessages fail")
            return []
        }
    }
    
    func save(_ inboxMessages:[InboxMessageCache]){
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(inboxMessages)
            userDefaults.set(encoded, forKey: Key.inboxMessages.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving inbox messages fail")
        }
    }
    
    func getInAppDeviceInfo() -> [String: String] {
        guard let inAppDeviceInfoData = userDefaults.object(forKey: Key.inAppDeviceInfo.rawValue) as? Data else { return [:] }
        let decoder = JSONDecoder()
        do {
            let inAppDeviceInfo = try decoder.decode([String: String].self, from: inAppDeviceInfoData)
            return inAppDeviceInfo
        } catch {
            Logger.log(message: "getInAppDeviceInfo fail")
            return [:]
        }
    }
    
    func saveInAppDeviceInfo(key: String, value: String){
        let inAppDeviceInfoData = userDefaults.object(forKey: Key.inAppDeviceInfo.rawValue) as? Data
        let decoder = JSONDecoder()
        do {
            var inAppDeviceInfoDictionary = [String: String]()
            if let inAppDeviceInfoData {
                inAppDeviceInfoDictionary = try decoder.decode([String: String].self, from: inAppDeviceInfoData)
            }
            inAppDeviceInfoDictionary[key] = value
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(inAppDeviceInfoDictionary)
            userDefaults.set(encoded, forKey: Key.inAppDeviceInfo.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saveInAppDeviceInfo fail")
        }
    }
    
    func clearInAppDeviceInfo(){
        userDefaults.removeObject(forKey: Key.inAppDeviceInfo.rawValue)
        userDefaults.synchronize()
    }
}


//MARK: Geofence
extension DengageLocalStorage {
    
    func getGeofenceClusters() -> [DengageGeofenceCluster] {
        guard let geofenceClustersData = userDefaults.object(forKey: Key.geofenceClusters.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([DengageGeofenceCluster].self, from: geofenceClustersData)
        } catch {
            Logger.log(message: "getGeofenceClusters fail")
            return []
        }
    }
    
    func saveGeofenceClusters(_ geofenceClusters: [DengageGeofenceCluster]){
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(geofenceClusters)
            userDefaults.set(encoded, forKey: Key.geofenceClusters.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving geofenceClusters fail")
        }
    }
}


//MARK: ApiUrlConfiguration
extension DengageLocalStorage {
    
    func getApiUrlConfiguration() -> ApiUrlConfiguration? {
        guard let apiUrlConfigurationData = userDefaults.object(forKey: Key.apiUrlConfiguration.rawValue) as? Data else { return nil }
        let decoder = JSONDecoder()
        do {
            let apiUrlConfiguration = try decoder.decode(ApiUrlConfiguration?.self, from: apiUrlConfigurationData)
            return apiUrlConfiguration
        } catch {
            Logger.log(message: "getApiUrlConfiguration fail")
            return nil
        }
    }
    
    func saveApiUrlConfiguration(_ apiUrlConfiguration: ApiUrlConfiguration?) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(apiUrlConfiguration)
            userDefaults.setValue(encoded, forKey: Key.apiUrlConfiguration.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving apiUrlConfiguration fail")
        }
    }
}


//MARK: Local Inbox Manager
public extension DengageLocalStorage {
    
    func getLocalInboxMessages() -> [DengageLocalInboxMessage] {

        guard let messagesData = appGroupUserDefaults?.object(forKey: Key.localInboxMessages.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let localInboxMessages = try decoder.decode([DengageLocalInboxMessage].self, from: messagesData)
            return localInboxMessages
        } catch {
            Logger.log(message: "getLocalInboxMessages fail \(error)")
            return []
        }
    }
    
    func save(localInboxMessages: [DengageLocalInboxMessage]){
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(localInboxMessages)
            appGroupUserDefaults?.set(encoded, forKey: Key.localInboxMessages.rawValue)
            appGroupUserDefaults?.synchronize()
        } catch {
            Logger.log(message: "saving local inbox messages fail")
        }
    }
    
    func getLocalInboxManagerEnabled() -> Bool {
        return appGroupUserDefaults?.object(forKey: Key.localInboxManagerEnabled.rawValue) as? Bool ?? false
    }
    
    func saveLocalInboxManagerEnabled(_ localInboxManagerEnabled: Bool) {
        appGroupUserDefaults?.set(localInboxManagerEnabled, forKey: Key.localInboxManagerEnabled.rawValue)
        appGroupUserDefaults?.synchronize()
    }

}

// MARK: Events & Cart
extension DengageLocalStorage {
    
    func getClientEvents() -> [String: [ClientEvent]] {
        guard let eventsData = userDefaults.object(forKey: Key.clientEvents.rawValue) as? Data else { return [:] }
        let decoder = JSONDecoder()
        do {
            let clientEvents = try decoder.decode([String: [ClientEvent]].self, from: eventsData)
            return clientEvents
        } catch {
            Logger.log(message: "getClientEvents fail")
            return [:]
        }
    }
    
    func saveClientEvents(_ clientEvents: [String: [ClientEvent]]) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(clientEvents)
            userDefaults.set(encoded, forKey: Key.clientEvents.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving client events fail")
        }
    }
    
    func getClientCart() -> Cart? {
        guard let cartData = userDefaults.object(forKey: Key.clientCart.rawValue) as? Data else { return nil }
        let decoder = JSONDecoder()
        do {
            let cart = try decoder.decode(Cart.self, from: cartData)
            return cart
        } catch {
            Logger.log(message: "getClientCart fail")
            return nil
        }
    }
    
    func saveClientCart(_ cart: Cart) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(cart)
            userDefaults.set(encoded, forKey: Key.clientCart.rawValue)
            userDefaults.synchronize()
        } catch {
            Logger.log(message: "saving client cart fail")
        }
    }
    
}


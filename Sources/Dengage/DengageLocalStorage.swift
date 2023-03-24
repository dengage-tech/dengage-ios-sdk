import Foundation

final class DengageLocalStorage: NSObject {
    
    static let shared = DengageLocalStorage(suitName: SUIT_NAME)
    
    var userDefaults: UserDefaults
    
    init(suitName: String) {
        userDefaults = UserDefaults(suiteName: suitName)!
    }
    
    func set(value: Any?, for key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func value(for key: Key) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    enum Key: String{
        
        case lastSyncdSubscription = "lastSyncdSubscription"
        case contactKey = "ContactKey"
        case token = "Token"
        case userPermission = "userPermission"
        case inboxMessages = "inboxMessages"
        case configParams = "configParams"
        case lastFetchedConfigTime = "lastFetchedConfigTime"
        case lastFetchedInAppMessageTime = "lastFetchedInAppMessageTime"
        case inAppMessages = "inAppMessages"
        case lastFetchedRealTimeInAppMessageTime = "lastFetchedRealTimeInAppMessageTime"
        case PartnerDeviceId = "PartnerDeviceId"
        case inAppMessageShowTime = "inAppMessageShowTime"
        case rfmScores = "rfmScores"
        case integrationKey = "integrationKey"
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
        case delayForInAppMessage = "delayForInAppMessage"
        case lastPushPayload = "lastPushPayload"
        

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
    
    func save(_ inappMessages: [InAppMessage]){
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
}

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
        case applicationIdentifier = "ApplicationIdentifier"
        case contactKey = "ContactKey"
        case token = "Token"
        case integrationKey = "integrationKey"
        case userPermission = "userPermission"
        case inboxMessages = "inboxMessages"
        case configParams = "configParams"
        case lastFetchedConfigTime = "lastFetchedConfigTime"
        case lastFetchedInAppMessageTime = "lastFetchedInAppMessageTime"
        case inAppMessages = "inAppMessages"
        case inAppMessageShowTime = "inAppMessageShowTime"
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
        case PartnerDeviceId = "PartnerDeviceId"

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
    
    func getOptions() -> DengageOptions? {
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


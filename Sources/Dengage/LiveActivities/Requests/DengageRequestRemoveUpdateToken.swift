import Foundation

class DengageRequestRemoveUpdateToken: APIRequest, DengageLiveActivityRequest, DengageLiveActivityUpdateTokenRequest {
    
    var endpointType: EndpointType {
        return .liveActivity
    }
    
    var path: String {
        guard let appId = config?.remoteConfiguration?.appId,
              let activityId = self.key.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) else {
            return ""
        }
        return "/live_activities/\(activityId)/token"
    }
    
    var method: HTTPMethod {
        return .delete
    }
    
    var queryParameters: [URLQueryItem] {
        return []
    }
    
    var httpBody: Data? {
        return nil
    }
    
    typealias Response = EmptyResponse
    
    var requestSuccessful: Bool
    var key: String
    var shouldForgetWhenSuccessful: Bool = true
    var timestamp: Date
    
    weak var config: DengageConfiguration?
    
    func prepareForExecution() -> Bool {
        guard config?.remoteConfiguration?.appId != nil else {
            Logger.log(message: "Cannot generate the remove update token request due to null app ID.")
            return false
        }

        guard self.key.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) != nil else {
            Logger.log(message: "Cannot translate activity type to url encoded string.")
            return false
        }

        return true
    }

    func supersedes(_ existing: DengageLiveActivityRequest) -> Bool {
        // Note that NSDate has nanosecond precision. It's possible for two requests to come in at the same time. If
        // that does happen, we assume the current one supersedes the existing one.
        return self.timestamp >= existing.timestamp
    }

    init(key: String, config: DengageConfiguration) {
        self.key = key
        self.requestSuccessful = false
        self.timestamp = Date()
        self.config = config
    }

    func encode(with coder: NSCoder) {
        coder.encode(key, forKey: "key")
        coder.encode(requestSuccessful, forKey: "requestSuccessful")
        coder.encode(timestamp, forKey: "timestamp")
    }

    required init?(coder: NSCoder) {
        guard
            let key = coder.decodeObject(forKey: "key") as? String,
            let timestamp = coder.decodeObject(forKey: "timestamp") as? Date
        else {
            return nil
        }
        self.key = key
        self.requestSuccessful = coder.decodeBool(forKey: "requestSuccessful")
        self.timestamp = timestamp
        self.config = nil
    }
}


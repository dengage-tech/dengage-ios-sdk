import Foundation

class DengageRequestSetUpdateToken: APIRequest, DengageLiveActivityRequest, DengageLiveActivityUpdateTokenRequest {
    
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
        return .post
    }
    
    var queryParameters: [URLQueryItem] {
        return []
    }
    
    var httpBody: Data? {
        guard let subscriptionId = config?.applicationIdentifier else {
            return nil
        }
        let body: [String: Any] = [
            "subscription_id": subscriptionId,
            "push_token": self.token,
            "device_type": 0
        ]
        return body.json
    }
    
    typealias Response = EmptyResponse
    
    var requestSuccessful: Bool
    var key: String
    var token: String
    var shouldForgetWhenSuccessful: Bool = false
    var timestamp: Date
    
     weak var config: DengageConfiguration?
    
    func prepareForExecution() -> Bool {
        guard config?.remoteConfiguration?.appId != nil else {
            Logger.log(message: "Cannot generate the set update token request due to null app ID.")
            return false
        }

        guard config?.applicationIdentifier != nil else {
            Logger.log(message: "Cannot generate the set update token request due to null subscription ID.")
            return false
        }

        guard self.key.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) != nil else {
            Logger.log(message: "Cannot translate activity type to url encoded string.")
            return false
        }

        return true
    }

    func supersedes(_ existing: DengageLiveActivityRequest) -> Bool {
        if let existingSetRequest = existing as? DengageRequestSetUpdateToken {
            if self.token == existingSetRequest.token {
                return false
            }
        }

        // Note that NSDate has nanosecond precision. It's possible for two requests to come in at the same time. If
        // that does happen, we assume the current one supersedes the existing one.
        return self.timestamp >= existing.timestamp
    }

    init(key: String, token: String, config: DengageConfiguration) {
        self.key = key
        self.token = token
        self.requestSuccessful = false
        self.timestamp = Date()
        self.config = config
    }

    func encode(with coder: NSCoder) {
        coder.encode(key, forKey: "key")
        coder.encode(token, forKey: "token")
        coder.encode(requestSuccessful, forKey: "requestSuccessful")
        coder.encode(timestamp, forKey: "timestamp")
    }

    required init?(coder: NSCoder) {
        guard
            let key = coder.decodeObject(forKey: "key") as? String,
            let token = coder.decodeObject(forKey: "token") as? String,
            let timestamp = coder.decodeObject(forKey: "timestamp") as? Date
        else {
            return nil
        }
        self.key = key
        self.token = token
        self.requestSuccessful = coder.decodeBool(forKey: "requestSuccessful")
        self.timestamp = timestamp
        self.config = nil
    }
}


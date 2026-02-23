import Foundation

class DengageRequestSetStartToken: APIRequest, DengageLiveActivityRequest, DengageLiveActivityStartTokenRequest {
    
    var endpointType: EndpointType {
        return .liveActivity
    }
    
    var path: String {
        return "/p/liveActivity/collect/pushToStart"
    }

    var method: HTTPMethod {
        return .post
    }

    var queryParameters: [URLQueryItem] {
        return []
    }

    var httpBody: Data? {
        guard let accountGuid = config?.remoteConfiguration?.accountName,
              let deviceId = config?.applicationIdentifier else {
            return nil
        }
        let contactKey = config?.getContactKey() ?? ""
        let body: [String: Any] = [
            "accountGuid": accountGuid,
            "deviceId": deviceId,
            "contactKey": contactKey,
            "livePushToStartToken": self.token,
            "activityType": self.key
        ]
        return body.json
    }
    
    typealias Response = EmptyResponse
    
    var key: String
    var token: String
    var requestSuccessful: Bool
    var shouldForgetWhenSuccessful: Bool = false
    var timestamp: Date
    
    weak var config: DengageConfiguration?
    
    func prepareForExecution() -> Bool {
        guard config?.remoteConfiguration?.accountName != nil else {
            Logger.log(message: "Cannot generate the set start token request due to null account name.")
            return false
        }

        guard config?.applicationIdentifier != nil else {
            Logger.log(message: "Cannot generate the set start token request due to null device ID.")
            return false
        }

        return true
    }

    func supersedes(_ existing: DengageLiveActivityRequest) -> Bool {
        if let existingSetRequest = existing as? DengageRequestSetStartToken {
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


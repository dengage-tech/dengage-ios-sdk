import Foundation
import ActivityKit

class DengageRequestSetStartToken: APIRequest, DengageLiveActivityRequest, DengageLiveActivityStartTokenRequest {
    
    var endpointType: EndpointType {
        return .liveActivity
    }
    
    var path: String {
        return "/p/liveActivity/collect/pushToStartToken"
    }

    var method: HTTPMethod {
        return .post
    }

    var queryParameters: [URLQueryItem] {
        return []
    }

    var httpBody: Data? {
        guard let accountGuid = config?.remoteConfiguration?.accountName,
              let appId = config?.remoteConfiguration?.appId,
              let deviceId = config?.applicationIdentifier else {
            return nil
        }
        let body: [String: Any] = [
            "accountGuid": accountGuid,
            "appGuid": appId,
            "deviceId": deviceId,
            "livePushToStartToken": self.token,
            "liveActivityPermission": self.liveActivityPermission
        ]
        return body.json
    }

    /// Reads the current Live Activity authorization state. Returns false on OS versions where
    /// ActivityKit is unavailable.
    static func currentLiveActivityPermission() -> Bool {
        if #available(iOS 16.1, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        } else {
            return false
        }
    }
    
    typealias Response = EmptyResponse
    
    var key: String
    var token: String
    var liveActivityPermission: Bool
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
                // Same token: only supersede (and thus resend) if the live activity permission changed,
                // so that a permission toggle is reflected server-side even when the token is unchanged.
                return self.liveActivityPermission != existingSetRequest.liveActivityPermission
            }
        }

        // Note that NSDate has nanosecond precision. It's possible for two requests to come in at the same time. If
        // that does happen, we assume the current one supersedes the existing one.
        return self.timestamp >= existing.timestamp
    }

    /// - Parameter liveActivityPermission: Pass an explicit value to preserve a previously captured
    ///   permission (e.g. when restoring from cache or re-injecting config). Pass nil to capture the
    ///   current permission state now.
    init(key: String, token: String, config: DengageConfiguration, liveActivityPermission: Bool? = nil) {
        self.key = key
        self.token = token
        self.liveActivityPermission = liveActivityPermission ?? DengageRequestSetStartToken.currentLiveActivityPermission()
        self.requestSuccessful = false
        self.timestamp = Date()
        self.config = config
    }

    func encode(with coder: NSCoder) {
        coder.encode(key, forKey: "key")
        coder.encode(token, forKey: "token")
        coder.encode(liveActivityPermission, forKey: "liveActivityPermission")
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
        self.liveActivityPermission = coder.decodeBool(forKey: "liveActivityPermission")
        self.requestSuccessful = coder.decodeBool(forKey: "requestSuccessful")
        self.timestamp = timestamp
        self.config = nil
    }
}


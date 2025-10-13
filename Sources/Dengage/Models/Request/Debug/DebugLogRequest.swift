import Foundation

struct DebugLogRequest: APIRequest {
    
    typealias Response = EmptyResponse
    
    let method: HTTPMethod = .post
    let endpointType: EndpointType = .push
    var path: String {
        return "/felogging/\(screenName)"
    }
    
    var httpBody: Data? {
        return try? JSONEncoder().encode(debugLog)
    }
    
    let queryParameters: [URLQueryItem] = []
    
    let screenName: String
    let debugLog: DebugLog
    
    init(screenName: String, debugLog: DebugLog) {
        self.screenName = screenName
        self.debugLog = debugLog
    }
}

struct DebugLog: Codable {
    let traceId: String
    let appGuid: String?
    let appId: String?
    let account: String?
    let device: String
    let sessionId: String
    let sdkVersion: String
    let currentCampaignList: [String]
    let campaignId: String?
    let campaignType: String?
    let sendId: String?
    let message: String
    let context: [String: String]
    let contactKey: String?
    let channel: String
    let currentRules: String
    
    enum CodingKeys: String, CodingKey {
        case traceId = "trace_id"
        case appGuid = "app_guid"
        case appId = "app_id"
        case account
        case device
        case sessionId = "session_id"
        case sdkVersion = "sdk_version"
        case currentCampaignList = "current_campaign_list"
        case campaignId = "campaign_id"
        case campaignType = "campaign_type"
        case sendId = "send_id"
        case message
        case context
        case contactKey = "contact_key"
        case channel
        case currentRules = "current_rules"
    }
    
    init(traceId: String,
         appGuid: String?,
         appId: String?,
         account: String?,
         device: String,
         sessionId: String,
         sdkVersion: String,
         currentCampaignList: [String],
         campaignId: String?,
         campaignType: String?,
         sendId: String?,
         message: String,
         context: [String: String],
         contactKey: String?,
         channel: String,
         currentRules: [String: Any]) {
        
        self.traceId = traceId
        self.appGuid = appGuid
        self.appId = appId
        self.account = account
        self.device = device
        self.sessionId = sessionId
        self.sdkVersion = sdkVersion
        self.currentCampaignList = currentCampaignList
        self.campaignId = campaignId
        self.campaignType = campaignType
        self.sendId = sendId
        self.message = message
        self.context = context
        self.contactKey = contactKey
        self.channel = channel
        
        // Convert [String: Any] to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: currentRules),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.currentRules = jsonString
        } else {
            self.currentRules = "{}"
        }
    }
}

import Foundation

enum StoryEventType: String {
    case display = "ds"
    case storyDisplay = "sd"
    case storyClick = "sc"
}

struct StoryRequest: APIRequest {
    
    typealias Response = EmptyResponse
    
    let method: HTTPMethod = .get
    let enpointType: EndpointType = .inapp
    let path: String = "/realtime-inapp/event"
    
    let httpBody: Data? = nil
    
    var queryParameters: [URLQueryItem] {
        var parameters = [
            URLQueryItem(name: "accid", value: accountName),
            URLQueryItem(name: "ckey", value: contactKey),
            URLQueryItem(name: "did", value: deviceID),
            URLQueryItem(name: "eventtype", value: storyEventType.rawValue),
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "session_id", value: sessionId),
            URLQueryItem(name: "campid", value: campaignId),  // Burada da public id gidiyor.
            URLQueryItem(name: "campparams", value: id),  // Burada da public id gidiyor.
            URLQueryItem(name: "content_id", value: contentId),
        ]
        
        if storyEventType == .storyDisplay || storyEventType == .storyClick {
            parameters.append(contentsOf: [
                URLQueryItem(name: "stPrId", value: storyProfileId),
                URLQueryItem(name: "stPrName", value: storyProfileName),
                URLQueryItem(name: "stId", value: storyId),
                URLQueryItem(name: "stName", value: storyName),
            ]
            )
        }
        
        return parameters
    }
    let id: String
    let contactKey: String
    let accountName: String
    let deviceID: String
    let sessionId: String
    let campaignId: String
    let appid: String
    let contentId: String?
    let storyEventType: StoryEventType
    let storyProfileId: String?
    let storyProfileName: String?
    let storyId: String?
    let storyName: String?
}

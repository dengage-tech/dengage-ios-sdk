import Foundation

struct MarkAsRealTimeInAppMessageAsDismissedRequest: APIRequest{
    
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
            URLQueryItem(name: "eventtype", value: "dms"),
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "session_id", value: sessionId),
            URLQueryItem(name: "campid", value: campaignId),
            URLQueryItem(name: "campparams", value: id)
        ]
        if let contentId = contentId {
            parameters.append(URLQueryItem(name: "content_id", value: contentId))
        }
        return parameters
    }

    let id: String
    let contactKey: String
    let accountName: String
    let deviceID: String
    let sessionId: String
    let campaignId: String
    let appId: String
    let contentId: String?
    
}

import Foundation

struct MarkAsRealTimeInAppMessageDisplayedRequest: APIRequest{
    
    typealias Response = EmptyResponse

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .inapp
    let path: String = "/realtime-inapp/event"

    let httpBody: Data? = nil
    
    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "accid", value: accountName),
            URLQueryItem(name: "ckey", value: contactKey),
            URLQueryItem(name: "did", value: deviceID),
            URLQueryItem(name: "eventtype", value: "imp"),
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "session_id", value: sessionId),
            URLQueryItem(name: "campid", value: campaignId),
            URLQueryItem(name: "campparams", value: id)
        ]
    }
    
    let id: String
    let contactKey: String
    let accountName: String
    let deviceID:String
    let sessionId: String
    let campaignId: String // publicID
    let appId: String
}

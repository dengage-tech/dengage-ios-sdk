import Foundation

struct AppForegroundEventRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .inapp
    let path: String = "/realtime-inapp/event"
    
    var queryParameters: [URLQueryItem] {
        return [
            URLQueryItem(name: "eventtype", value: "foreground"),
            URLQueryItem(name: "accid", value: accountName),
            URLQueryItem(name: "session_id", value: sessionId),
            URLQueryItem(name: "did", value: deviceId),
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "ckey", value: contactKey),
            URLQueryItem(name: "eventval", value: duration)
        ]
    }

    let sessionId: String
    let contactKey: String
    let deviceId: String
    let accountName: String
    let appId: String
    let duration: String
}

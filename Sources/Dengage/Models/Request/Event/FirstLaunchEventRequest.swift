import Foundation

struct FirstLaunchEventRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .inapp
    let path: String = "/realtime-inapp/event"

    var queryParameters: [URLQueryItem] {
        return [
            URLQueryItem(name: "eventtype", value: "firstlaunch"),
            URLQueryItem(name: "accid", value: accountName),
            URLQueryItem(name: "session_id", value: sessionId),
            URLQueryItem(name: "did", value: deviceId),
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "ckey", value: contactKey)
        ]
    }

    let sessionId: String
    let contactKey: String
    let deviceId: String
    let accountName: String
    let appId: String
}

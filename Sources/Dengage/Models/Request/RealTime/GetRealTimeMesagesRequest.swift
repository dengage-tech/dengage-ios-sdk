import Foundation

struct GetRealTimeMesagesRequest: APIRequest {

    typealias Response = [InAppMessageData]

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .inapp
    var path: String {
        return "api/realtime-inapp/\(accountName)/\(appId)/campaign.json"
    }

    let queryParameters: [URLQueryItem] = []

    let accountName: String
    let appId: String
}

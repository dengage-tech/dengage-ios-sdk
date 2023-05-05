import Foundation

struct GetRealTimeMesagesRequest: APIRequest {

    typealias Response = [InAppMessageData]

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .inapp
    var path: String {
        return "/\(accountName)/\(appId)/campaign"
    }

    let queryParameters: [URLQueryItem] = []

    let accountName: String
    let appId: String
}

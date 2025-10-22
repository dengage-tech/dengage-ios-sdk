import Foundation

struct GetRealTimeMesagesRequest: APIRequest {

    typealias Response = [InAppMessageData]

    let method: HTTPMethod = .get
    let endpointType: EndpointType = .inappRealTime
    var path: String {
        if version.isEmpty {
            return "/\(accountName)/\(appId)/campaign.json"
        } else {
            return "/\(accountName)/\(appId)/\(version)/campaign.json"
        }
    }

    let queryParameters: [URLQueryItem] = []

    let accountName: String
    let appId: String
    let version: String
}

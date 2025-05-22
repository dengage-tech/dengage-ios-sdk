import Foundation

struct GetRealTimeMesagesRequest: APIRequest {

    typealias Response = [InAppMessageData]

    let method: HTTPMethod = .get
    let endpointType: EndpointType = .inappRealTime
    var path: String {
        return "/\(accountName)/\(appId)/campaign.json"
    }

    let queryParameters: [URLQueryItem] = []

    let accountName: String
    let appId: String
}

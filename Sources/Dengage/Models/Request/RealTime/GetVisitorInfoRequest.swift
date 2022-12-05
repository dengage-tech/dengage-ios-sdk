import Foundation
struct GetVisitorInfoRequest: APIRequest {

    typealias Response = VisitorInfo

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .push
    var path: String {
        return "/api/audience/visitor-info"
    }

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "ckey", value: contactKey),
            URLQueryItem(name: "did", value: deviceID)
        ]
    }

    let accountName: String
    let contactKey: String
    let deviceID: String
}

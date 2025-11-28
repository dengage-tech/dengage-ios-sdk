import Foundation
struct GetSDKParamsRequest: APIRequest {

    typealias Response = GetSDKParamsResponse

    let method: HTTPMethod = .get
    let endpointType: EndpointType = .push
    let path: String = "/api/getSdkParams"

    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "ik", value: integrationKey),
        ]
    }

    let integrationKey: String

    init(integrationKey: String) {
        self.integrationKey = integrationKey

    }
}


import Foundation
struct GetSDKParamsRequest: APIRequest {

    typealias Response = GetSDKParamsResponse

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .push
    let path: String = "/api/getSdkParams"

    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "ik", value: integrationKey),
            URLQueryItem(name: "did", value: deviceId)
        ]
    }

    let integrationKey: String
    let deviceId: String

    init(integrationKey: String, deviceId: String) {
        self.integrationKey = integrationKey
        self.deviceId = deviceId
    }
}


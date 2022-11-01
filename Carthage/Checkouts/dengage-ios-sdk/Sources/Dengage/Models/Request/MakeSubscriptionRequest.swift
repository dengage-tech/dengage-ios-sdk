
import Foundation

struct MakeSubscriptionRequest: APIRequest {

    typealias Response = GetSDKParamsResponse

    let method: HTTPMethod = .post
    let enpointType: EndpointType = .push
    let path: String = "/api/device/subscription"

    var httpBody: Data?{
        let parameters = ["integrationKey": config.integrationKey,
                          "token": config.deviceToken ?? "",
                          "contactKey": config.getContactKey() ?? "",
                          "permission": config.permission,
                          "udid": config.applicationIdentifier,
                          "carrierId": config.getCarrierIdentifier,
                          "appVersion": config.appVersion,
                          "sdkVersion": SDK_VERSION,
                          "tokenType": "I",
                          "country": config.deviceCountryCode,
                          "language": config.deviceLanguage,
                          "timezone": config.deviceTimeZone,
                          "advertisingId" : config.advertisingIdentifier as Any]
        return parameters.json
    }

    let queryParameters: [URLQueryItem] = []

    let config: DengageConfiguration
}


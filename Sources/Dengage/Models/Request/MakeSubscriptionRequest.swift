
import Foundation

struct MakeSubscriptionRequest: APIRequest {
    
    typealias Response = GetSDKParamsResponse
    
    let method: HTTPMethod = .post
    let endpointType: EndpointType = .push
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
                          "language": config.getLanguage(),
                          "timezone": config.deviceTimeZone,
                          "partner_device_id": config.getPartnerDeviceID() ?? "",
                          "advertisingId" : config.advertisingIdentifier as Any,
                          "locationPermission" : config.getLocationPermission() ?? ""]
        return parameters.json
    }
    
    let queryParameters: [URLQueryItem] = []
    
    let config: DengageConfiguration
}


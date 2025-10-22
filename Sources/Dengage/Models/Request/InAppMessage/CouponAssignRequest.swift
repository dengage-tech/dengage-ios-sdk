import Foundation

struct CouponAssignRequest: APIRequest {
    
    typealias Response = CouponAssignResponse
    
    let method: HTTPMethod = .post
    let endpointType: EndpointType = .push
    var path: String {
        return "/coupon/\(accountId)/assign"
    }
    
    var httpBody: Data? {
        let requestBody = CouponAssignRequestBody(key: key)
        return try? JSONEncoder().encode(requestBody)
    }
    
    let queryParameters: [URLQueryItem] = []
    
    let accountId: String
    let key: String
    
    init(accountId: String, listKey: String, contactKey: String, deviceId: String, campaignId: String) {
        self.accountId = accountId
        
        let couponData = CouponKeyData(
            ListKey: listKey,
            ContactKey: contactKey,
            DeviceId: deviceId,
            CampaignId: campaignId
        )
        
        if let jsonData = try? JSONEncoder().encode(couponData) {
            self.key = jsonData.base64EncodedString()
        } else {
            self.key = ""
        }
    }
}

struct CouponAssignRequestBody: Codable {
    let key: String
}

struct CouponKeyData: Codable {
    let ListKey: String
    let ContactKey: String
    let DeviceId: String
    let CampaignId: String
}

struct CouponAssignResponse: Codable {
    let code: String?
    let message: String?
}
import Foundation
struct ExpiredInAppMessageRequest: APIRequest{
    
    typealias Response = [InAppRemovalId]

    let method: HTTPMethod = .get
    let endpointType: EndpointType = .push
    let path: String = "/api/inapp/getExpiredMessages"

    let httpBody: Data? = nil
    
    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "cdkey", value: contactKey),
            URLQueryItem(name: "appid", value: appid)
        ]
    }
    
    let appid: String
    let contactKey: String
    let accountName: String

    
    init(accountName:String, contactKey: String, appid: String) {
        self.accountName = accountName
        self.contactKey = contactKey
        self.appid = appid
    
    }
}

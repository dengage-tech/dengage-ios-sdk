import Foundation
struct GetMessagesRequest: APIRequest {

    typealias Response = [DengageMessage]
    let enpointType: EndpointType = .push
    let method: HTTPMethod = .get
    let path: String = "/api/pi/getMessages"

    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "cdkey", value: contactKey),
            URLQueryItem(name: "limit", value: limit),
            URLQueryItem(name: "offset", value: offset),
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "did", value: deviceId)
        ]
    }

    let limit: String
    let offset: String
    let contactKey: String
    let accountName:String
    let type:String
    let deviceId: String
    
    init(accountName:String,
         contactKey: String,
         type:String,
         offset: Int,
         limit: Int = 20,
         deviceId: String) {
        self.accountName = accountName
        self.contactKey = contactKey
        self.offset = String(offset)
        self.limit = String(limit)
        self.type = type
        self.deviceId = deviceId
    }
}

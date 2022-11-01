import Foundation

struct GetInAppMessagesRequest: APIRequest {

    typealias Response = [InAppMessage]

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .push
    let path: String = "/api/inapp/getMessages"

    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "cdkey", value: contactKey),
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "did", value: deviceId)
        ]
    }

    let contactKey: String
    let accountName:String
    let type:String
    let deviceId: String
    
    init(accountName:String,
         contactKey: String,
         type:String,
         limit: Int = 20,
         deviceId: String) {
        self.accountName = accountName
        self.contactKey = contactKey
        self.type = type
        self.deviceId = deviceId
    }
}

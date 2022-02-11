import Foundation
struct MarkAsReadRequest: APIRequest{
    
    typealias Response = EmptyResponse

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .push
    let path: String = "/api/pi/setAsClicked"

    let httpBody: Data? = nil
    
    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "cdkey", value: contactKey),
            URLQueryItem(name: "msgid", value: id),
            URLQueryItem(name: "did", value: deviceID),
            URLQueryItem(name: "type", value: type)
        ]
    }
    
    let id: String
    let contactKey: String
    let accountName: String
    let type: String
    let deviceID:String
    
    init(type: String,
         deviceID:String,
         accountName:String,
         contactKey: String,
         id: String) {
        self.accountName = accountName
        self.contactKey = contactKey
        self.id = id
        self.type = type
        self.deviceID = deviceID
    }
}

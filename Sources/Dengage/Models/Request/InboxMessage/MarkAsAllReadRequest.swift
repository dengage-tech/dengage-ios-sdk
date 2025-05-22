import Foundation

struct MarkAsAllReadRequest: APIRequest{
    
    typealias Response = EmptyResponse
    
    let method: HTTPMethod = .get
    let endpointType: EndpointType = .push
    let path: String = "/p/pi/setAsClickedAll"
    
    let httpBody: Data? = nil
    
    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "cdkey", value: contactKey),
            URLQueryItem(name: "did", value: deviceID),
            URLQueryItem(name: "type", value: type)
        ]
    }
    
    let appid: String
    let accountName: String
    let contactKey: String
    let deviceID: String
    let type: String
    
    
    init(appid: String,
         type: String,
         deviceID:String,
         accountName:String,
         contactKey: String) {
        self.appid = appid
        self.accountName = accountName
        self.contactKey = contactKey
        self.type = type
        self.deviceID = deviceID
    }
}

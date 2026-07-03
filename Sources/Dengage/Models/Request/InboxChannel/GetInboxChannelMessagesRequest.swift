import Foundation

struct GetInboxChannelMessagesRequest: APIRequest {

    typealias Response = [DengageInboxChannelMessage]
    let endpointType: EndpointType = .push
    let method: HTTPMethod = .get
    let path: String = "/api/inbox/getMessages"
    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName),
            URLQueryItem(name: "ckey", value: contactKey),
            URLQueryItem(name: "did", value: deviceId),
            URLQueryItem(name: "appId", value: appId),
            URLQueryItem(name: "limit", value: limit)
        ]
    }

    let accountName: String
    let contactKey: String?
    let deviceId: String
    let appId: String?
    let limit: String

    init(accountName: String,
         contactKey: String?,
         deviceId: String,
         appId: String?,
         limit: Int = 20) {
        self.accountName = accountName
        self.contactKey = contactKey
        self.deviceId = deviceId
        self.appId = appId
        self.limit = String(limit)
    }
}

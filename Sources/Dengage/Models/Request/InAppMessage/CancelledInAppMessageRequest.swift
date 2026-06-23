import Foundation
struct CancelledInAppMessageRequest: APIRequest {

    typealias Response = [InAppCancelledSendId]

    let method: HTTPMethod = .get
    let endpointType: EndpointType = .push
    let path: String = "/api/inapp/getCancelledSendIds"

    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "acc", value: accountName)
        ]
    }

    let accountName: String

    init(accountName: String) {
        self.accountName = accountName
    }
}

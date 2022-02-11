
import Foundation
struct OpenEventRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .post
    let enpointType: EndpointType = .event
    let path: String = "/api/mobile/open"
    let queryParameters: [URLQueryItem] = []

    var httpBody: Data?{
        var parameters = ["integrationKey": integrationKey,
                          "messageId": messageId,
                          "messageDetails": messageDetails] as [String : Any]
        
        if let buttonId = buttonId {
            parameters["buttonId"] = buttonId
        }
        return parameters.json
    }

    let integrationKey: String
    let messageId: Int
    let messageDetails: String
    let buttonId: String?
}


import Foundation
struct TransactionalOpenEventRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .post
    let endpointType: EndpointType = .event
    var path: String { eventType.path(isTransactional: true) }
    let queryParameters: [URLQueryItem] = []
    
    var httpBody: Data?{
        var parameters = ["integrationKey": integrationKey,
                          "transactionId": transactionId,
                          "messageId": messageId,
                          "messageDetails": messageDetails] as [String : Any]
        if let buttonId = buttonId {
            parameters["buttonId"] = buttonId
        }
        return parameters.json
    }

    let integrationKey: String
    let transactionId: String
    let messageId: Int
    let messageDetails: String
    let buttonId: String?
    var eventType: PushEventType = .open

}


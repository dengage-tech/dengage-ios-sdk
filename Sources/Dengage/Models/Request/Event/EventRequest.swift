import Foundation
struct EventRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .post
    let enpointType: EndpointType = .event
    let path: String = "/api/event"

    var httpBody: Data?{
        let parameters = ["integrationKey": integrationKey,
                          "key": key,
                          "eventTable": eventTable,
                          "eventDetails": eventDetails] as [String : Any]
        return parameters.json
    }

    let queryParameters: [URLQueryItem] = []

    let integrationKey: String
    let key: String
    let eventTable: String
    let eventDetails: [String: Any]
}


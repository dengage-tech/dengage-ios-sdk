import Foundation
struct EventRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .post
    let enpointType: EndpointType = .event
    let path: String = "/api/event"

    var httpBody: Data?{
        
        let safeEventDetails = eventDetails.removingInvalidNumbers()
        
        let parameters = ["integrationKey": integrationKey,
                          "key": key,
                          "eventTable": eventTable,
                          "eventDetails": safeEventDetails] as [String : Any]
        return parameters.json
    }

    let queryParameters: [URLQueryItem] = []

    let integrationKey: String
    let key: String
    let eventTable: String
    let eventDetails: [String: Any]
}

extension Dictionary where Key == String, Value == Any {
    func removingInvalidNumbers() -> [String: Any] {
        var cleaned: [String: Any] = [:]
        for (key, value) in self {
            switch value {
            case let num as Double where num.isNaN || !num.isFinite:
                cleaned[key] = 0 // or NSNull(), or just skip
            case let dict as [String: Any]:
                cleaned[key] = dict.removingInvalidNumbers()
            case let array as [Any]:
                cleaned[key] = array.removingInvalidNumbers()
            default:
                cleaned[key] = value
            }
        }
        return cleaned
    }
}

extension Array where Element == Any {
    func removingInvalidNumbers() -> [Any] {
        return map { element in
            switch element {
            case let num as Double where num.isNaN || !num.isFinite:
                return 0
            case let dict as [String: Any]:
                return dict.removingInvalidNumbers()
            case let array as [Any]:
                return array.removingInvalidNumbers()
            default:
                return element
            }
        }
    }
}



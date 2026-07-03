import Foundation

/// POST /api/inbox/events. Supports bulk sending: one request can carry
/// multiple events. The event date is stamped as UTC now by the SDK.
struct SendInboxChannelEventsRequest: APIRequest {

    typealias Response = EmptyResponse
    let endpointType: EndpointType = .push
    let method: HTTPMethod = .post
    let path: String = "/api/inbox/events"
    let queryParameters: [URLQueryItem] = []

    var httpBody: Data? {
        let eventDateUTC = Utilities.convertToString(to: Date()) ?? ""
        let eventParams: [[String: Any]] = events.map { event in
            [
                "eventType": event.eventType.rawValue,
                "msgid": event.messageId,
                "messageDetails": event.messageDetails ?? "",
                "eventDateUTC": eventDateUTC
            ]
        }
        var parameters: [String: Any] = [
            "acc": accountName,
            "did": deviceId,
            "events": eventParams
        ]
        if let contactKey = contactKey {
            parameters["ckey"] = contactKey
        }
        if let appId = appId {
            parameters["appId"] = appId
        }
        return parameters.json
    }

    let accountName: String
    let contactKey: String?
    let deviceId: String
    let appId: String?
    let events: [DengageInboxChannelEvent]
}

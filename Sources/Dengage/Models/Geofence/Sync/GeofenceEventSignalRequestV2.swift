import Foundation

/// `POST /event-signal/{integrationKey}` v2 — trigger + offline replay + dedup (contract §3).
/// camelCase alanlar; v1'in kısa anahtarları (cid/geoid) kullanılmaz.
public struct GeofenceEventSignalRequestV2: APIRequest {

    public typealias Response = EmptyResponse

    public let method: HTTPMethod = .post
    public let endpointType: EndpointType = .geofence
    public var path: String { "/event-signal/\(integrationKey)" }
    public let queryParameters: [URLQueryItem] = []

    public var httpBody: Data? {
        var parameters: [String: Any] = [
            "deviceId": deviceId,
            "geofenceId": geofenceId,
            "clusterId": clusterId,
            "eventType": eventType.rawValue,
            "latitude": latitude,
            "longitude": longitude,
            "occurredAt": GeofenceIso.string(from: occurredAt),
            "ingestedAt": GeofenceIso.string(from: ingestedAt),
            "idempotencyKey": idempotencyKey,
            "source": source.rawValue
        ]
        if let contactKey = contactKey { parameters["contactKey"] = contactKey }
        if let campaignId = campaignId { parameters["campaignId"] = campaignId }
        if let accuracyM = accuracyM { parameters["accuracyM"] = accuracyM }
        return parameters.json
    }

    let integrationKey: String
    let deviceId: String
    let contactKey: String?
    let geofenceId: Int
    let clusterId: Int
    let campaignId: Int?
    let eventType: GeofenceEventType
    let latitude: Double
    let longitude: Double
    let accuracyM: Double?
    let occurredAt: Date
    let ingestedAt: Date
    let idempotencyKey: String
    let source: GeofenceEventSource

    public init(integrationKey: String,
                deviceId: String,
                contactKey: String?,
                geofenceId: Int,
                clusterId: Int,
                campaignId: Int?,
                eventType: GeofenceEventType,
                latitude: Double,
                longitude: Double,
                accuracyM: Double?,
                occurredAt: Date,
                ingestedAt: Date,
                idempotencyKey: String,
                source: GeofenceEventSource) {
        self.integrationKey = integrationKey
        self.deviceId = deviceId
        self.contactKey = contactKey
        self.geofenceId = geofenceId
        self.clusterId = clusterId
        self.campaignId = campaignId
        self.eventType = eventType
        self.latitude = latitude
        self.longitude = longitude
        self.accuracyM = accuracyM
        self.occurredAt = occurredAt
        self.ingestedAt = ingestedAt
        self.idempotencyKey = idempotencyKey
        self.source = source
    }
}

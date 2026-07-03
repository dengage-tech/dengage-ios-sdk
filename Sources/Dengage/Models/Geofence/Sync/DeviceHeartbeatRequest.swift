import Foundation

/// `POST /devices/heartbeat/{integrationKey}` — device_last_location UPSERT (contract §2).
public struct DeviceHeartbeatRequest: APIRequest {

    public typealias Response = EmptyResponse

    public let method: HTTPMethod = .post
    public let endpointType: EndpointType = .geofence
    public var path: String { "/devices/heartbeat/\(integrationKey)" }
    public let queryParameters: [URLQueryItem] = []

    public var httpBody: Data? {
        var parameters: [String: Any] = [
            "deviceId": deviceId,
            "latitude": latitude,
            "longitude": longitude,
            "capturedAt": GeofenceIso.string(from: capturedAt)
        ]
        if let contactKey = contactKey { parameters["contactKey"] = contactKey }
        if let accuracyM = accuracyM { parameters["accuracyM"] = accuracyM }
        return parameters.json
    }

    let integrationKey: String
    let deviceId: String
    let contactKey: String?
    let latitude: Double
    let longitude: Double
    let accuracyM: Double?
    let capturedAt: Date

    public init(integrationKey: String,
                deviceId: String,
                contactKey: String?,
                latitude: Double,
                longitude: Double,
                accuracyM: Double?,
                capturedAt: Date) {
        self.integrationKey = integrationKey
        self.deviceId = deviceId
        self.contactKey = contactKey
        self.latitude = latitude
        self.longitude = longitude
        self.accuracyM = accuracyM
        self.capturedAt = capturedAt
    }
}

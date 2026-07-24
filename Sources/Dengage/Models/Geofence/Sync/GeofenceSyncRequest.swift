import Foundation

/// `GET /geofences/sync/{integrationKey}` — full payload + ETag (contract §1).
/// ETag/304 yönetimi `DengageNetworking.sendGeofenceSync(...)` içinde yapılır.
public struct GeofenceSyncRequest: APIRequest {

    public typealias Response = GeofenceSyncResponse

    public let method: HTTPMethod = .get
    public let endpointType: EndpointType = .geofence
    public var path: String { "/geofences/sync/\(integrationKey)" }
    public let httpBody: Data? = nil

    public var queryParameters: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let deviceId = deviceId { items.append(URLQueryItem(name: "deviceId", value: deviceId)) }
        if let contactKey = contactKey { items.append(URLQueryItem(name: "contactKey", value: contactKey)) }
        if let latitude = latitude { items.append(URLQueryItem(name: "lat", value: String(format: "%.06f", latitude))) }
        if let longitude = longitude { items.append(URLQueryItem(name: "lon", value: String(format: "%.06f", longitude))) }
        return items
    }

    public var headers: [String: String]? {
        guard let ifNoneMatch = ifNoneMatch, !ifNoneMatch.isEmpty else { return nil }
        return ["If-None-Match": ifNoneMatch]
    }

    let integrationKey: String
    let deviceId: String?
    let contactKey: String?
    let latitude: Double?
    let longitude: Double?
    let ifNoneMatch: String?

    public init(integrationKey: String,
                deviceId: String?,
                contactKey: String?,
                latitude: Double?,
                longitude: Double?,
                ifNoneMatch: String?) {
        self.integrationKey = integrationKey
        self.deviceId = deviceId
        self.contactKey = contactKey
        self.latitude = latitude
        self.longitude = longitude
        self.ifNoneMatch = ifNoneMatch
    }
}

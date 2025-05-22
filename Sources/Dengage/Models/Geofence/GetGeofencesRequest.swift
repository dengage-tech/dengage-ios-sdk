import Foundation

public struct GetGeofencesRequest: APIRequest {

    public typealias Response = [DengageGeofenceCluster]

    public let method: HTTPMethod = .get
    public let endpointType: EndpointType = .geofence
    public var path: String {
        "/geofence/\(integrationKey)"
    }

    public let httpBody: Data? = nil

    public var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "latitude", value: String(format: "%.06f", latitude)),
            URLQueryItem(name: "longitude", value: String(format: "%.06f", longitude))
        ]
    }

    let integrationKey: String
    let latitude: Double
    let longitude: Double

    public init(integrationKey: String,
         latitude: Double,
         longitude: Double) {
        self.integrationKey = integrationKey
        self.latitude = latitude
        self.longitude = longitude
    }
}

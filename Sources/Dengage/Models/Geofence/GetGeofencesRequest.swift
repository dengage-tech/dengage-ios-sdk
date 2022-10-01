import Foundation

struct GetGeofencesRequest: APIRequest {

    typealias Response = [DengageGeofenceCluster]

    let method: HTTPMethod = .get
    let enpointType: EndpointType = .geofence
    var path: String {
        "/geofence/\(integrationKey)"
    }

    let httpBody: Data? = nil

    var queryParameters: [URLQueryItem] {
        [
            URLQueryItem(name: "latitude", value: String(format: "%.06f", latitude)),
            URLQueryItem(name: "longitude", value: String(format: "%.06f", longitude))
        ]
    }

    let integrationKey: String
    let latitude: Double
    let longitude: Double

    init(integrationKey: String,
         latitude: Double,
         longitude: Double) {
        self.integrationKey = integrationKey
        self.latitude = latitude
        self.longitude = longitude
    }
}

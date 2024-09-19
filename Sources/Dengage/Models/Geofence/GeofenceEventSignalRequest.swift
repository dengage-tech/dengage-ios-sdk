import Foundation

public struct GeofenceEventSignalRequest: APIRequest {
    
    public typealias Response = EmptyResponse
    
    public let method: HTTPMethod = .post
    public let enpointType: EndpointType = .geofence
    public var path: String {
        "/event-signal/\(integrationKey)"
    }
    
    public let queryParameters: [URLQueryItem] = []
    
    public var httpBody: Data? {
        let parameters = ["cid": clusterId,
                          "geoid": geofenceId,
                          "did": deviceId,
                          "ckey": contactKey,
                          "et": Utilities.convertToString(to: Date()) ??  "",
                          "loc": [ "lat": latitude,
                                   "long": longitude
                                 ],
                          "type": type,
                          "token": token,
                          "permit": permit] as [String: Any]
        
        return parameters.json
    }
    
    let integrationKey: String
    let clusterId: Int
    let geofenceId: Int
    let deviceId: String
    let contactKey: String
    let latitude: Double
    let longitude: Double
    let type: String
    let token: String
    let permit: Bool
    
    public init(integrationKey: String,
         clusterId: Int,
         geofenceId: Int,
         deviceId: String,
         contactKey: String,
         latitude: Double,
         longitude: Double,
         type: String,
         token: String,
         permit: Bool) {
        self.integrationKey = integrationKey
        self.clusterId = clusterId
        self.geofenceId = geofenceId
        self.deviceId = deviceId
        self.contactKey = contactKey
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.token = token
        self.permit = permit
    }
}

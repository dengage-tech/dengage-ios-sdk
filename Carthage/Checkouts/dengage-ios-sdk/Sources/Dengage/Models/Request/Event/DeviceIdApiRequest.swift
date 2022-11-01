
import Foundation
struct DeviceIdApiRequest: APIRequest {

    typealias Response = EmptyResponse

    let method: HTTPMethod = .post
    let enpointType: EndpointType = .deviceId
    var path: String = DengageLocalStorage.shared.value(for: .deviceIdRoute) as! String
    let queryParameters: [URLQueryItem] = []
    
    var httpBody: Data?{
        let parameters = ["device_id": device_id] as [String : Any]
        return parameters.json
    }
    
    var headers: [String : String]?
    {
        return ["Authorization":"Bearer \(token)"]
    }

    let device_id: String
    let token: String

    

}


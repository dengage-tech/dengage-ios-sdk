import Foundation
struct TagsRequest: APIRequest {
    typealias Response = EmptyResponse

    let method: HTTPMethod = .post
    let enpointType: EndpointType = .push
    let path: String = "/api/setTags"
    let queryParameters: [URLQueryItem] = []
    
    var httpBody: Data? {
        let parameters = ["accountName": accountName,
                          "key": key,
                          "tags": tags.map{$0.parameters}] as [String : Any]
        return parameters.json
    }

    let accountName: String
    let key:String
    let tags:[TagItem]
}

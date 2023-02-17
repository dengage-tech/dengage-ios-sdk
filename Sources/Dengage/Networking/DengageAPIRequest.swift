import Foundation

fileprivate let defaultHeaders: [String: String] = [
    "Content-Type": "application/json",
    "Accept": "application/json",
]

typealias APIResponse = Decodable

struct EmptyResponse: Decodable { }

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

enum EndpointType{
    case event, push , deviceId, inapp
}

protocol APIRequest {
    var enpointType: EndpointType{ get }
    var path: String { get }
    var httpBody: Data? { get }
    var queryParameters: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    
    associatedtype Response: APIResponse
}
extension APIRequest{
    var httpBody: Data?{
        return nil
    }
    
    var headers: [String: String]?{
        return nil
    }
}
extension APIRequest {
    func asURLRequest(with baseURL:URL) -> URLRequest {
        var urlComps = URLComponents(string: baseURL.absoluteString + path)!
        urlComps.queryItems = queryParameters.filter { $0.value != nil }
        urlComps.percentEncodedQuery = urlComps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var urlRequest = URLRequest(url: urlComps.url!)
        let headers = bindDefaultHeaders(with: headers)
        headers.forEach{ header in
            urlRequest.setValue(header.value,forHTTPHeaderField: header.key)
        }
        if let httpBody = httpBody {
            urlRequest.httpBody = httpBody
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
    
    func bindDefaultHeaders(with headers: [String: String]?) -> [String: String]{
        var requestHeaders = [String: String]()
        defaultHeaders.forEach { key, value  in
            requestHeaders[key] = value
        }
        
        if let headers = headers {
            headers.forEach { key, value in
                requestHeaders[key] = value
            }
        }
        
        return requestHeaders
    }
}

extension Dictionary {
    var json: Data? {
        try? JSONSerialization.data(withJSONObject: self)
    }
}
extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}


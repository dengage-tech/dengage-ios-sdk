import Foundation

final class DengageNetworking {

    let config: DengageConfiguration
    let session: URLSession
    
    init(config: DengageConfiguration,
         session: URLSession = .shared) {
        
        self.config  = config
        self.session = session
    }

    func send<T: APIRequest>(request: T, completion: @escaping (Result<T.Response, Error>) -> Void) {
        let decoder = JSONDecoder()
        let baseURL = createBaseURL(for: request.enpointType)
        var apiRequest = request.asURLRequest(with: baseURL)
        apiRequest.setValue(config.userAgent, forHTTPHeaderField: "User-Agent")
        
        Logger.log(message: "API REQUEST URL", argument: "\(apiRequest)")

        
        if let body = apiRequest.httpBody {
            Logger.log(message: "HTTP REQUEST BODY:\n", argument: body.pretty)
        }
        
        let dataTask = session.dataTask(with: apiRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ServiceError.noHttpResponse))
                return
            }

            if let data = data  {
                Logger.log(message: "HTTP API RESPONSE:\n", argument: data.pretty)
            }
            Logger.log(message: "HTTP API STATUS CODE:\n", argument: httpResponse.statusCode.description)
            switch httpResponse.statusCode {
            case 200..<300:
                guard let data = data else {
                    completion(.failure(ServiceError.noData))
                    return
                }
                
                do{
                    let responseObject = try decoder.decode(T.Response.self, from: data)
                    completion(.success(responseObject))
                    
                }catch let decodingError {
                    
                    if httpResponse.statusCode == 200
                    {
                        Logger.log(message: "HTTP API STATUS CODE:\n", argument: httpResponse.statusCode.description)
                        completion(.failure(ServiceError.noData))

                    }
                    else
                    {
                        completion(.failure(ServiceError.decoding(decodingError)))

                    }
                }
            default:
                Logger.log(message: "API ERROR", argument: apiRequest.url?.absoluteString ?? "") //todo handle optional
                Logger.log(message: "RESPONSE STATUS:", argument: "\(httpResponse.statusCode)")
                Logger.log(message: "REQUEST:", argument: "\(String(describing: type(of: request)))")
                completion(.failure(ServiceError.fail(httpResponse.statusCode)))
            }
        }
        dataTask.resume()
    }
    
    func createBaseURL(for endpointType:EndpointType) -> URL{
        switch endpointType {
        case .event:
            return config.eventURL
        case .push:
            return config.subscriptionURL
        case .deviceId:
            return config.dengageDeviceIdApiUrl
        case .inapp:
            return config.inAppURL
        }
    }
}

internal enum ServiceError: Error {
    case invalidRefreshToken
    case noHttpResponse
    case noData
    case socialMediaReauth
    case fail(Int)
    case decoding(Error)
}

// MARK: - Extensions
extension Data {
    var pretty: String {
        guard let json = try? JSONSerialization.jsonObject(with: self) else { return "" }
        let options: JSONSerialization.WritingOptions
        if #available(iOS 13.0, *) {
            options = [.prettyPrinted, .withoutEscapingSlashes]
        } else {
            options = [.prettyPrinted]
        }
        let data = try! JSONSerialization.data(withJSONObject: json, options: options)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

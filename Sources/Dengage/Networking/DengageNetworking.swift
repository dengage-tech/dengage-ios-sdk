import Foundation

final public class DengageNetworking {
    
    let config: DengageConfiguration
    let session: URLSession
    
    init(config: DengageConfiguration,
         session: URLSession = .shared) {
        
        self.config  = config
        self.session = session
    }
    
    public func send<T: APIRequest>(request: T, completion: @escaping (Result<T.Response, Error>) -> Void) {
        let decoder = JSONDecoder()
        let baseURL = createBaseURL(for: request.endpointType)
        var apiRequest = request.asURLRequest(with: baseURL)
        apiRequest.setValue(config.userAgent, forHTTPHeaderField: "User-Agent")
        
        
        if let body = apiRequest.httpBody {
            Logger.log(message: "HTTP REQUEST BODY:\n for API \(apiRequest.url)", argument: body.pretty)
        }else
        {
            Logger.log(message: "HTTP REQUEST BODY:\n for API \(apiRequest.url)", argument: "")

        }
        
        let dataTask = session.dataTask(with: apiRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ServiceError.noHttpResponse))
                return
            }
            
            if let data = data  {
                
                Logger.log(message: "HTTP API RESPONSE:\n for API \(apiRequest.url)", argument: data.pretty)
            }
            
            Logger.log(message: "HTTP API STATUS CODE:\n", argument: httpResponse.statusCode.description)
            switch httpResponse.statusCode {
            case 200..<300:
                guard let data = data else {
                    completion(.failure(ServiceError.noData))
                    return
                }
                
                do{
                    if T.Type.self == EventRequest.Type.self || T.Type.self == DebugLogRequest.Type.self {
                        let encodedJSON = try JSONEncoder().encode("{}")
                        
                        let responseObject = try decoder.decode(T.Response.self, from: encodedJSON)
                        completion(.success(responseObject))
                        
                    } else {
                        let responseObject = try decoder.decode(T.Response.self, from: data)
                        completion(.success(responseObject))
                        
                    }
                    
                    
                    
                    
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

    /// `GET /geofences/sync` — ETag/304 farkındalıklı (contract §1). Generic `send` 304'ü ve
    /// response header'larını ayırt edemediği için ayrı bir yol kullanılır.
    public func sendGeofenceSync(request: GeofenceSyncRequest,
                                 completion: @escaping (Result<GeofenceSyncResult, Error>) -> Void) {
        let baseURL = createBaseURL(for: request.endpointType)
        var apiRequest = request.asURLRequest(with: baseURL)
        apiRequest.setValue(config.userAgent, forHTTPHeaderField: "User-Agent")

        let urlString = apiRequest.url?.absoluteString ?? ""
        Logger.log(message: "HTTP GEOFENCE SYNC REQUEST:\n \(apiRequest.httpMethod ?? "GET") \(urlString)",
                   argument: apiRequest.value(forHTTPHeaderField: "If-None-Match") ?? "")

        let task = session.dataTask(with: apiRequest) { data, response, _ in
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(ServiceError.noHttpResponse))
                return
            }
            Logger.log(message: "HTTP GEOFENCE SYNC STATUS:\n for \(urlString)",
                       argument: http.statusCode.description)
            if http.statusCode == 304 {
                completion(.success(.notModified))
                return
            }
            switch http.statusCode {
            case 200..<300:
                guard let data = data else {
                    completion(.failure(ServiceError.noData))
                    return
                }
                Logger.log(message: "HTTP GEOFENCE SYNC RESPONSE:\n for \(urlString)", argument: data.pretty)
                do {
                    let decoded = try JSONDecoder().decode(GeofenceSyncResponse.self, from: data)
                    let etag = DengageNetworking.headerValue(http, "ETag") ?? decoded.etag
                    completion(.success(.updated(decoded, etag: etag)))
                } catch let decodingError {
                    completion(.failure(ServiceError.decoding(decodingError)))
                }
            default:
                completion(.failure(ServiceError.fail(http.statusCode)))
            }
        }
        task.resume()
    }

    /// HTTP header'ı case-insensitive okur (iOS 10+ uyumlu; `value(forHTTPHeaderField:)` iOS 13+).
    private static func headerValue(_ response: HTTPURLResponse, _ name: String) -> String? {
        for (key, value) in response.allHeaderFields {
            if let key = key as? String, key.caseInsensitiveCompare(name) == .orderedSame {
                return value as? String
            }
        }
        return nil
    }

    func createBaseURL(for endpointType:EndpointType) -> URL{
        
        switch endpointType {
        case .event:
            return config.eventURL
        case .push:
            return config.subscriptionURL
        case .geofence:
            return config.geofenceURL
        case .deviceId:
            return config.dengageDeviceIdApiUrl
        case .inapp:
            return config.inAppURL
        case .inappRealTime:
            return config.inAppRealTimeURL
        case .liveActivity:
            return config.liveActivityURL
            
        }
    }
}

public enum ServiceError: Error {
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

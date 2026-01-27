import Foundation

/// Handler for HTTP requests from WebView
final class HttpRequestHandler: AsyncBridgeHandler {

    private let inAppMessage: InAppMessage?
    private let session: URLSession

    init(inAppMessage: InAppMessage? = nil) {
        self.inAppMessage = inAppMessage

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    struct HttpRequestPayload: Decodable {
        let url: String
        let method: String?
        let headers: [String: String]?
        let body: String?
        let queryParams: [String: String]?
        let contentType: String?

        var httpMethod: String {
            return method?.uppercased() ?? "GET"
        }
    }

    struct HttpResponse: Encodable {
        let statusCode: Int
        let body: AnyCodable?
        let headers: [String: String]
    }

    func supportedActions() -> [String] {
        return ["httpRequest"]
    }

    func handle(message: BridgeMessage, callback: BridgeCallback) {
        guard let payloadData = message.payload?.data(using: .utf8),
              let payload = try? JSONDecoder().decode(HttpRequestPayload.self, from: payloadData) else {
            callback.onError(errorCode: BridgeErrorCodes.invalidPayload, errorMessage: "Invalid HTTP request payload")
            return
        }

        let processedUrl = replaceVariables(payload.url)

        guard var urlComponents = URLComponents(string: processedUrl) else {
            callback.onError(errorCode: BridgeErrorCodes.invalidPayload, errorMessage: "Invalid URL: \(processedUrl)")
            return
        }

        // Add query parameters
        if let queryParams = payload.queryParams {
            var queryItems = urlComponents.queryItems ?? []
            for (key, value) in queryParams {
                let processedValue = replaceVariables(value)
                queryItems.append(URLQueryItem(name: key, value: processedValue))
            }
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            callback.onError(errorCode: BridgeErrorCodes.invalidPayload, errorMessage: "Failed to construct URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = payload.httpMethod

        // Add headers
        if let headers = payload.headers {
            for (key, value) in headers {
                let processedValue = replaceVariables(value)
                request.setValue(processedValue, forHTTPHeaderField: key)
            }
        }

        // Add body for POST/PUT/PATCH
        if let body = payload.body, ["POST", "PUT", "PATCH"].contains(payload.httpMethod) {
            let processedBody = replaceVariables(body)
            request.httpBody = processedBody.data(using: .utf8)
            let contentType = payload.contentType ?? "application/json"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.log(message: "HttpRequestHandler error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    callback.onError(errorCode: BridgeErrorCodes.httpError, errorMessage: error.localizedDescription)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    callback.onError(errorCode: BridgeErrorCodes.httpError, errorMessage: "Invalid response")
                }
                return
            }

            // Parse response headers
            var responseHeaders: [String: String] = [:]
            for (key, value) in httpResponse.allHeaderFields {
                if let keyString = key as? String, let valueString = value as? String {
                    responseHeaders[keyString] = valueString
                }
            }

            // Parse response body
            var parsedBody: Any? = nil
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    parsedBody = jsonObject
                } else if let stringBody = String(data: data, encoding: .utf8) {
                    parsedBody = stringBody
                }
            }

            let httpResponseData: [String: Any] = [
                "statusCode": httpResponse.statusCode,
                "body": parsedBody as Any,
                "headers": responseHeaders
            ]

            DispatchQueue.main.async {
                callback.onSuccess(data: httpResponseData)
            }
        }

        task.resume()
    }

    private func replaceVariables(_ input: String) -> String {
        var result = input

        let integrationKey = Dengage.getIntegrationKey()
        let sdkParams = Dengage.getSdkParameters()
        let deviceId = Dengage.getDeviceId() ?? ""
        let contactKey = Dengage.getContactKey() ?? ""

        result = result.replacingOccurrences(of: "${integrationKey}", with: integrationKey)
        result = result.replacingOccurrences(of: "${accountName}", with: sdkParams?.accountName ?? "")
        result = result.replacingOccurrences(of: "${appId}", with: sdkParams?.appId ?? "")
        result = result.replacingOccurrences(of: "${campaign.publicId}", with: inAppMessage?.data.publicId ?? "")
        result = result.replacingOccurrences(of: "${campaign.content.contentId}", with: inAppMessage?.data.content.contentId ?? "")
        result = result.replacingOccurrences(of: "${visitor.deviceId}", with: deviceId)
        result = result.replacingOccurrences(of: "${visitor.contactKey}", with: contactKey)

        // URL configurations from plist or storage
        if let pushApiUrl = Bundle.main.object(forInfoDictionaryKey: "DengageApiUrl") as? String {
            result = result.replacingOccurrences(of: "${pushApiBaseUrl}", with: pushApiUrl)
        }
        if let eventApiUrl = Bundle.main.object(forInfoDictionaryKey: "DengageEventApiUrl") as? String {
            result = result.replacingOccurrences(of: "${eventApiBaseUrl}", with: eventApiUrl)
        }
        if let inAppApiUrl = Bundle.main.object(forInfoDictionaryKey: "DengageInAppApiUrl") as? String {
            result = result.replacingOccurrences(of: "${inAppApiBaseUrl}", with: inAppApiUrl)
        }
        if let geofenceApiUrl = Bundle.main.object(forInfoDictionaryKey: "DengageGeofenceApiUrl") as? String {
            result = result.replacingOccurrences(of: "${geofenceApiBaseUrl}", with: geofenceApiUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        }
        if let realTimeApiUrl = Bundle.main.object(forInfoDictionaryKey: "fetchRealTimeINAPPURL") as? String {
            result = result.replacingOccurrences(of: "${getRealTimeMessagesBaseUrl}", with: realTimeApiUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        }

        return result
    }
}

import Foundation

/// Handler for recommendation requests from WebView.
/// Collects user behavior data, sends a POST request to the Recommendation API,
/// and returns the recommendation response back to the bridge.
/// Mirrors dengage-android-sdk RecommendationHandler.
final class RecommendationHandler: AsyncBridgeHandler {

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func supportedActions() -> [String] {
        return ["getRecommendation"]
    }

    func handle(message: BridgeMessage, callback: BridgeCallback) {
        let payload = parsePayload(message.payload)

        guard let containerKey = payload["containerKey"] as? String, !containerKey.isEmpty else {
            callback.onError(
                errorCode: BridgeErrorCodes.invalidPayload,
                errorMessage: "containerKey is required in payload"
            )
            return
        }

        guard let accountName = Dengage.getSdkParameters()?.accountName, !accountName.isEmpty else {
            callback.onError(
                errorCode: BridgeErrorCodes.internalError,
                errorMessage: "accountName is missing"
            )
            return
        }

        guard let baseUrl = resolvePushApiBaseUrl() else {
            callback.onError(
                errorCode: BridgeErrorCodes.internalError,
                errorMessage: "pushApiBaseUrl is missing"
            )
            return
        }

        let trimmed = baseUrl.hasSuffix("/") ? String(baseUrl.dropLast()) : baseUrl
        guard let url = URL(string: "\(trimmed)/rc/\(accountName)/recommendations/\(containerKey)/ios") else {
            callback.onError(
                errorCode: BridgeErrorCodes.invalidPayload,
                errorMessage: "Invalid URL for recommendation request"
            )
            return
        }

        let body: [String: Any] = buildRequestBody(payload: payload)

        guard JSONSerialization.isValidJSONObject(body),
              let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            callback.onError(
                errorCode: BridgeErrorCodes.internalError,
                errorMessage: "Failed to serialize recommendation request body"
            )
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData

        Logger.log(message: "RecommendationHandler request URL: \(url.absoluteString)")

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.log(message: "RecommendationHandler error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    callback.onError(
                        errorCode: BridgeErrorCodes.httpError,
                        errorMessage: error.localizedDescription
                    )
                }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    callback.onError(
                        errorCode: BridgeErrorCodes.httpError,
                        errorMessage: "Invalid response"
                    )
                }
                return
            }

            let rawBody: String? = data.flatMap { String(data: $0, encoding: .utf8) }

            Logger.log(message: "RecommendationHandler response (\(http.statusCode)) for \(url.absoluteString): \(rawBody ?? "<empty>")")

            guard (200..<300).contains(http.statusCode) else {
                Logger.log(message: "RecommendationHandler error: \(http.statusCode) - \(rawBody ?? "")")
                DispatchQueue.main.async {
                    callback.onError(
                        errorCode: BridgeErrorCodes.httpError,
                        errorMessage: "Recommendation request failed with status \(http.statusCode): \(rawBody ?? "")"
                    )
                }
                return
            }

            var parsedBody: Any? = nil
            if let data = data {
                if var parsed = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let requestId = parsed["requestId"] {
                        parsed["rid"] = requestId
                    }
                    parsedBody = parsed
                } else {
                    parsedBody = rawBody
                }
            }

            DispatchQueue.main.async {
                callback.onSuccess(data: parsedBody)
            }
        }
        task.resume()
    }

    private func parsePayload(_ payloadJson: String?) -> [String: Any] {
        guard let payloadJson = payloadJson,
              let data = payloadJson.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return [:]
        }
        return json
    }

    private func buildRequestBody(payload: [String: Any]) -> [String: Any] {
        let config = Dengage.dengage?.config
        let cart = config?.getCart()
        let cartProductIds = cart?.items.map { $0.productId } ?? []

        var body: [String: Any] = [:]
        body["did"] = Dengage.getDeviceId() ?? ""
        body["ck"] = config?.getContactKey() ?? NSNull()
        body["cp"] = config?.getLastProductId() ?? NSNull()
        body["cid"] = config?.realTimeCategoryPath ?? NSNull()

        if !cartProductIds.isEmpty {
            body["crp"] = cartProductIds
        }
        let lastViewedProducts = config?.getLastViewedProducts() ?? []
        if !lastViewedProducts.isEmpty {
            body["lvp"] = lastViewedProducts
        }
        let lastViewedCategories = config?.getLastViewedCategories() ?? []
        if !lastViewedCategories.isEmpty {
            body["lvc"] = lastViewedCategories
        }
        let lastPurchasedProducts = config?.lastPurchasedProducts ?? []
        if !lastPurchasedProducts.isEmpty {
            body["lpp"] = lastPurchasedProducts
        }
        let lastPurchasedCategories = config?.lastPurchasedCategories ?? []
        if !lastPurchasedCategories.isEmpty {
            body["lpc"] = lastPurchasedCategories
        }

        let keyMapping: [String: String] = ["maxRecommendationCount": "mrc"]
        for (key, value) in payload {
            if key == "containerKey" { continue }
            let mappedKey = keyMapping[key] ?? key
            body[mappedKey] = value
        }

        return body
    }

    private func resolvePushApiBaseUrl() -> String? {
        if let configured = DengageLocalStorage.shared.getApiUrlConfiguration()?.denPushApiUrl,
           !configured.isEmpty {
            return configured
        }
        return Bundle.main.object(forInfoDictionaryKey: "DengageApiUrl") as? String
    }
}

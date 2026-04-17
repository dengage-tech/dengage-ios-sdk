import Foundation

/// Handler for recommendation impression/click events fired from WebView.
/// Mirrors the batching logic of dengage.websdk / dengage-android-sdk:
/// events are accumulated per (deviceId, contactKey, sessionId) tuple and
/// flushed via a single POST /re/{accountName}/reco-events/batch request
/// after a short debounce.
final class RecommendationEventHandler: AsyncBridgeHandler {

    private final class Batch {
        let id: String
        var payload: [String: Any]
        var events: [[String: Any]] = []
        var flushWorkItem: DispatchWorkItem?

        init(id: String, payload: [String: Any]) {
            self.id = id
            self.payload = payload
        }
    }

    private static let flushDelay: TimeInterval = 0.5

    private let queue = DispatchQueue(label: "com.dengage.sdk.recommendationEventHandler", qos: .utility)
    private var batches: [String: Batch] = [:]
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func supportedActions() -> [String] {
        return [
            "sendRecommendationImpressionEvent",
            "sendRecommendationClickEvent"
        ]
    }

    func handle(message: BridgeMessage, callback: BridgeCallback) {
        let args = parseArgs(payload: message.payload)
        guard args.count >= 3 else {
            callback.onError(
                errorCode: BridgeErrorCodes.invalidPayload,
                errorMessage: "Expected (recommendationRequestId, containerKey, itemIds)"
            )
            return
        }

        let eventType: String
        switch message.action {
        case "sendRecommendationImpressionEvent": eventType = "IM"
        case "sendRecommendationClickEvent": eventType = "CL"
        default:
            callback.onError(
                errorCode: BridgeErrorCodes.invalidPayload,
                errorMessage: "Unknown action \(message.action)"
            )
            return
        }

        let recommendationRequestId = stringify(args[0])
        let containerKey = stringify(args[1])
        let rawItemIds = args[2]

        let event = buildEvent(
            eventType: eventType,
            recommendationRequestId: recommendationRequestId,
            containerKey: containerKey,
            rawItemIds: rawItemIds
        )

        enqueue(event: event)

        callback.onSuccess(data: true)
    }

    private func parseArgs(payload: String?) -> [Any] {
        guard let payload = payload,
              let data = payload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return [] }

        if let args = json["args"] as? [Any] {
            return args
        }
        return []
    }

    private func stringify(_ value: Any?) -> String? {
        guard let value = value, !(value is NSNull) else { return nil }
        if let s = value as? String { return s }
        return "\(value)"
    }

    private func buildEvent(
        eventType: String,
        recommendationRequestId: String?,
        containerKey: String?,
        rawItemIds: Any?
    ) -> [String: Any] {
        var event: [String: Any] = [
            "t": eventType,
            "rid": recommendationRequestId as Any,
            "ck2": containerKey as Any
        ]

        let itemIdList: [Any]
        if rawItemIds == nil || rawItemIds is NSNull {
            itemIdList = []
        } else if let list = rawItemIds as? [Any] {
            itemIdList = list
        } else if let value = rawItemIds {
            itemIdList = [value]
        } else {
            itemIdList = []
        }

        let isSingleItem = itemIdList.count == 1

        if eventType == "IM" || !isSingleItem {
            event["pids"] = itemIdList.map { stringify($0) ?? nil }
        } else if let first = itemIdList.first {
            event["pid"] = stringify(first) as Any
        }

        return event
    }

    private func enqueue(event: [String: Any]) {
        let deviceId = Dengage.getDeviceId() ?? ""
        let contactKey = Dengage.getContactKey() ?? ""
        let sessionId = Dengage.dengage?.sessionManager.currentSessionId ?? ""

        let batchId = [deviceId, contactKey, sessionId].joined(separator: "_")

        var mutableEvent = event
        mutableEvent["ts"] = Int(Date().timeIntervalSince1970 * 1000)

        queue.async { [weak self] in
            guard let self = self else { return }

            let batch: Batch
            if let existing = self.batches[batchId] {
                batch = existing
            } else {
                let payload: [String: Any] = [
                    "p": "ios",
                    "did": deviceId,
                    "ck": contactKey.isEmpty ? NSNull() : contactKey,
                    "sid": sessionId.isEmpty ? NSNull() : sessionId,
                    "events": [[String: Any]]()
                ]
                batch = Batch(id: batchId, payload: payload)
                self.batches[batchId] = batch
            }

            let alreadyQueued = batch.events.contains { self.eventsEqual($0, mutableEvent) }
            if !alreadyQueued {
                batch.events.append(mutableEvent)
            }

            batch.flushWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.flush(batchId: batchId)
            }
            batch.flushWorkItem = workItem
            self.queue.asyncAfter(deadline: .now() + RecommendationEventHandler.flushDelay, execute: workItem)
        }
    }

    private func eventsEqual(_ lhs: [String: Any], _ rhs: [String: Any]) -> Bool {
        return (lhs as NSDictionary).isEqual(to: rhs)
    }

    private func flush(batchId: String) {
        queue.async { [weak self] in
            guard let self = self, let batch = self.batches.removeValue(forKey: batchId) else { return }
            guard !batch.events.isEmpty else { return }

            var payload = batch.payload
            payload["events"] = batch.events

            guard let accountName = Dengage.getSdkParameters()?.accountName, !accountName.isEmpty else {
                Logger.log(message: "RecommendationEventHandler: accountName missing, dropping batch")
                return
            }

            guard let baseUrl = self.resolvePushApiBaseUrl() else {
                Logger.log(message: "RecommendationEventHandler: pushApiBaseUrl missing, dropping batch")
                return
            }

            let trimmed = baseUrl.hasSuffix("/") ? String(baseUrl.dropLast()) : baseUrl
            guard let url = URL(string: "\(trimmed)/re/\(accountName)/reco-events/batch") else {
                Logger.log(message: "RecommendationEventHandler: invalid URL")
                return
            }

            guard JSONSerialization.isValidJSONObject(payload),
                  let body = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
                Logger.log(message: "RecommendationEventHandler: failed to serialize payload")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body

            let bodyString = String(data: body, encoding: .utf8) ?? ""
            Logger.log(message: "RecommendationEventHandler flush URL: \(url.absoluteString) body: \(bodyString)")

            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    Logger.log(message: "RecommendationEventHandler flush error: \(error.localizedDescription)")
                    return
                }
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    let bodyStr = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                    Logger.log(message: "RecommendationEventHandler flush failed: \(http.statusCode) - \(bodyStr)")
                }
            }
            task.resume()
        }
    }

    private func resolvePushApiBaseUrl() -> String? {
        if let configured = DengageLocalStorage.shared.getApiUrlConfiguration()?.denPushApiUrl,
           !configured.isEmpty {
            return configured
        }
        return Bundle.main.object(forInfoDictionaryKey: "DengageApiUrl") as? String
    }
}

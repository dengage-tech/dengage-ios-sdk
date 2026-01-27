import Foundation
import WebKit

/// Main bridge class that exposes native functionality to WebView JavaScript
final class DengageBridge: NSObject {

    static let bridgeName = "DengageBridgeNative"

    private weak var webView: WKWebView?
    private let handlerRegistry: BridgeHandlerRegistry

    private init(webView: WKWebView, handlerRegistry: BridgeHandlerRegistry) {
        self.webView = webView
        self.handlerRegistry = handlerRegistry
        super.init()
    }

    /// Attach the bridge to a WKWebView
    /// - Parameters:
    ///   - webView: The WKWebView to attach to
    ///   - handlerRegistry: Custom handler registry
    /// - Returns: DengageBridge instance
    @discardableResult
    static func attach(to webView: WKWebView, handlerRegistry: BridgeHandlerRegistry) -> DengageBridge {
        let bridge = DengageBridge(webView: webView, handlerRegistry: handlerRegistry)

        let contentController = webView.configuration.userContentController

        // Add message handlers for bridge communication
        contentController.add(bridge, name: "dengageBridgeFire")
        contentController.add(bridge, name: "dengageBridgeCall")
        contentController.add(bridge, name: "dengageBridgeCallSync")

        return bridge
    }

    /// Get the handler registry
    func getHandlerRegistry() -> BridgeHandlerRegistry {
        return handlerRegistry
    }

    /// Fire and forget - no response callback
    private func fire(action: String, payloadJson: String?) {
        Logger.log(message: "Bridge fire: action=\(action)")

        let message = BridgeMessage(
            callId: "",
            action: action,
            payload: payloadJson,
            type: .fireForget
        )

        guard let handler = handlerRegistry.getHandler(for: action) as? FireAndForgetHandler else {
            Logger.log(message: "No fire-and-forget handler found for action: \(action)")
            return
        }

        handler.handle(message: message)
    }

    /// Async call with callback
    private func call(action: String, payloadJson: String?, callId: String) {
        Logger.log(message: "Bridge call: action=\(action), callId=\(callId)")

        let message = BridgeMessage(
            callId: callId,
            action: action,
            payload: payloadJson,
            type: .async
        )

        guard let handler = handlerRegistry.getHandler(for: action) as? AsyncBridgeHandler else {
            sendResponse(BridgeResponse.error(
                callId: callId,
                errorCode: BridgeErrorCodes.handlerNotFound,
                errorMessage: "No async handler found for action: \(action)"
            ))
            return
        }

        let callback = BridgeCallbackImpl(
            onSuccess: { [weak self] data in
                self?.sendResponse(BridgeResponse.success(callId: callId, data: data))
            },
            onError: { [weak self] errorCode, errorMessage in
                self?.sendResponse(BridgeResponse.error(callId: callId, errorCode: errorCode, errorMessage: errorMessage))
            }
        )

        handler.handle(message: message, callback: callback)
    }

    /// Synchronous call - returns immediately
    private func callSync(action: String, payloadJson: String?) -> String {
        Logger.log(message: "Bridge callSync: action=\(action)")

        let message = BridgeMessage(
            callId: "",
            action: action,
            payload: payloadJson,
            type: .sync
        )

        guard let handler = handlerRegistry.getHandler(for: action) as? SyncBridgeHandler else {
            let response = BridgeResponse.error(
                callId: "",
                errorCode: BridgeErrorCodes.handlerNotFound,
                errorMessage: "No sync handler found for action: \(action)"
            )
            return encodeResponse(response)
        }

        let response = handler.handleSync(message: message)
        return encodeResponse(response)
    }

    /// Send response back to JavaScript
    private func sendResponse(_ response: BridgeResponse) {
        let responseJson = encodeResponse(response)
        let js = "window.DengageBridge && window.DengageBridge._handleNativeResponse(\(responseJson))"

        DispatchQueue.main.async { [weak self] in
            self?.webView?.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    private func encodeResponse(_ response: BridgeResponse) -> String {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(response)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            Logger.log(message: "Failed to encode bridge response: \(error)")
            return "{}"
        }
    }
}

// MARK: - WKScriptMessageHandler
extension DengageBridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            Logger.log(message: "Invalid bridge message body")
            return
        }

        let action = body["action"] as? String ?? ""
        let payloadJson = body["payload"] as? String
        let callId = body["callId"] as? String ?? ""

        switch message.name {
        case "dengageBridgeFire":
            fire(action: action, payloadJson: payloadJson)

        case "dengageBridgeCall":
            call(action: action, payloadJson: payloadJson, callId: callId)

        case "dengageBridgeCallSync":
            let result = callSync(action: action, payloadJson: payloadJson)
            // For sync calls, we need to return the result via a callback
            let js = "window.DengageBridge && window.DengageBridge._handleSyncResponse('\(callId)', \(result))"
            DispatchQueue.main.async { [weak self] in
                self?.webView?.evaluateJavaScript(js, completionHandler: nil)
            }

        default:
            break
        }
    }
}

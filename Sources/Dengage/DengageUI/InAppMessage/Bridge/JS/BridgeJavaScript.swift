import Foundation
import WebKit

/// JavaScript code to be injected into WebView for bridge communication
struct BridgeJavaScript {

    /// JavaScript code that creates the DengageBridge interface on window
    static let bridgeCode = """
        (function() {
            // Prevent double initialization
            if (window.DengageBridge && window.DengageBridge._initialized) {
                return;
            }

            var callbackId = 0;
            var callbacks = {};
            var syncCallbacks = {};

            window.DengageBridge = {
                _initialized: true,

                /**
                 * Fire and forget - no response expected
                 * @param {string} action - The action name
                 * @param {object} payload - The payload object
                 */
                fire: function(action, payload) {
                    var payloadJson = payload ? JSON.stringify(payload) : null;
                    window.webkit.messageHandlers.dengageBridgeFire.postMessage({
                        action: action,
                        payload: payloadJson
                    });
                },

                /**
                 * Async call with callback
                 * @param {string} action - The action name
                 * @param {object} payload - The payload object
                 * @param {function} callback - Callback function(response)
                 */
                call: function(action, payload, callback) {
                    var id = 'cb_' + (++callbackId);
                    callbacks[id] = callback;
                    var payloadJson = payload ? JSON.stringify(payload) : null;
                    window.webkit.messageHandlers.dengageBridgeCall.postMessage({
                        action: action,
                        payload: payloadJson,
                        callId: id
                    });
                },

                /**
                 * Promise-based async call
                 * @param {string} action - The action name
                 * @param {object} payload - The payload object
                 * @returns {Promise} - Resolves with response data
                 */
                callAsync: function(action) {
                    var restArgs = Array.prototype.slice.call(arguments, 1);
                    var payload;
                    if (restArgs.length === 0) {
                        payload = null;
                    } else if (restArgs.length === 1 && restArgs[0] !== null && typeof restArgs[0] === 'object' && !Array.isArray(restArgs[0])) {
                        payload = restArgs[0];
                    } else if (
                        restArgs.length === 2 &&
                        typeof restArgs[0] === 'string' &&
                        (restArgs[1] == null || (typeof restArgs[1] === 'object' && !Array.isArray(restArgs[1])))
                    ) {
                        payload = Object.assign({ containerKey: restArgs[0] }, restArgs[1] || {});
                    } else {
                        payload = { args: restArgs };
                    }
                    var self = this;
                    return new Promise(function(resolve, reject) {
                        self.call(action, payload, function(response) {
                            if (response.success) {
                                //resolve(response.data);
                                resolve(response);
                            } else {
                                reject({
                                    code: response.errorCode,
                                    message: response.errorMessage
                                });
                            }
                        });
                    });
                },

                /**
                 * Synchronous call - uses callback pattern on iOS
                 * @param {string} action - The action name
                 * @param {object} payload - The payload object
                 * @param {function} callback - Callback for result
                 */
                callSync: function(action, payload, callback) {
                    var id = 'sync_' + (++callbackId);
                    syncCallbacks[id] = callback;
                    var payloadJson = payload ? JSON.stringify(payload) : null;
                    window.webkit.messageHandlers.dengageBridgeCallSync.postMessage({
                        action: action,
                        payload: payloadJson,
                        callId: id
                    });
                },

                /**
                 * Internal: Handle native response
                 * @param {object} response - The response from native
                 */
                _handleNativeResponse: function(response) {
                    var callback = callbacks[response.callId];
                    if (callback) {
                        delete callbacks[response.callId];
                        try {
                            callback(response);
                        } catch (e) {
                            console.error('DengageBridge callback error:', e);
                        }
                    }
                },

                /**
                 * Internal: Handle sync response
                 * @param {string} callId - The call ID
                 * @param {object} response - The response from native
                 */
                _handleSyncResponse: function(callId, response) {
                    var callback = syncCallbacks[callId];
                    if (callback) {
                        delete syncCallbacks[callId];
                        try {
                            callback(response);
                        } catch (e) {
                            console.error('DengageBridge sync callback error:', e);
                        }
                    }
                }
            };

            console.log('DengageBridge initialized');
        })();
        """

    /// Inject the bridge JavaScript into a WKWebView
    /// - Parameter webView: The WKWebView to inject into
    static func inject(into webView: WKWebView) {
        webView.evaluateJavaScript(bridgeCode, completionHandler: nil)
    }

    /// Create a WKUserScript for early injection.
    /// Injected at `.atDocumentStart` so that `window.DengageBridge` is defined
    /// BEFORE any inline <script> in the campaign HTML tries to use it.
    static func createUserScript() -> WKUserScript {
        return WKUserScript(
            source: bridgeCode,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
    }
}

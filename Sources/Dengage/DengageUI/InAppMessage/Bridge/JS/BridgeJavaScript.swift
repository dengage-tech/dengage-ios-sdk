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
                callAsync: function(action, payload) {
                    var self = this;
                    return new Promise(function(resolve, reject) {
                        self.call(action, payload, function(response) {
                            if (response.success) {
                                resolve(response.data);
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

            // Legacy Dn compatibility layer
            if (!window.Dn || !window.Dn._nativeInterface) {
                window.Dn = window.Dn || {};

                window.Dn.dismiss = function() {
                    DengageBridge.fire('legacy_dismiss', {});
                };

                window.Dn.iosUrl = function(targetUrl) {
                    DengageBridge.fire('legacy_iosUrl', { targetUrl: targetUrl });
                };

                window.Dn.iosUrlN = function(targetUrl, inAppBrowser, retrieveOnSameLink) {
                    DengageBridge.fire('legacy_iosUrlN', {
                        targetUrl: targetUrl,
                        inAppBrowser: inAppBrowser,
                        retrieveOnSameLink: retrieveOnSameLink
                    });
                };

                window.Dn.androidUrl = function(targetUrl) {
                    DengageBridge.fire('legacy_androidUrl', { targetUrl: targetUrl });
                };

                window.Dn.androidUrlN = function(targetUrl, inAppBrowser, retrieveOnSameLink) {
                    DengageBridge.fire('legacy_androidUrlN', {
                        targetUrl: targetUrl,
                        inAppBrowser: inAppBrowser,
                        retrieveOnSameLink: retrieveOnSameLink
                    });
                };

                window.Dn.sendClick = function(buttonId, buttonType) {
                    DengageBridge.fire('legacy_sendClick', { buttonId: buttonId, buttonType: buttonType });
                };

                window.Dn.close = function() {
                    DengageBridge.fire('legacy_close', {});
                };

                window.Dn.closeN = function() {
                    DengageBridge.fire('legacy_closeN', {});
                };

                window.Dn.setTags = function(tags) {
                    DengageBridge.fire('legacy_setTags', { tags: tags });
                };

                window.Dn.promptPushPermission = function() {
                    DengageBridge.fire('legacy_promptPushPermission', {});
                };

                window.Dn.showRating = function() {
                    DengageBridge.fire('legacy_showRating', {});
                };

                window.Dn.openSettings = function() {
                    DengageBridge.fire('legacy_openSettings', {});
                };

                window.Dn.copyToClipboard = function(value) {
                    DengageBridge.fire('legacy_copyToClipboard', { value: value });
                };
            }

            console.log('DengageBridge initialized');
        })();
        """

    /// Inject the bridge JavaScript into a WKWebView
    /// - Parameter webView: The WKWebView to inject into
    static func inject(into webView: WKWebView) {
        webView.evaluateJavaScript(bridgeCode, completionHandler: nil)
    }

    /// Create a WKUserScript for early injection
    static func createUserScript() -> WKUserScript {
        return WKUserScript(
            source: bridgeCode,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
    }
}

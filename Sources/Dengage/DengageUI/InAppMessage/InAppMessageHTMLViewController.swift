import UIKit
@preconcurrency import WebKit

final class InAppMessageHTMLViewController: UIViewController {

    private lazy var viewSource: InAppMessageHTMLView = {
        let view = InAppMessageHTMLView()
        view.webView.navigationDelegate = self
        return view
    }()

    var delegate: InAppMessagesActionsDelegate?
    let message: InAppMessage
    let couponCode: String
    var isIosURLNPresent = false
    var isClicked = false

    // DengageBridge support
    private var dengageBridge: DengageBridge?
    private var legacyHandler: LegacyDnHandler?

    var hasTopNotch: Bool {
        if #available(iOS 13.0, *), let _ = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return true
        }
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }

    init(with message: InAppMessage, couponCode: String) {
        self.message = message
        self.couponCode = couponCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = viewSource
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isIosURLNPresent = message.data.content.props.html?.contains("Dn.iosUrlN") ?? false
        setupBridge()
        setupJavascript()
        viewSource.setupConstraints(for: message.data.content.props, message: message)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(sender:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapView(sender: UITapGestureRecognizer) {
        guard message.data.content.props.dismissOnTouchOutside else { return }
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.viewSource.webView.alpha = 0.0
        }, completion: { _ in
            self.delegate?.sendDismissEvent(message: self.message)
            self.delegate?.close()
        })
    }

    private func setupBridge() {
        // Create legacy handler with callbacks
        legacyHandler = LegacyDnHandler(
            delegate: delegate,
            message: message,
            isIosURLNPresent: isIosURLNPresent,
            onClicked: { [weak self] in
                self?.isClicked = true
            },
            onFinish: { [weak self] in
                self?.delegate?.close()
            }
        )

        // Create handler registry and register handlers
        let registry = BridgeHandlerRegistry()
        if let handler = legacyHandler {
            registry.register(handler)
        }
        registry.register(HttpRequestHandler(inAppMessage: message))
        registry.register(DeviceInfoHandler())
        registry.register(StorageHandler())

        // Attach bridge to webView
        dengageBridge = DengageBridge.attach(to: viewSource.webView, handlerRegistry: registry)
    }

    private func setupJavascript() {
        let contentController = viewSource.webView.configuration.userContentController

        // Add bridge JavaScript as user script
        let bridgeScript = BridgeJavaScript.createUserScript()
        contentController.addUserScript(bridgeScript)

        // Keep legacy interface for backwards compatibility
        let legacyScript = WKUserScript(
            source: javascriptInterface,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(legacyScript)

        if #available(iOS 14.0, *) {
            viewSource.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            viewSource.webView.configuration.preferences.javaScriptEnabled = true
        }

        // Keep legacy message handlers for backwards compatibility
        ["dismiss",
         "close",
         "closeN",
         "iosUrl",
         "iosUrlN",
         "sendClick",
         "promptPushPermission",
         "openSettings",
         "setTags",
         "copyToClipboard",
         "consoleLog"
        ].forEach {
            contentController.add(self, name: $0)
        }

        // Add console.log bridge script
        let consoleScript = WKUserScript(
            source: consoleLogBridge,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(consoleScript)

        if let htmlString = message.data.content.props.html {

            var processedHtml = htmlString

            if !couponCode.isEmpty, Mustache.hasCouponSection(htmlString) {
                processedHtml = Mustache.replaceCouponSections(processedHtml, couponCode: couponCode)
            }

            let dataDict: [String: Any] = ["dnInAppDeviceInfo": Dengage.getInAppDeviceInfo()]
            let renderedHtml = Mustache.render(processedHtml, dataDict)
            viewSource.webView.loadHTMLString(renderedHtml, baseURL: nil)
        }
        viewSource.webView.contentMode = .scaleAspectFit
        viewSource.webView.sizeToFit()
        viewSource.webView.autoresizesSubviews = true
    }

    /// Update delegate reference in legacy handler
    func updateDelegate(_ newDelegate: InAppMessagesActionsDelegate?) {
        self.delegate = newDelegate
        legacyHandler?.delegate = newDelegate
    }
}

extension InAppMessageHTMLViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.setWebViewHeight()
        // Inject bridge JS after page loads for dynamic content
        BridgeJavaScript.inject(into: webView)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme,
              !scheme.contains("dengage") else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func setWebViewHeight() {
        guard viewSource.webView.url?.absoluteString == "about:blank" else { return }
        viewSource.webView.evaluateJavaScript("document.documentElement.scrollHeight") { height, _ in
            guard let scrollHeight = height as? CGFloat else { return }
            self.viewSource.height?.constant = (scrollHeight > self.viewSource.frame.height)
                ? self.viewSource.frame.height
                : scrollHeight
        }
    }
}

extension InAppMessageHTMLViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        run(message: message)
    }

    private func run(message: WKScriptMessage) {
        switch message.name {
        case "sendClick":
            isClicked = true
            guard let dict = message.body as? [String: Any] else { return }
            let buttonId = dict["buttonId"] as? String ?? ""
            let buttonType = dict["buttonType"] as? String ?? ""
            delegate?.sendClickEvent(message: self.message, buttonId: buttonId, buttonType: buttonType)
        case "iosUrl":
            if !isIosURLNPresent {
                guard let bodyString = message.body as? String else { return }
                if bodyString == "Dn.promptPushPermission()" {
                    delegate?.promptPushPermission()
                } else if bodyString == "DN.SHOWRATING()" {
                    Dengage.showRatingView()
                } else {
                    delegate?.open(url: bodyString)
                }
            }

        case "iosUrlN":
            guard let dict = message.body as? [String: Any] else { return }
            DengageLocalStorage.shared.set(
                value: dict["openInAppBrowser"] as? Bool ?? false,
                for: .openInAppBrowser
            )
            DengageLocalStorage.shared.set(
                value: dict["retrieveLinkOnSameScreen"] as? Bool ?? false,
                for: .retrieveLinkOnSameScreen
            )
            if let deeplink = dict["deeplink"] as? String {
                if deeplink == "Dn.promptPushPermission()" {
                    delegate?.promptPushPermission()
                } else if deeplink == "DN.SHOWRATING()" {
                    Dengage.showRatingView()
                } else {
                    delegate?.open(url: deeplink)
                }
            }

        case "setTags":
            guard let tagItemString = message.body as? String else { return }
            let trimmed = tagItemString.trimmingCharacters(in: .whitespacesAndNewlines)
            let withoutBraces = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "{} "))
            let components = withoutBraces.components(separatedBy: ",")
            var dict = [String: String]()
            for component in components {
                let pair = component.components(separatedBy: ":")
                if pair.count == 2 {
                    let key = pair[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = pair[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    dict[key] = value
                }
            }
            delegate?.setTags(tags: [TagItem(with: dict)])

        case "promptPushPermission":
            delegate?.promptPushPermission()

        case "openSettings":
            delegate?.openApplicationSettings()

        case "copyToClipboard":
            guard let bodyString = message.body as? String else { return }
            UIPasteboard.general.string = bodyString

        case "dismiss":
            if !isClicked {
                isClicked = true
                delegate?.sendDismissEvent(message: self.message)
            }

        case "close":
            if !isClicked {
                isClicked = true
                delegate?.sendDismissEvent(message: self.message)
            }
            if !isIosURLNPresent { delegate?.close() }

        case "closeN":
            if !isClicked {
                isClicked = true
                delegate?.sendDismissEvent(message: self.message)
            }
            delegate?.close()

        case "consoleLog":
            guard let dict = message.body as? [String: Any],
                  let logMessage = dict["message"] as? String else { return }
            let level = dict["level"] as? String ?? "log"
            Logger.log(message: "[WebView \(level)] \(logMessage)")

        default:
            break
        }
    }
}

extension InAppMessageHTMLViewController {

    fileprivate var consoleLogBridge: String {
        """
        (function() {
            var originalConsole = {
                log: console.log,
                warn: console.warn,
                error: console.error,
                info: console.info,
                debug: console.debug
            };

            function sendToNative(level, args) {
                var message = Array.prototype.slice.call(args).map(function(arg) {
                    if (typeof arg === 'object') {
                        try {
                            return JSON.stringify(arg);
                        } catch (e) {
                            return String(arg);
                        }
                    }
                    return String(arg);
                }).join(' ');

                try {
                    window.webkit.messageHandlers.consoleLog.postMessage({
                        level: level,
                        message: message
                    });
                } catch (e) {}
            }

            console.log = function() {
                sendToNative('log', arguments);
                originalConsole.log.apply(console, arguments);
            };

            console.warn = function() {
                sendToNative('warn', arguments);
                originalConsole.warn.apply(console, arguments);
            };

            console.error = function() {
                sendToNative('error', arguments);
                originalConsole.error.apply(console, arguments);
            };

            console.info = function() {
                sendToNative('info', arguments);
                originalConsole.info.apply(console, arguments);
            };

            console.debug = function() {
                sendToNative('debug', arguments);
                originalConsole.debug.apply(console, arguments);
            };
        })();
        """
    }

    fileprivate var javascriptInterface: String {
        """
        var Dn = {
            iosUrl: (url) => {
                window.webkit.messageHandlers.iosUrl.postMessage(url);
            },
            iosUrlN: (url, inbr, ret) => {
                window.webkit.messageHandlers.iosUrlN.postMessage({
                    deeplink: url,
                    openInAppBrowser: inbr,
                    retrieveLinkOnSameScreen: ret
                });
            },
            androidUrl: (url) => {},
            androidUrlN: (url, inbr, ret) => {},
            sendClick: (buttonId, buttonType) => {
                window.webkit.messageHandlers.sendClick.postMessage({buttonId: buttonId, buttonType: buttonType});
            },
            dismiss: () => {
                window.webkit.messageHandlers.dismiss.postMessage(null);
            },
            close: () => {
                window.webkit.messageHandlers.close.postMessage(null);
            },
            closeN: () => {
                window.webkit.messageHandlers.closeN.postMessage(null);
            },
            setTags: (tags) => {
                window.webkit.messageHandlers.setTags.postMessage(tags);
            },
            promptPushPermission: () => {
                window.webkit.messageHandlers.promptPushPermission.postMessage(null);
            },
            openSettings: () => {
                window.webkit.messageHandlers.openSettings.postMessage(null);
            },
            copyToClipboard: (value) => {
                window.webkit.messageHandlers.copyToClipboard.postMessage(value);
            }
        }
        """
    }

}

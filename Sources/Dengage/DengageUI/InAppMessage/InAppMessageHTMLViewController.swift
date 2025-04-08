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
    var isIosURLNPresent = false
    var isClicked = false

    var hasTopNotch: Bool {
        if #available(iOS 13.0, *), let _ = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return true
        }
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }

    init(with message: InAppMessage) {
        self.message = message
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
        setupJavascript()
        viewSource.setupConstraints(for: message.data.content.props, message: message)
        isIosURLNPresent = message.data.content.props.html?.contains("Dn.iosUrlN") ?? false

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

    private func setupJavascript() {
        let userScript = WKUserScript(
            source: javascriptInterface,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        let contentController = viewSource.webView.configuration.userContentController
        contentController.addUserScript(userScript)

        if #available(iOS 14.0, *) {
            viewSource.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            viewSource.webView.configuration.preferences.javaScriptEnabled = true
        }

        ["dismiss",
         "close",
         "closeN",
         "iosUrl",
         "iosUrlN",
         "sendClick",
         "promptPushPermission",
         "openSettings",
         "setTags"
        ].forEach {
            contentController.add(self, name: $0)
        }

        if let htmlString = message.data.content.props.html {
            let dataDict: [String: Any] = ["dnInAppDeviceInfo": Dengage.getInAppDeviceInfo()]
            let renderedHtml = Mustache.render(htmlString, dataDict)
            viewSource.webView.loadHTMLString(renderedHtml, baseURL: nil)
        }
        viewSource.webView.contentMode = .scaleAspectFit
        viewSource.webView.sizeToFit()
        viewSource.webView.autoresizesSubviews = true
    }
}

extension InAppMessageHTMLViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.setWebViewHeight()
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
            let buttonId = message.body as? String
            isClicked = true
            delegate?.sendClickEvent(message: self.message, buttonId: buttonId)

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

        default:
            break
        }
    }
}

extension InAppMessageHTMLViewController {
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
            sendClick: (eventName) => {
                window.webkit.messageHandlers.sendClick.postMessage(eventName);
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
            }
        }
        """
    }

}

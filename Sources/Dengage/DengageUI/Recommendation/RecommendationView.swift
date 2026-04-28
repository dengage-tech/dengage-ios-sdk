import Foundation
import UIKit
import WebKit

/// RecommendationView renders a recommendation in-app (INLINE_CAROUSEL) campaign.
/// Mirrors dengage-android-sdk RecommendationView: it hosts a WKWebView with the
/// DengageBridge attached so the HTML can call getRecommendation /
/// sendRecommendationImpressionEvent / sendRecommendationClickEvent, and exposes
/// a native `Dn` JavaScript interface for the legacy `Dn.*` API used by the
/// campaign HTML.
open class RecommendationView: WKWebView, WKScriptMessageHandler, WKNavigationDelegate {

    weak var delegate: InAppMessagesActionsDelegate?
    var message: InAppMessage?

    /// Called whenever the HTML content reports a new height. Host view controllers
    /// should use this to size the view (e.g. update an owned height constraint and
    /// trigger a layout pass). If nil, the view falls back to managing its own
    /// internal height constraint.
    public var onHeightChange: ((CGFloat) -> Void)?

    private var dengageBridge: DengageBridge?
    private var heightConstraint: NSLayoutConstraint?
    private var reportedContentHeight: CGFloat = 0

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: reportedContentHeight)
    }

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        layer.masksToBounds = true
        navigationDelegate = self

        setupBridge()

        let bridgeScript = BridgeJavaScript.createUserScript()
        configuration.userContentController.addUserScript(bridgeScript)

        // Native `Dn` override. Injected at .atDocumentStart AFTER the bridge
        // script so it wins over any default shim and is ready before inline
        // <script> blocks in the campaign HTML execute.
        let dnScript = WKUserScript(
            source: dnJavaScriptInterface,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(dnScript)

        [
            "dismiss", "close", "closeN",
            "iosUrl", "iosUrlN",
            "androidUrl", "androidUrlN",
            "sendClick",
            "setTags",
            "promptPushPermission",
            "openSettings",
            "copyToClipboard"
        ].forEach { configuration.userContentController.add(self, name: $0) }

        configuration.userContentController.add(self, name: "DnRecommendationView")
        let heightScript = WKUserScript(
            source: heightObserverScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(heightScript)

        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
    }

    private func setupBridge() {
        let registry = BridgeHandlerRegistry()
        registry.register(HttpRequestHandler(inAppMessage: message))
        registry.register(DeviceInfoHandler())
        registry.register(StorageHandler())
        registry.register(RecommendationHandler())
        registry.register(RecommendationEventHandler())

        dengageBridge = DengageBridge.attach(to: self, handlerRegistry: registry)
    }

    /// Populate the recommendation WebView with the campaign HTML.
    /// Mirrors RecommendationView.populateRecommendation on Android.
    internal func populateRecommendation(inAppMessage: InAppMessage) {
        self.message = inAppMessage

        let html = inAppMessage.data.content.props.html ?? ""
        loadHTMLString(html, baseURL: nil)
    }

    func updateDelegate(_ newDelegate: InAppMessagesActionsDelegate?) {
        self.delegate = newDelegate
    }

    // MARK: - Native Dn interface handling

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "DnRecommendationView":
            let height: CGFloat
            if let n = message.body as? NSNumber { height = CGFloat(truncating: n) }
            else if let d = message.body as? Double { height = CGFloat(d) }
            else { return }
            adjustHeight(height)
        case "sendClick":
            
            guard let dict = message.body as? [String: Any] else { return }
            let buttonId = dict["buttonId"] as? String ?? ""
            let buttonType = dict["buttonType"] as? String ?? ""
            if let message = self.message {
                delegate?.sendClickEvent(message: message, buttonId: buttonId, buttonType: buttonType)
            }
        case "iosUrl":
            guard let url = message.body as? String else { return }
            delegate?.open(url: url)

        case "iosUrlN":
            guard let dict = message.body as? [String: Any],
                  let deeplink = dict["deeplink"] as? String else { return }
            DengageLocalStorage.shared.set(
                value: dict["openInAppBrowser"] as? Bool ?? false,
                for: .openInAppBrowser
            )
            DengageLocalStorage.shared.set(
                value: dict["retrieveLinkOnSameScreen"] as? Bool ?? false,
                for: .retrieveLinkOnSameScreen
            )
            delegate?.open(url: deeplink)

        case "copyToClipboard":
            guard let value = message.body as? String else { return }
            UIPasteboard.general.string = value

        // Mirror dengage-android-sdk: tapping a recommendation item navigates
        // but must NOT emit a dismiss event. sendClick / setTags / androidUrl
        // are not applicable in the recommendation context.
        case "dismiss", "close", "closeN",
             "setTags",
             "promptPushPermission",
             "openSettings",
             "androidUrl", "androidUrlN":
            break

        default:
            break
        }
    }

    // MARK: - Height auto-adjust

    private var heightObserverScript: String {
        return """
        (function() {
          var lastHeight = 0;
          function reportHeight() {
            var h = document.body.scrollHeight;
            if (h !== lastHeight && h > 0) {
              lastHeight = h;
              try {
                window.webkit.messageHandlers.DnRecommendationView.postMessage(h);
              } catch(e) {}
            }
          }
          new MutationObserver(function() { reportHeight(); })
            .observe(document.body, { childList: true, subtree: true, attributes: true });
          setTimeout(reportHeight, 300);
        })();
        """
    }

    private var dnJavaScriptInterface: String {
        return """
        window.Dn = {
            iosUrl: (url) => { window.webkit.messageHandlers.iosUrl.postMessage(url); },
            iosUrlN: (url, inbr, ret) => {
                window.webkit.messageHandlers.iosUrlN.postMessage({
                    deeplink: url,
                    openInAppBrowser: inbr,
                    retrieveLinkOnSameScreen: ret
                });
            },
            androidUrl: (url) => { window.webkit.messageHandlers.androidUrl.postMessage(url); },
            androidUrlN: (url, inbr, ret) => {
                window.webkit.messageHandlers.androidUrlN.postMessage({
                    deeplink: url, openInAppBrowser: inbr, retrieveLinkOnSameScreen: ret
                });
            },
            sendClick: (buttonId, buttonType) => {
                window.webkit.messageHandlers.sendClick.postMessage({ buttonId: buttonId, buttonType: buttonType });
            },
            dismiss: () => { window.webkit.messageHandlers.dismiss.postMessage(null); },
            close: () => { window.webkit.messageHandlers.close.postMessage(null); },
            closeN: () => { window.webkit.messageHandlers.closeN.postMessage(null); },
            setTags: (tags) => { window.webkit.messageHandlers.setTags.postMessage(tags); },
            promptPushPermission: () => { window.webkit.messageHandlers.promptPushPermission.postMessage(null); },
            openSettings: () => { window.webkit.messageHandlers.openSettings.postMessage(null); },
            copyToClipboard: (value) => { window.webkit.messageHandlers.copyToClipboard.postMessage(value); }
        };
        """
    }

    private func adjustHeight(_ height: CGFloat) {
        guard height > 0 else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isHidden = false
            self.reportedContentHeight = height
            self.invalidateIntrinsicContentSize()

            self.onHeightChange?(height)

            if self.onHeightChange == nil {
                if let existing = self.heightConstraint {
                    existing.constant = height
                } else {
                    let constraint = self.heightAnchor.constraint(equalToConstant: height)
                    constraint.priority = .required
                    constraint.isActive = true
                    self.heightConstraint = constraint
                }
            }

            self.setNeedsLayout()
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
}

//
//  File.swift
//
//
//  Created by Priya Agarwal on 20/02/24.
//

import Foundation

import UIKit
import WebKit

open class InAppInlineElementView: WKWebView, WKScriptMessageHandler {

    var delegate: InAppMessagesActionsDelegate?
    var message: InAppMessage?

    // DengageBridge support
    private var dengageBridge: DengageBridge?
    private var legacyHandler: LegacyDnHandler?

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {

        super.init(frame: frame, configuration: configuration)

        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        contentMode = .scaleAspectFit
        sizeToFit()
        autoresizesSubviews = true

        setUpUI()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        setupBridge()

        // Add bridge JavaScript as user script
        let bridgeScript = BridgeJavaScript.createUserScript()
        configuration.userContentController.addUserScript(bridgeScript)

        // Keep legacy interface for backwards compatibility
        let userScript = WKUserScript(
            source: javascriptInterface,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(userScript)

        if #available(iOS 14.0, *) {
            self.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            self.configuration.preferences.javaScriptEnabled = true
        }

        // Keep legacy message handlers for backwards compatibility
        configuration.userContentController.add(self, name: "dismiss")
        configuration.userContentController.add(self, name: "close")
        configuration.userContentController.add(self, name: "closeN")
        configuration.userContentController.add(self, name: "iosUrl")
        configuration.userContentController.add(self, name: "iosUrlN")
        configuration.userContentController.add(self, name: "sendClick")
        configuration.userContentController.add(self, name: "promptPushPermission")
        configuration.userContentController.add(self, name: "setTags")
        configuration.userContentController.add(self, name: "openSettings")
        configuration.userContentController.add(self, name: "copyToClipboard")

        loadHTMLString(message?.data.content.props.html ?? "", baseURL: nil)

        self.contentMode = .scaleAspectFit
        self.sizeToFit()
        self.autoresizesSubviews = true
    }

    private func setupBridge() {
        // Create legacy handler with callbacks
        legacyHandler = LegacyDnHandler(
            delegate: delegate,
            message: message,
            isIosURLNPresent: false,
            onClicked: nil,
            onFinish: nil
        )

        // Create handler registry and register handlers
        let registry = BridgeHandlerRegistry()
        if let handler = legacyHandler {
            registry.register(handler)
        }
        registry.register(HttpRequestHandler(inAppMessage: message))
        registry.register(DeviceInfoHandler())
        registry.register(StorageHandler())

        // Attach bridge to self (WKWebView)
        dengageBridge = DengageBridge.attach(to: self, handlerRegistry: registry)
    }

    /// Update delegate reference in legacy handler
    func updateDelegate(_ newDelegate: InAppMessagesActionsDelegate?) {
        self.delegate = newDelegate
        legacyHandler?.delegate = newDelegate
    }

    /// Update message reference
    func updateMessage(_ newMessage: InAppMessage?) {
        self.message = newMessage
        legacyHandler?.message = newMessage
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        run(message: message)
    }

    private func run(message: WKScriptMessage) {
        switch message.name {
        case "sendClick":
            let buttonId = message.body as? String
            if let msg = self.message {
                self.delegate?.sendClickEvent(
                    message: msg,
                    buttonId: buttonId,
                    buttonType: ""
                )
            }

        case "iosUrl":
            guard let url = message.body as? String else { return }
            if url == "Dn.promptPushPermission()" {
                self.delegate?.promptPushPermission()
            } else if url.uppercased() == "DN.SHOWRATING()" {
                Dengage.showRatingView()
            } else {
                self.delegate?.open(url: url)
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
                    self.delegate?.promptPushPermission()
                } else if deeplink.uppercased() == "DN.SHOWRATING()" {
                    Dengage.showRatingView()
                } else {
                    self.delegate?.open(url: deeplink)
                }
            }

        case "setTags":
            guard let tagItemData = message.body as? [[String: String]] else { return }
            let tagItems = tagItemData.map { TagItem(with: $0) }
            self.delegate?.setTags(tags: tagItems)

        case "promptPushPermission":
            self.delegate?.promptPushPermission()

        case "openSettings":
            self.delegate?.openApplicationSettings()

        case "copyToClipboard":
            guard let bodyString = message.body as? String else { return }
            UIPasteboard.general.string = bodyString

        case "dismiss", "close", "closeN":
            if let msg = self.message {
                self.delegate?.sendDismissEvent(message: msg)
            }
            self.delegate?.close()

        default:
            break
        }
    }
}

extension InAppInlineElementView {

    fileprivate var javascriptInterface: String {
        return """
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
                window.webkit.messageHandlers.sendClick.postMessage(buttonId);
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

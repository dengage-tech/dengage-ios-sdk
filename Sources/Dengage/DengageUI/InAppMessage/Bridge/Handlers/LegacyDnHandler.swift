import Foundation
import UIKit
import StoreKit

/// Handler for legacy Dn.* JavaScript interface methods
/// Provides backwards compatibility with existing HTML content
final class LegacyDnHandler: FireAndForgetHandler {

    weak var delegate: InAppMessagesActionsDelegate?
    var message: InAppMessage?
    var isIosURLNPresent: Bool
    var onClicked: (() -> Void)?
    var onFinish: (() -> Void)?

    init(
        delegate: InAppMessagesActionsDelegate? = nil,
        message: InAppMessage? = nil,
        isIosURLNPresent: Bool = false,
        onClicked: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        self.delegate = delegate
        self.message = message
        self.isIosURLNPresent = isIosURLNPresent
        self.onClicked = onClicked
        self.onFinish = onFinish
    }

    func supportedActions() -> [String] {
        return [
            "legacy_dismiss",
            "legacy_iosUrl",
            "legacy_iosUrlN",
            "legacy_sendClick",
            "legacy_close",
            "legacy_closeN",
            "legacy_setTags",
            "legacy_androidUrl",
            "legacy_androidUrlN",
            "legacy_promptPushPermission",
            "legacy_showRating",
            "legacy_openSettings",
            "legacy_copyToClipboard"
        ]
    }

    struct IosUrlPayload: Decodable {
        let targetUrl: String
    }

    struct IosUrlNPayload: Decodable {
        let targetUrl: String
        let inAppBrowser: Bool
        let retrieveOnSameLink: Bool
    }

    struct SendClickPayload: Decodable {
        let buttonId: String?
        let buttonType: String?
    }

    struct CopyToClipboardPayload: Decodable {
        let value: String
    }

    struct SetTagsPayload: Decodable {
        let tags: String?
    }

    func handle(message: BridgeMessage) {
        Logger.log(message: "LegacyDnHandler handling action: \(message.action)")

        switch message.action {
        case "legacy_dismiss":
            handleDismiss()

        case "legacy_iosUrl":
            guard let payloadData = message.payload?.data(using: .utf8),
                  let payload = try? JSONDecoder().decode(IosUrlPayload.self, from: payloadData) else { return }
            handleIosUrl(payload.targetUrl)

        case "legacy_iosUrlN":
            guard let payloadData = message.payload?.data(using: .utf8),
                  let payload = try? JSONDecoder().decode(IosUrlNPayload.self, from: payloadData) else { return }
            handleIosUrlN(payload.targetUrl, inAppBrowser: payload.inAppBrowser, retrieveOnSameLink: payload.retrieveOnSameLink)

        case "legacy_sendClick":
            let payloadData = message.payload?.data(using: .utf8)
            let payload = payloadData.flatMap { try? JSONDecoder().decode(SendClickPayload.self, from: $0) }
            handleSendClick(buttonId: payload?.buttonId, buttonType: payload?.buttonType)

        case "legacy_close":
            handleClose()

        case "legacy_closeN":
            handleCloseN()

        case "legacy_setTags":
            let payloadData = message.payload?.data(using: .utf8)
            let payload = payloadData.flatMap { try? JSONDecoder().decode(SetTagsPayload.self, from: $0) }
            handleSetTags(payload?.tags)

        case "legacy_androidUrl", "legacy_androidUrlN":
            // iOS ignores Android-specific URLs
            Logger.log(message: "In app message: ignoring Android URL on iOS")

        case "legacy_promptPushPermission":
            handlePromptPushPermission()

        case "legacy_showRating":
            handleShowRating()

        case "legacy_openSettings":
            handleOpenSettings()

        case "legacy_copyToClipboard":
            guard let payloadData = message.payload?.data(using: .utf8),
                  let payload = try? JSONDecoder().decode(CopyToClipboardPayload.self, from: payloadData) else { return }
            handleCopyToClipboard(payload.value)

        default:
            Logger.log(message: "LegacyDnHandler: Unknown action \(message.action)")
        }
    }

    private func handleDismiss() {
        Logger.log(message: "In app message: dismiss event")
        if let msg = self.message {
            delegate?.sendDismissEvent(message: msg)
        }
        onFinish?()
    }

    private func handleIosUrl(_ targetUrl: String) {
        if !isIosURLNPresent {
            Logger.log(message: "In app message: ios target url event \(targetUrl)")
            if targetUrl == "Dn.promptPushPermission()" {
                handlePromptPushPermission()
            } else if targetUrl.uppercased() == "DN.SHOWRATING()" {
                handleShowRating()
            } else {
                delegate?.open(url: targetUrl)
            }
        }
    }

    private func handleIosUrlN(_ targetUrl: String, inAppBrowser: Bool, retrieveOnSameLink: Bool) {
        Logger.log(message: "In app message: ios target url n event \(targetUrl)")

        DengageLocalStorage.shared.set(value: inAppBrowser, for: .openInAppBrowser)
        DengageLocalStorage.shared.set(value: retrieveOnSameLink, for: .retrieveLinkOnSameScreen)

        if targetUrl == "Dn.promptPushPermission()" {
            handlePromptPushPermission()
        } else if targetUrl.uppercased() == "DN.SHOWRATING()" {
            handleShowRating()
        } else {
            delegate?.open(url: targetUrl)
        }
    }

    private func handleSendClick(buttonId: String?, buttonType: String?) {
        onClicked?()
        Logger.log(message: "In app message: clicked button \(buttonId ?? "")")
        if let msg = self.message {
            delegate?.sendClickEvent(message: msg, buttonId: buttonId, buttonType: buttonType)
        }
    }

    private func handleClose() {
        if !isIosURLNPresent {
            Logger.log(message: "In app message: close event")
            if let msg = self.message {
                delegate?.sendDismissEvent(message: msg)
            }
            delegate?.close()
        }
    }

    private func handleCloseN() {
        Logger.log(message: "In app message: close event n")
        if let msg = self.message {
            delegate?.sendDismissEvent(message: msg)
        }
        delegate?.close()
    }

    private func handleSetTags(_ tagsString: String?) {
        Logger.log(message: "In app message: set tags event")
        guard let tagItemString = tagsString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !tagItemString.isEmpty else { return }

        let withoutBraces = tagItemString.trimmingCharacters(in: CharacterSet(charactersIn: "{} "))
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
    }

    private func handlePromptPushPermission() {
        Logger.log(message: "In app message: prompt push permission event")
        delegate?.promptPushPermission()
    }

    private func handleShowRating() {
        Logger.log(message: "In app message: show rating event")
        Dengage.showRatingView()
        onFinish?()
    }

    private func handleOpenSettings() {
        Logger.log(message: "In app message: open settings event")
        delegate?.openApplicationSettings()
    }

    private func handleCopyToClipboard(_ value: String) {
        Logger.log(message: "In app message: copyToClipboard event \(value)")
        UIPasteboard.general.string = value
    }
}

import Foundation

protocol InAppMessagesActionsDelegate: AnyObject {
    func open(url: String?)
    func sendDismissEvent(message: InAppMessage)
    func sendClickEvent(message: InAppMessage, buttonId: String?, buttonType: String?)
    func promptPushPermission()
    func openApplicationSettings()
    func close()
    func setTags(tags: [TagItem])
    func closeInAppBrowser()
}

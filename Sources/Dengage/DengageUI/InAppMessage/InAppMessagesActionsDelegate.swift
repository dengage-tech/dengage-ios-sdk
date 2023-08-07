import Foundation
protocol InAppMessagesActionsDelegate:AnyObject{
    func open(url: String?)
    func sendDissmissEvent(message:InAppMessage)
    func sendClickEvent(message:InAppMessage, buttonId:String?)
    func promptPushPermission()
    func close()
    func setTags(tags:[TagItem])
    func closeInAppBrowser()

}


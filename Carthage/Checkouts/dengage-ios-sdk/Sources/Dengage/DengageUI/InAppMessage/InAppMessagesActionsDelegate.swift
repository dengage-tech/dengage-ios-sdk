import Foundation
protocol InAppMessagesActionsDelegate:AnyObject{
    func open(url: String?)
    func sendDissmissEvent(messageId:String?)
    func sendClickEvent(messageId:String?, buttonId:String?)
    func promptPushPermission()
    func close()
    func setTags(tags:[TagItem])
}

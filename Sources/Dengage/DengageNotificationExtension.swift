import Foundation
import UserNotifications

final class DengageNotificationExtension {
    
    static func didReceiveNotificationRequest(_ bestAttemptContent: UNMutableNotificationContent?,
                                              withContentHandler contentHandler:  @escaping (UNNotificationContent) -> Void) {
        
        
        Logger.log(message: "NOTIFICATION_RECEIVED")
        
        guard let bestAttemptContent = bestAttemptContent, let message = bestAttemptContent.message else {
            Logger.log(message: "Message source not handled")
            return
        }
        guard let messageSource = message.messageSource, messageSource == MESSAGE_SOURCE else {
            Logger.log(message: "Message source not dengage")
            return
        }
        guard let title = message.title, let subtitle = message.subtitle else {
            Logger.log(message: "title or subtitle not found")
            return
        }
        
        if #available(iOS 15.0, *) {
            bestAttemptContent.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
        if let muted = message.muted, muted {
            bestAttemptContent.sound = nil
        }
        
        if let addToInbox = message.addToInbox, addToInbox {
            
        }
        
        /*
        do {
            let data =  try JSONSerialization.data(withJSONObject: bestAttemptContent.userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data, encoding: String.Encoding.utf8)
            Logger.log(message: convertedString ?? "")
            //DengageLocalStorage.shared.set(value: convertedString, for: .lastPushPayload)
            let localMessage = DengageLocalInboxMessage(id: "",
                                                        title: message.title,
                                                        message: message.messageSource,
                                                        mediaURL: message.urlImageString,
                                                        targetUrl: message.targetUrl,
                                                        receiveDate: Date(),
                                                        isClicked: false,
                                                        carouselItems: nil,
                                                        isDeleted: false)
                                                        
            //let localMessage = DengageLocalInboxMessage(title: message.title ?? "NULL")
            var localMessages: [DengageLocalInboxMessage] = []
            localMessages.append(localMessage)
            DengageLocalStorage.shared.save(localMessages)
        } catch let myJSONError {
            print(myJSONError)
        }
         */


        registerDismissableCategory(for: bestAttemptContent) {
            finishNotificationRequest(bestAttemptContent, message: message, title: title,
                                      subtitle: subtitle, withContentHandler: contentHandler)
        }
    }
    
    private static func finishNotificationRequest(_ bestAttemptContent: UNMutableNotificationContent,
                                                  message: PushContent,
                                                  title: String,
                                                  subtitle: String,
                                                  withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        bestAttemptContent.title = title
        bestAttemptContent.subtitle = subtitle
        
        
        if let urlImageString = message.urlImageString, let contentUrl = URL(string: urlImageString) {
            if let imageData = NSData(contentsOf: contentUrl) {
                guard let attachment = UNNotificationAttachment.create(fileIdentifier: contentUrl.lastPathComponent,
                                                                       data: imageData) else {
                    Logger.log(message: "UNNotificationAttachment.saveImageToDisk()")
                    return
                }
                
                bestAttemptContent.attachments = [ attachment ]
            }
        }
        contentHandler(bestAttemptContent)
    }
    
    /// Category used for Dengage pushes that arrive without one, so that dismissing them is
    /// still reported (iOS only delivers dismiss for categories with `.customDismissAction`).
    static let defaultCategoryIdentifier = "DENGAGE_DEFAULT_CATEGORY"
    
    /// Makes sure the push has a category with `.customDismissAction` (plus its action buttons)
    /// for every push type: text, rich and carousel, with or without buttons. Categories that are
    /// already registered, by the host app or by the carousel content extension, are kept.
    private static func registerDismissableCategory(for bestAttemptContent: UNMutableNotificationContent,
                                                    completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationCategories { existing in
            let categories = mergedCategories(for: bestAttemptContent, into: existing)
            if categories != existing {
                center.setNotificationCategories(categories)
            }
            completion()
        }
    }
    
    /// Returns `existing` with this push's category added or updated so that it carries
    /// `.customDismissAction`. Sets a category identifier on the content when the push has none.
    static func mergedCategories(for bestAttemptContent: UNMutableNotificationContent,
                                 into existing: Set<UNNotificationCategory>) -> Set<UNNotificationCategory> {
        let pushActions = actions(for: bestAttemptContent)
        
        if bestAttemptContent.categoryIdentifier.isEmpty {
            // Pushes with buttons need their own category so they don't overwrite each other's actions.
            if pushActions.isEmpty {
                bestAttemptContent.categoryIdentifier = defaultCategoryIdentifier
            } else {
                let messageId = bestAttemptContent.message?.messageId.map(String.init) ?? UUID().uuidString
                bestAttemptContent.categoryIdentifier = "DENGAGE_ACTIONS_\(messageId)"
            }
        }
        let identifier = bestAttemptContent.categoryIdentifier
        let current = existing.first { $0.identifier == identifier }
        
        let actions = pushActions.isEmpty ? (current?.actions ?? []) : pushActions
        var options = current?.options ?? []
        options.insert(.customDismissAction)
        let intentIdentifiers = current?.intentIdentifiers ?? []
        
        let category: UNNotificationCategory
        if #available(iOS 11.0, *) {
            category = UNNotificationCategory(identifier: identifier,
                                              actions: actions,
                                              intentIdentifiers: intentIdentifiers,
                                              hiddenPreviewsBodyPlaceholder: current?.hiddenPreviewsBodyPlaceholder ?? "",
                                              options: options)
        } else {
            // Fallback on earlier versions
            category = UNNotificationCategory(identifier: identifier,
                                              actions: actions,
                                              intentIdentifiers: intentIdentifiers,
                                              options: options)
        }
        
        var merged = existing.filter { $0.identifier != identifier }
        merged.insert(category)
        return merged
    }
    
    private static func actions(for bestAttemptContent: UNMutableNotificationContent) -> [UNNotificationAction] {
        guard let actionButtons = bestAttemptContent.message?.actionButtons else {
            Logger.log(message: "Action Buttons not found")
            return []
        }
        
        Logger.log(message: "Parsing action buttons")
        
        return actionButtons.compactMap { item in
            guard let id = item.id, let title = item.text else { return nil }
            let options: UNNotificationActionOptions = ("NO".caseInsensitiveCompare(id) == .orderedSame)  ? [] : .foreground
            return UNNotificationAction(identifier: id, title: title, options: options)
        }
    }
}

@available(iOSApplicationExtension 10.0, *)
public extension UNNotificationAttachment {
    
    static func create(fileIdentifier: String, data: NSData, options: [NSObject: AnyObject]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        guard let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(folderName, isDirectory: true) else { return nil }
        
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL, options: options)
            return attachment
        } catch let error {
            Logger.log(message:"error create image attachment", argument: error.localizedDescription)
        }
        
        return nil
    }
}

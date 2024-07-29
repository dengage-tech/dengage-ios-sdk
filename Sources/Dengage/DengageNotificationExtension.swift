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
        
        addActionButtonsIfNeeded(bestAttemptContent)
        
        bestAttemptContent.title = title
        bestAttemptContent.subtitle = subtitle
        
        
        guard let urlImageString = message.urlImageString, let contentUrl = URL(string: urlImageString) else { return }
        
        guard let imageData = NSData(contentsOf: contentUrl) else {
            Logger.log(message: "URL_STR_IS_NULL")
            return
        }
        
        guard let attachment = UNNotificationAttachment.create(fileIdentifier: contentUrl.lastPathComponent,
                                                               data: imageData) else {
            Logger.log(message: "UNNotificationAttachment.saveImageToDisk()")
            return
        }
        
        bestAttemptContent.attachments = [ attachment ]
        contentHandler(bestAttemptContent)
    }
    
    private static func addActionButtonsIfNeeded(_ bestAttemptContent: UNMutableNotificationContent) {
        
        guard let actionButtons = bestAttemptContent.message?.actionButtons else {
            Logger.log(message: "Action Buttons not found")
            return
        }
        
        Logger.log(message: "Parsing action buttons")
        
        let actions: [UNNotificationAction] = actionButtons.compactMap{ item in
            guard let id = item.id, let title = item.text else { return nil }
            return UNNotificationAction(identifier: id, title: title, options: .foreground)
        }
        
        let category: UNNotificationCategory;
        if #available(iOS 11.0, *) {
            category = UNNotificationCategory(identifier: bestAttemptContent.categoryIdentifier,
                                              actions: actions,
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              options: .customDismissAction)
            
        } else {
            // Fallback on earlier versions
            category = UNNotificationCategory(identifier: bestAttemptContent.categoryIdentifier,
                                              actions: actions,
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
        }
        UNUserNotificationCenter.current().setNotificationCategories([category])
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

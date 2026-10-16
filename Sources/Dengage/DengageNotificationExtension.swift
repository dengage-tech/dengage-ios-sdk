import Foundation
import UserNotifications
import Intents

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


        addActionButtonsIfNeeded(bestAttemptContent)
        
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

        if #available(iOS 15.0, *), let notificationIcon = message.notificationIcon, !notificationIcon.isEmpty {
            applyCommunicationStyle(bestAttemptContent,
                                    notificationIcon: notificationIcon,
                                    withContentHandler: contentHandler)
            return
        }
        contentHandler(bestAttemptContent)
    }

    /// Shows the notification as a communication notification (`notificationIcon` instead of the app icon,
    /// the title, or the app name when it is empty, as the sender name).
    /// Requires the Communication Notifications capability on the app target and
    /// `INSendMessageIntent` in the extension's `IntentsSupported`; otherwise the content is delivered unchanged.
    @available(iOS 15.0, *)
    private static func applyCommunicationStyle(_ bestAttemptContent: UNMutableNotificationContent,
                                                notificationIcon: String,
                                                withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        var senderImage: INImage?
        if let url = URL(string: notificationIcon), let imageData = NSData(contentsOf: url) {
            senderImage = INImage(imageData: imageData as Data)
        } else {
            Logger.log(message: "Communication notification icon not loaded")
        }

        let senderName = bestAttemptContent.title.isEmpty ? appName() : bestAttemptContent.title
        let sender = INPerson(personHandle: INPersonHandle(value: notificationIcon, type: .unknown),
                              nameComponents: nil,
                              displayName: senderName,
                              image: senderImage,
                              contactIdentifier: nil,
                              customIdentifier: notificationIcon)

        let intent = INSendMessageIntent(recipients: nil,
                                         outgoingMessageType: .outgoingMessageText,
                                         content: bestAttemptContent.body,
                                         speakableGroupName: nil,
                                         conversationIdentifier: notificationIcon,
                                         serviceName: nil,
                                         sender: sender,
                                         attachments: nil)
        intent.setImage(senderImage, forParameterNamed: \.sender)

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        interaction.donate { error in
            if let error = error {
                Logger.log(message: "Communication notification interaction donate failed", argument: error.localizedDescription)
            }
            do {
                contentHandler(try bestAttemptContent.updating(from: intent))
            } catch {
                Logger.log(message: "Communication notification content update failed", argument: error.localizedDescription)
                contentHandler(bestAttemptContent)
            }
        }
    }

    /// The containing app's name; the extension is at `<App>.app/PlugIns/<Extension>.appex`.
    private static func appName() -> String {
        let appBundle = Bundle(url: Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()) ?? Bundle.main
        return appBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? appBundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ""
    }

    private static func addActionButtonsIfNeeded(_ bestAttemptContent: UNMutableNotificationContent) {
        
        guard let actionButtons = bestAttemptContent.message?.actionButtons else {
            Logger.log(message: "Action Buttons not found")
            return
        }
        
        Logger.log(message: "Parsing action buttons")
        
        let actions: [UNNotificationAction] = actionButtons.compactMap { item in
            guard let id = item.id, let title = item.text else { return nil }
            let options: UNNotificationActionOptions = ("NO".caseInsensitiveCompare(id) == .orderedSame)  ? [] : .foreground
            return UNNotificationAction(identifier: id, title: title, options: options)
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

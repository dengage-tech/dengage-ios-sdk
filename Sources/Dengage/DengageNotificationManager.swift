
import Foundation
import UIKit

final class DengageNotificationManager: DengageNotificationManagerInterface {
    
    private let config: DengageConfiguration
    private let apiClient: DengageNetworking
    private let eventManager: DengageEventProtocolInterface
    private let launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var openTriggerCompletionHandler: ((_ notificationResponse: UNNotificationResponse) -> Void)?

    init(config: DengageConfiguration,
         service: DengageNetworking,
         eventManager: DengageEventProtocolInterface,
         launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        self.config = config
        self.apiClient = service
        self.eventManager = eventManager
        self.launchOptions = launchOptions
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            didReceive(with: userInfo)
        }
    }
    
    func didReceivePush(_ center: UNUserNotificationCenter,
                        _ response: UNNotificationResponse,
                        withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        guard let messageSource = content.message?.messageSource,
              MESSAGE_SOURCE == messageSource else {
//                  center.delegate?.userNotificationCenter?(center,
//                                                           didReceive: response,
//                                                           withCompletionHandler: completionHandler)
            
            completionHandler()
            
           return
        }
        
        let actionIdentifier = response.actionIdentifier
        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            Logger.log(message: "UNNotificationDismissActionIdentifier TRIGGERED")
            sendEventWithContent(content: content, actionIdentifier: "DismissAction")
        case UNNotificationDefaultActionIdentifier:
            Logger.log(message: "UNNotificationDefaultActionIdentifier TRIGGERED")
            sendEventWithContent(content: content, actionIdentifier: nil)
        default:
            Logger.log(message: "TRIGGERED ACTION_ID", argument: actionIdentifier)
            sendEventWithContent(content: content, actionIdentifier: actionIdentifier)
            checkTargetUrlInActionButtons(content: content, actionIdentifier: actionIdentifier)
        }
        
        openTriggerCompletionHandler?(response)
    
        if !config.options.disableOpenURL
        {
            if let targetUrl = content.message?.targetUrl, !targetUrl.isEmpty {
                openDeeplink(link: targetUrl)
                eventManager.sessionStart(referrer: content.message?.targetUrl)
            }
        }
        
        completionHandler()
    }
    
    func didReceive(with userInfo: [AnyHashable: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
           let message = try? JSONDecoder().decode(PushContent.self, from: jsonData)  {
            if let messageSource = message.messageSource, MESSAGE_SOURCE == messageSource
            {
                
            }
            if let targetUrl = message.targetUrl, !targetUrl.isEmpty, !config.options.disableOpenURL {
                openDeeplink(link: targetUrl)
                eventManager.sessionStart(referrer: message.targetUrl)
            }
        }else{
            Logger.log(message: "UserInfo parse failed")
        }
    }
    
    private func openDeeplink(link: String?) {
        Logger.log(message: "TARGET_URL is", argument: link ?? "nil")
        guard let urlString = link, !urlString.isEmpty, let url = URL(string: urlString) else {
            Logger.log(message: "TARGET_URL not found error", argument: link ?? "nil")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func checkTargetUrlInActionButtons(content: UNNotificationContent,
                                             actionIdentifier: String) {
        
        guard let actionButtons = content.message?.actionButtons else { return }
                
        for actionItem in actionButtons where actionItem.id == actionIdentifier {
            guard let url = actionItem.targetUrl, !url.isEmpty else { continue }
            openDeeplink(link: url)
        }
    }
    
    private func sendEventWithContent(content: UNNotificationContent, actionIdentifier: String?) {
        
        guard let messageId = content.message?.messageId else {
            Logger.log(message: "MSG_ID is not found")
            return
        }
        Logger.log(message: "MSG_ID is", argument: String(messageId))
        
        guard let messageDetails = content.message?.messageDetails else {
            Logger.log(message: "MSG_DETAILS is not found")
            return
        }
        Logger.log(message: "MSG_DETAILS is", argument: messageDetails)
        
        if let actionIdentifier = actionIdentifier, actionIdentifier.isEmpty == false {
            Logger.log(message: "BUTTON_ID is", argument: String(actionIdentifier))
        }
        
        if let transactionId = content.message?.transactionId {
            Logger.log(message: "BUTTON_ID is", argument: String(transactionId))

            let request = TransactionalOpenEventRequest(integrationKey: config.integrationKey,
                                                        transactionId: transactionId,
                                                        messageId: messageId,
                                                        messageDetails: messageDetails,
                                                        buttonId: actionIdentifier)
            
            eventManager.sendTransactionalOpenEvet(request: request)
        } else {
            let request = OpenEventRequest(integrationKey: config.integrationKey,
                                           messageId: messageId,
                                           messageDetails: messageDetails,
                                           buttonId: actionIdentifier)
            eventManager.sendOpenEvet(request: request)
        }
        
        if config.options.badgeCountReset == true {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

extension DengageNotificationManager{
    func promptForPushNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [self] granted, _ in
            guard granted else {
                Logger.log(message: "PERMISSION_NOT_GRANTED", argument: String(granted))
                Dengage.register(deviceToken: Data())
                return
            }

            self.getNotificationSettings()
            Logger.log(message: "PERMISSION_GRANTED", argument: String(granted))
        }
    }
    
    func promptForPushNotifications(callback: @escaping (_ IsUserGranted: Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard granted else {
                Logger.log(message: "PERMISSION_NOT_GRANTED", argument: String(granted))
                Dengage.register(deviceToken: Data())
                callback(granted)
                return
            }
            
            self?.getNotificationSettings()
            Logger.log(message: "PERMISSION_GRANTED", argument: String(granted))
            callback(granted)
        }
    }
    
    func getNotificationSettings() {
        guard !config.options.disableRegisterForRemoteNotifications else { return }
        notificationCenter.getNotificationSettings { settings in
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                Logger.log(message: "REGISTER_TOKEN")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

protocol DengageNotificationManagerInterface: AnyObject{
    func didReceivePush(_ center: UNUserNotificationCenter,
                        _ response: UNNotificationResponse,
                        withCompletionHandler completionHandler: @escaping () -> Void)
    func didReceive(with userInfo: [AnyHashable: Any])
    func promptForPushNotifications()
    func promptForPushNotifications(callback: @escaping (_ IsUserGranted: Bool) -> Void)
    func getNotificationSettings()
    var openTriggerCompletionHandler: ((_ notificationResponse: UNNotificationResponse) -> Void)? { get set }
}

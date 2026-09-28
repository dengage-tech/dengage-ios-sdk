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
        
        do {
            let data =  try JSONSerialization.data(withJSONObject: content.userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data, encoding: String.Encoding.utf8)
            DengageLocalStorage.shared.set(value: convertedString, for: .lastPushPayload)
        } catch let myJSONError {
            print(myJSONError)
        }
        
        
        let actionIdentifier = response.actionIdentifier
        let event = Self.pushEvent(for: actionIdentifier)
        sendEventWithContent(content: content, actionIdentifier: event.buttonId, eventType: event.type)
        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            Logger.log(message: "UNNotificationDismissActionIdentifier TRIGGERED")
        case UNNotificationDefaultActionIdentifier:
            Logger.log(message: "UNNotificationDefaultActionIdentifier TRIGGERED")
        default:
            Logger.log(message: "TRIGGERED ACTION_ID", argument: actionIdentifier)
            checkTargetUrlInActionButtons(content: content, actionIdentifier: actionIdentifier)
        }
        
        openTriggerCompletionHandler?(response)
    
        if !config.options.disableOpenURL && !Dengage.isPushSilent(response: response)
        {
            if let targetUrl = content.message?.targetUrl, !targetUrl.isEmpty,
               actionIdentifier != UNNotificationDismissActionIdentifier {
                if actionIdentifier == UNNotificationDefaultActionIdentifier {
                    openDeeplink(link: targetUrl)
                }
                eventManager.sessionStart(referrer: content.message?.targetUrl)
            }
        }
        
        completionHandler()
    }
    
    func didReceive(with userInfo: [AnyHashable: Any]) {
        // Uygulama arka plandayken gelen push ise (silent push dahil) in-app fetch'leri bastır.
        DengageAppStateTracker.shared.markPushWakeIfInBackground()

        // Silent push: sourceType == geofence ise fence'leri sunucudan yeniden çek (resync)
        if GeofenceSilentPushDispatcher.isGeofenceSilentPush(userInfo) {
            GeofenceSilentPushDispatcher.dispatch(userInfo)
            return
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
           let message = try? JSONDecoder().decode(PushContent.self, from: jsonData)  {
            
            do {
                let data =  try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
                let convertedString = String(data: data, encoding: String.Encoding.utf8)
                DengageLocalStorage.shared.set(value: convertedString, for: .lastPushPayload)
            } catch let myJSONError {
                print(myJSONError)
            }
            
            // TODO: sendEventWithContent neden if'in dışında? priya
            if let messageSource = message.messageSource, MESSAGE_SOURCE == messageSource
            {
                
            }
            
            sendEventWithContent(messageId: message.messageId, messageDetails: message.messageDetails, transactionId: message.transactionId, actionIdentifier: nil)

            
            if let targetUrl = message.targetUrl, !targetUrl.isEmpty, !config.options.disableOpenURL && !Dengage.isPushSilent(userInfo: userInfo)
            {
                openDeeplink(link: targetUrl)
                eventManager.sessionStart(referrer: message.targetUrl)
            }
        }else{
            Logger.log(message: "UserInfo parse failed")
        }
    }
    
    /// Maps a notification response to the event it reports: swiping the push away is a dismiss,
    /// tapping the push or one of its action buttons is an open.
    static func pushEvent(for actionIdentifier: String) -> (type: PushEventType, buttonId: String?) {
        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            return (.dismiss, nil)
        case UNNotificationDefaultActionIdentifier:
            return (.open, nil)
        default:
            return (.open, actionIdentifier)
        }
    }
    
    func didClickCarouselItem(content: UNNotificationContent, carouselId: Int) {
        sendEventWithContent(content: content, actionIdentifier: String(carouselId))
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
    
    private func sendEventWithContent(content: UNNotificationContent,
                                      actionIdentifier: String?,
                                      eventType: PushEventType = .open) {
        sendPushEvent(eventType,
                      messageId: content.message?.messageId,
                      messageDetails: content.message?.messageDetails,
                      transactionId: content.message?.transactionId,
                      buttonId: actionIdentifier)
    }
    
    private func sendEventWithContent(messageId: Int? , messageDetails : String?, transactionId:String? , actionIdentifier: String?) {
        sendPushEvent(.open,
                      messageId: messageId,
                      messageDetails: messageDetails,
                      transactionId: transactionId,
                      buttonId: actionIdentifier)
    }
    
    /// Sends an open or dismiss event. Both use the same parameters and the same
    /// regular/transactional routing; only the endpoint differs.
    func sendPushEvent(_ eventType: PushEventType,
                       messageId: Int?,
                       messageDetails: String?,
                       transactionId: String?,
                       buttonId: String?) {

        guard let messageId = messageId else {
            Logger.log(message: "MSG_ID is not found")
            return
        }
        Logger.log(message: "MSG_ID is", argument: String(messageId))

        guard let messageDetails = messageDetails else {
            Logger.log(message: "MSG_DETAILS is not found")
            return
        }
        Logger.log(message: "MSG_DETAILS is", argument: messageDetails)

        guard Self.markPushEventSent(eventType, messageDetails: messageDetails) else { return }

        if let buttonId = buttonId, buttonId.isEmpty == false {
            Logger.log(message: "BUTTON_ID is", argument: String(buttonId))
        }
        
        if let transactionId = transactionId {
            Logger.log(message: "TRANSACTION_ID is", argument: String(transactionId))
            
            let request = TransactionalOpenEventRequest(integrationKey: config.integrationKey,
                                                        transactionId: transactionId,
                                                        messageId: messageId,
                                                        messageDetails: messageDetails,
                                                        buttonId: buttonId,
                                                        eventType: eventType)
            
            eventManager.sendTransactionalOpenEvet(request: request)
        } else {
            let request = OpenEventRequest(integrationKey: config.integrationKey,
                                           messageId: messageId,
                                           messageDetails: messageDetails,
                                           buttonId: buttonId,
                                           eventType: eventType)
            eventManager.sendOpenEvet(request: request)
        }
        
        if eventType == .open, config.options.badgeCountReset == true {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    /// Records that `eventType` was sent for `messageDetails` and returns false when it must be
    /// skipped: the same event was already sent for this message, or (for dismiss) the message
    /// was already opened.
    static func markPushEventSent(_ eventType: PushEventType,
                                  messageDetails: String,
                                  storage: DengageLocalStorage = .shared) -> Bool {
        if eventType == .dismiss,
           let opened = storage.value(for: .sentOpenEventMessageDetails) as? [String],
           opened.contains(messageDetails) {
            Logger.log(message: "Message already opened, skipping dismiss event for messageDetails: \(messageDetails)")
            return false
        }
        var sentDetails = (storage.value(for: eventType.sentMessageDetailsKey) as? [String]) ?? []
        if sentDetails.contains(messageDetails) {
            Logger.log(message: "Duplicate \(eventType.rawValue) event detected for messageDetails: \(messageDetails), skipping.")
            return false
        }
        sentDetails.append(messageDetails)
        if sentDetails.count > 10 {
            sentDetails.removeFirst()
        }
        storage.set(value: sentDetails, for: eventType.sentMessageDetailsKey)
        return true
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
    func didClickCarouselItem(content: UNNotificationContent, carouselId: Int)
    func promptForPushNotifications()
    func promptForPushNotifications(callback: @escaping (_ IsUserGranted: Bool) -> Void)
    func getNotificationSettings()
    var openTriggerCompletionHandler: ((_ notificationResponse: UNNotificationResponse) -> Void)? { get set }
}

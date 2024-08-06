//
//  DengageNotificationDelegate.swift
//  dengage.ios.sdk
//
//  Created by Developer on 15.08.2019.
//  Copyright © 2019 Dengage All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import UIKit

class DengageNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    var delegate: UNUserNotificationCenterDelegate?
    var openTriggerCompletionHandler: ((_ notificationResponse: UNNotificationResponse) -> Void)?
    let config: DengageConfiguration
    let eventManager: DengageEventProtocolInterface

    
    override init() {
        
        let apiKey = DengageLocalStorage.shared.value(for: .integrationKey) as? String
        self.config = DengageConfiguration(integrationKey: apiKey ?? "", options: DengageOptions())
        
        let apiClient = DengageNetworking(config: config)
        let sessionManager = DengageSessionManager(config: config)        
        self.eventManager = DengageEventManager(config: config,
                                                service: apiClient,
                                                sessionManager: sessionManager)
       // self.delegate = nil
        super.init()
    }
    
    init(config: DengageConfiguration,
         eventManager: DengageEventProtocolInterface) {
        
         self.config = config
        self.eventManager = eventManager
      //  self.delegate = nil
    }
    
    
    @available(iOS 10.0, *)
    final func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])

        
        
    }
    
    @available(iOS 10.0, *)
    final func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        guard let messageSource = content.message?.messageSource,
              MESSAGE_SOURCE == messageSource else {
            
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
    
    
    final func sendEventWithContent(content: UNNotificationContent,
                                    actionIdentifier: String?) {
        
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
        
        
        let apiKey = DengageLocalStorage.shared.value(for: .integrationKey) as? String ?? ""

        
        if let transactionId = content.message?.transactionId {
            Logger.log(message: "BUTTON_ID is", argument: String(transactionId))
            
            let request = TransactionalOpenEventRequest(integrationKey: apiKey,
                                                        transactionId: transactionId,
                                                        messageId: messageId,
                                                        messageDetails: messageDetails,
                                                        buttonId: actionIdentifier)
            
            eventManager.sendTransactionalOpenEvet(request: request)
        } else {
            let request = OpenEventRequest(integrationKey: apiKey,
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

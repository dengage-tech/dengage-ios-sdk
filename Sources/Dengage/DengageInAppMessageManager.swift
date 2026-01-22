import Foundation
import WebKit
import UIKit
import SafariServices

public class DengageInAppMessageManager: DengageInAppMessageManagerInterface {
   
    var config: DengageConfiguration
    var apiClient: DengageNetworking
    var inAppMessageWindow: UIWindow?
    let sessionManager: DengageSessionManagerInterface
    var inAppBrowserWindow: UIWindow?
    public var returnAfterDeeplinkRecieved : ((String) -> Void)?
    var inAppShowTimer = Timer()
    var hourlyFetchTimer: Timer?
    var isInAppMessageShowing = false
    

    init(config: DengageConfiguration,
         service: DengageNetworking,
         sessionManager: DengageSessionManagerInterface) {
        self.config = config
        self.apiClient = service
        self.sessionManager = sessionManager
        DengageLocalStorage.shared.set(value: Date().timeIntervalSince1970, for: .lastSessionStartTime)
        registerLifeCycleTrackers()
        startHourlyFetchTimer()
    }
    
    deinit {
        stopHourlyFetchTimer()
    }
}

//MARK: - API
extension DengageInAppMessageManager{
    func fetchInAppMessages(){
        fetchRealTimeMessages()
       // getVisitorInfo()
        Logger.log(message: "fetchInAppMessages called")
        // Cleanup expired show history entries (older than 2 weeks)
        DengageLocalStorage.shared.cleanupExpiredShowHistory()
        guard shouldFetchInAppMessages else {return}
        guard let remoteConfig = config.remoteConfiguration, let accountName = remoteConfig.accountName else { return }
        Logger.log(message: "fetchInAppMessages request started")
        let request = GetInAppMessagesRequest(accountName: accountName,
                                              contactKey: config.contactKey.key,
                                              type: config.contactKey.type,
                                              deviceId: config.applicationIdentifier, appid: config.remoteConfiguration?.appId ?? "")
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchIntervalInMin)
                DengageLocalStorage.shared.set(value: nextFetchTime, for: .lastFetchedInAppMessageTime)
                DengageLocalStorage.shared.set(value: Date().timeMiliseconds, for: .lastSuccessfulInAppMessageFetchTime)
                self?.addInAppMessagesIfNeeded(response)
                self?.fetchInAppExpiredMessageIds()
                
            case .failure(let error):
                Logger.log(message: "fetchInAppMessages_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    func fetchInAppExpiredMessageIds() {
        Logger.log(message: "fetchInAppExpiredMessageIds called")
        guard expiredMessagesFetchIntervalInMin else {return}
        if DengageLocalStorage.shared.getInAppMessages().count == 0
        {
            return
        }
        guard let remoteConfig = config.remoteConfiguration, let accountName = remoteConfig.accountName ,let appid = remoteConfig.appId else { return }
        Logger.log(message: "fetchInAppExpiredMessageIds request started")
        let request = ExpiredInAppMessageRequest.init(accountName: accountName, contactKey: config.contactKey.key, appid: appid)
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchexpiredMessagesFetchIntervalInMin)
                DengageLocalStorage.shared.set(value: nextFetchTime, for: .expiredMessagesFetchIntervalInMin)
                self?.removeExpiredInAppMessageFromCache(response)
            case .failure(let error):
                Logger.log(message: "fetchInAppExpiredMessageIds_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    func fetchRealTimeMessages(){
        guard shouldFetchRealTimeInAppMessages else { return }
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let appId = remoteConfig.appId
        else { return }
        Logger.log(message: "fetchRealTimeInAppMessages request started")
        let version2Request = GetRealTimeMesagesRequest(accountName: accountName, appId: appId, version: "v2")
        apiClient.send(request: version2Request) { [weak self] result in
            switch result {
            case .success(let response):
                let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchIntervalInMin)
                DengageLocalStorage.shared.set(value: nextFetchTime, for: .lastFetchedRealTimeInAppMessageTime)
                DengageLocalStorage.shared.set(value: Date().timeMiliseconds, for: .lastSuccessfulRealTimeInAppMessageFetchTime)
                let arrRealTimeInAppMessages = InAppMessage.mapRealTime(source: response)
                self?.addInAppMessagesIfNeeded(arrRealTimeInAppMessages, forRealTime: true)
                
            case .failure(let error):
                Logger.log(message: "fetchRealTimeInAppMessages_ERROR", argument: error.localizedDescription)
                let version1Request = GetRealTimeMesagesRequest(accountName: accountName, appId: appId, version: "")
                self?.apiClient.send(request: version1Request) { [weak self] result in
                    switch result {
                    case .success(let response):
                        let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchIntervalInMin)
                        DengageLocalStorage.shared.set(value: nextFetchTime, for: .lastFetchedRealTimeInAppMessageTime)
                        DengageLocalStorage.shared.set(value: Date().timeMiliseconds, for: .lastSuccessfulRealTimeInAppMessageFetchTime)
                        let arrRealTimeInAppMessages = InAppMessage.mapRealTime(source: response)
                        self?.addInAppMessagesIfNeeded(arrRealTimeInAppMessages, forRealTime: true)
                        
                    case .failure(let error):
                        Logger.log(message: "fetchRealTimeInAppMessages_ERROR", argument: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func getVisitorInfo(){
       
        guard isEnabledRealTimeInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName
        else { return }
        
        var cKey : String?
        
        if config.contactKey.key == ""
        {
            cKey = nil
        }
        else if config.contactKey.key == config.applicationIdentifier
        {
            cKey = nil

        }
        else
        {
            cKey = config.contactKey.key

        }
        
        let request = GetVisitorInfoRequest(accountName: accountName,
                                            contactKey: cKey,
                                            deviceID: config.applicationIdentifier)
        apiClient.send(request: request) { result in
            switch result {
            case .success(let response):
                 
                DengageLocalStorage.shared.save(response)

                
            case .failure(let error):
                Logger.log(message: "getVisitorInfo_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func markAsInAppMessageAsDisplayed(inAppMessageId: String? ,contentId:String ) {
        guard isEnabledInAppMessage else {return}
        guard let accountName = config.remoteConfiguration?.accountName,
              let messageId = inAppMessageId else { return }
        let request = MarkAsInAppMessageDisplayedRequest(type: config.contactKey.type,
                                                         deviceID: config.applicationIdentifier,
                                                         accountName: accountName,
                                                         contactKey: config.contactKey.key,
                                                         id: messageId, contentId: contentId)
        
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                Logger.log(message: "markAsInAppMessageAsDisplayed_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setInAppMessageAsClicked(_ message: InAppMessage, _ buttonId: String?, _ buttonType: String? , _ contentId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let messageId = message.data.messageDetails else { return }
        
        
        var updatedMessage = message
        if buttonType?.caseInsensitiveCompare("DISMISS") == .orderedSame {
            updatedMessage.dismissCount = (updatedMessage.dismissCount ?? 0) + 1
            self.updateInAppMessageOnCache(updatedMessage)
        } else {
            if !updatedMessage.data.isRealTime {
                self.removeInAppMessageFromCache(updatedMessage.data.messageDetails ?? "")
            }
        }
        
        let request = MarkAsInAppMessageClickedRequest(type: config.contactKey.type,
                                                       deviceID: config.applicationIdentifier,
                                                       accountName: accountName,
                                                       contactKey: config.contactKey.key,
                                                       id: messageId,
                                                       buttonId: buttonId, contentId: contentId)
        
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success( _ ):
                if let maxDismissCount = updatedMessage.data.displayTiming.maxDismissCount,
                    let dismissCount = updatedMessage.dismissCount, maxDismissCount > 0, dismissCount < maxDismissCount {
                    break
                } else {
                    self?.removeInAppMessageFromCache(updatedMessage.data.messageDetails ?? "")
                    break
                }
            case .failure(let error):
                Logger.log(message: "setInAppMessageAsClicked_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setInAppMessageAsDismissed(_ message: InAppMessage , contentId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let messageId = message.data.messageDetails else { return }
        let request = MarkAsInAppMessageAsDismissedRequest(type: config.contactKey.type,
                                                           deviceID: config.applicationIdentifier,
                                                           accountName: accountName,
                                                           contactKey: config.contactKey.key,
                                                           id: messageId, contentId: contentId ?? "")
        
        self.removeInAppMessageFromCache(message.data.messageDetails ?? "")
        
        apiClient.send(request: request) { result in
            switch result {
            case .success( _ ):
                break
            case .failure(let error):
                Logger.log(message: "setInAppMessageAsDismissed_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    // Real Time
    private func markAsRealTimeInAppMessageAsDisplayed(message: InAppMessage) {
        guard isEnabledInAppMessage else {return}
        guard let accountName = config.remoteConfiguration?.accountName,
              let appId = config.remoteConfiguration?.appId,
              let messageId = message.data.messageDetails,
              let publicId = message.data.publicId else { return }
        let request = MarkAsRealTimeInAppMessageDisplayedRequest(id: messageId,
                                                                 contactKey: config.contactKey.key,
                                                                 accountName: accountName,
                                                                 deviceID: config.applicationIdentifier,
                                                                 sessionId: sessionManager.currentSessionId,
                                                                 campaignId: publicId,
                                                                 appId: appId,
                                                                 contentId: message.data.content.contentId)
        
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                Logger.log(message: "markAsInAppMessageAsDisplayed_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setRealtimeInAppMessageAsClicked(_ message: InAppMessage, _ buttonId: String?, _ buttonType: String?) {
        guard isEnabledInAppMessage else {return}
        guard
            let remoteConfig = config.remoteConfiguration,
            let accountName = remoteConfig.accountName,
            let messageId = message.data.messageDetails,
            let publicId = message.data.publicId
        else { return }
        let request = MarkAsRealTimeInAppMessageClickedRequest(id: messageId,
                                                               contactKey: config.contactKey.key,
                                                               accountName: accountName,
                                                               deviceID: config.applicationIdentifier,
                                                               buttonId: buttonId,
                                                               sessionId: sessionManager.currentSessionId,
                                                               campaignId: publicId,
                                                               appid: remoteConfig.appId ?? "",
                                                               contentId: message.data.content.contentId)
        
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success( _ ):
                break
            case .failure(let error):
                Logger.log(message: "setInAppMessageAsClicked_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setRealTimeInAppMessageAsDismissed(_ message: InAppMessage) {
        guard isEnabledInAppMessage else { return }
        guard
            let remoteConfig = config.remoteConfiguration,
            let accountName = remoteConfig.accountName,
            let messageId = message.data.messageDetails,
            let publicId = message.data.publicId
        else { return }
        let request = MarkAsRealTimeInAppMessageAsDismissedRequest(id: messageId,
                                                                   contactKey: config.contactKey.key,
                                                                   accountName: accountName,
                                                                   deviceID: config.applicationIdentifier,
                                                                   sessionId: sessionManager.currentSessionId,
                                                                   campaignId: publicId,
                                                                   appId: remoteConfig.appId ?? "",
                                                                   contentId: message.data.content.contentId)
        
        apiClient.send(request: request) { result in
            switch result {
            case .success( _ ):
                break
            case .failure(let error):
                Logger.log(message: "setRealTimeInAppMessageAsDismissed_ERROR", argument: error.localizedDescription)
            }
        }
    }
}

//MARK: - Workers
extension DengageInAppMessageManager {
    
    func showAppStory(inAppMessage: InAppMessage, storyCompletion: ((StoriesListView?) -> Void)?) {
        let data = inAppMessage.data
        
        // Check if same publicId was displayed within last 2 seconds
        if let publicId = data.publicId {
            let currentTime = Date().timeIntervalSince1970
            if let lastDisplayTime = DengageLocalStorage.shared.getStoryLastDisplayTime(publicId: publicId) {
                let timeDifference = currentTime - lastDisplayTime
                if timeDifference < 2.0 {
                    // Same publicId displayed within 2 seconds, prevent duplicate display
                    Logger.log(message: "showAppStory: Duplicate display prevented for publicId: \(publicId), timeDifference: \(timeDifference)")
                    storyCompletion?(nil)
                    return
                }
            }
        }
        
        if let storySet = data.content.props.storySet {
            let storiesListView = StoriesListView()
            let storiesListViewController = StoriesListViewController()
            storiesListView.controller = storiesListViewController
            storiesListView.controller?.storyActionsDelegate = self
            storiesListView.setProperties(title: storySet.title, styling: storySet.styling)
            storiesListViewController.collectionView = storiesListView.collectionView
            storiesListViewController.loadInAppMessage(inAppMessage, data.publicId, data.content.contentId!)
            storiesListView.collectionView.reloadData()
            storiesListView.setDelegates()
            storiesListViewController.collectionView = storiesListView.collectionView
            storyCompletion?(storiesListView)
            
            self.storyEvent(eventType: .display, message: inAppMessage)
            
            // Update last display time after successfully displaying the story
            if let publicId = data.publicId {
                let currentTime = Date().timeIntervalSince1970
                DengageLocalStorage.shared.setStoryLastDisplayTime(publicId: publicId, timestamp: currentTime)
            }
            
        }
    }
    
    func showinlineInapp(propertyId : String , webView : InAppInlineElementView , inAppMessage: InAppMessage)
    {
        if let htmlSTR = inAppMessage.data.content.props.html
        {
          
            webView.message = inAppMessage
            webView.delegate = self
            webView.loadHTMLString(htmlSTR, baseURL: nil)


        }
        

    }
    
    func setNavigation(screenName: String? = nil, params: Dictionary<String,String>? = nil , propertyID : String? = nil
                       , inAppInlineElement : InAppInlineElementView? = nil
                       , hideIfNotFound: Bool = false, storyPropertyID: String? = nil, storyCompletion: ((StoriesListView?) -> Void)? = nil) {

        // Check if an in-app message is already being displayed (skip inline and story messages)
        if isInAppMessageShowing && inAppInlineElement == nil && storyPropertyID == nil {
            Logger.log(message: "setNavigation skipped: An in-app message is already being displayed")
            storyCompletion?(nil)
            return
        }

        // Check if we've received successful responses within the required time frame
        guard let remoteConfig = config.remoteConfiguration else {
            storyCompletion?(nil)
            return
        }
        
        let currentTime = Date().timeMiliseconds
        let fetchIntervalInMin = remoteConfig.inAppFetchIntervalInMin
        let timeoutMinutes = max(fetchIntervalInMin * 4, 60) // Use 1 hour minimum
        let timeoutMilliseconds = Double(timeoutMinutes * 60 * 1000)
        
        let lastSuccessfulInAppFetch = config.lastSuccessfulInAppMessageFetchTime ?? 0
        let lastSuccessfulRealTimeFetch = config.lastSuccessfulRealTimeInAppMessageFetchTime ?? 0
        
        let timeSinceLastInAppFetch = currentTime - lastSuccessfulInAppFetch
        let timeSinceLastRealTimeFetch = currentTime - lastSuccessfulRealTimeFetch
        
        // If both fetches are older than the timeout return
        if timeSinceLastInAppFetch > timeoutMilliseconds && timeSinceLastRealTimeFetch > timeoutMilliseconds {
            Logger.log(message: "setNavigation blocked: No successful in-app message fetch in the last \(timeoutMinutes) minutes")
            storyCompletion?(nil)
            return
        }
        
        guard !(config.inAppMessageShowTime != 0 && Date().timeMiliseconds < config.inAppMessageShowTime) else {
            storyCompletion?(nil)
            return
        }
        
        inAppShowTimer.invalidate()
        
        DengageLocalStorage.shared.set(value: false, for: .cancelInAppMessage)

        let messages = DengageLocalStorage.shared.getInAppMessages()
        guard !messages.isEmpty else {
            storyCompletion?(nil)
            return
        }
        
        let inAppMessages = DengageInAppMessageUtils.findNotExpiredInAppMessages(untilDate: Date(), messages)
        
        guard let priorInAppMessage = DengageInAppMessageUtils.findPriorInAppMessage(inAppMessages: inAppMessages, screenName: screenName, params:params, config: config, propertyId: propertyID, storyPropertyId: storyPropertyID ) else {
            storyCompletion?(nil)
            return
        }
        
        let delay = priorInAppMessage.data.displayTiming.delay ?? 0
        
        DengageLocalStorage.shared.set(value: delay, for: .delayForInAppMessage)
        
        if propertyID != nil
        {
            if let ID = propertyID, let vw = inAppInlineElement
            {
                if priorInAppMessage.data.inlineTarget?.iosSelector == propertyID
                {
                    showinlineInapp(propertyId: ID, webView: vw, inAppMessage: priorInAppMessage)
                }
                else if propertyID != "" && hideIfNotFound
                {
                    inAppInlineElement?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    inAppInlineElement?.isHidden = true

                }
            }
            else if propertyID != "" && hideIfNotFound
            {
                inAppInlineElement?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                inAppInlineElement?.isHidden = true

            }
        } else if let id = storyPropertyID {
            if let iosSelector = priorInAppMessage.data.inlineTarget?.iosSelector, iosSelector == id, ("STORY".caseInsensitiveCompare(priorInAppMessage.data.content.type ?? "")) == .orderedSame
            {
                showAppStory(inAppMessage: priorInAppMessage, storyCompletion: storyCompletion)
                return
            }
        } else {
            if let html = priorInAppMessage.data.content.props.html, Mustache.hasCouponSection(html) {
                let couponContent = Mustache.getCouponContent(html)
                
                // Validate coupon before showing the message
                guard let accountName = config.remoteConfiguration?.accountName,
                      let couponListKey = couponContent else {
                    return
                }
                
                validateCoupon(
                    accountId: accountName,
                    listKey: couponListKey,
                    message: priorInAppMessage
                )
            } else {
                showInAppMessage(inAppMessage: priorInAppMessage, couponCode: "")
            }
        }
        storyCompletion?(nil)

    }
    
    private func validateCoupon(accountId: String, listKey: String, message: InAppMessage) {
        // Mark as showing immediately to prevent duplicate calls during async validation
        isInAppMessageShowing = true

        let request = CouponAssignRequest(
            accountId: accountId,
            listKey: listKey,
            contactKey: config.contactKey.key,
            deviceId: config.applicationIdentifier,
            campaignId: message.id
        )

        apiClient.send(request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let couponCode = response.code {
                        self?.showInAppMessage(inAppMessage: message, couponCode: couponCode)
                    } else {
                        self?.isInAppMessageShowing = false
                        Logger.log(message: "No coupon code received from server")
                        self?.sendCouponValidationFailureLog(
                            couponContent: listKey,
                            errorMessage: "No coupon code received from server",
                            inAppMessage: message,
                            screenName: nil
                        )
                    }
                case .failure(let error):
                    self?.isInAppMessageShowing = false
                    Logger.log(message: "Coupon assignment failed: \(error.localizedDescription)")
                    self?.sendCouponValidationFailureLog(
                        couponContent: listKey,
                        errorMessage: error.localizedDescription,
                        inAppMessage: message,
                        screenName: nil
                    )
                }
            }
        }
    }
    
    private func sendCouponValidationFailureLog(
        couponContent: String,
        errorMessage: String,
        inAppMessage: InAppMessage,
        screenName: String?
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            guard let debugDeviceIds = self.config.remoteConfiguration?.debugDeviceIds,
                  debugDeviceIds.contains(self.config.applicationIdentifier) else {
                return
            }
            
            let traceId = UUID().uuidString
            let campaignId = inAppMessage.data.publicId ?? inAppMessage.id
            
            let debugLog = DebugLog(
                traceId: traceId,
                appGuid: self.config.remoteConfiguration?.appId,
                appId: self.config.remoteConfiguration?.appId,
                account: self.config.remoteConfiguration?.accountName,
                device: self.config.applicationIdentifier,
                sessionId: self.sessionManager.currentSessionId,
                sdkVersion: SDK_VERSION,
                currentCampaignList: [],
                campaignId: campaignId,
                campaignType: inAppMessage.data.isRealTime ? "realtime" : "bulk",
                sendId: nil,
                message: "Coupon validation failed: \(couponContent) - \(errorMessage) traceId: \(traceId) campaignId: \(campaignId)",
                context: ["coupon_code": couponContent],
                contactKey: self.config.getContactKey() ?? "",
                channel: "ios",
                currentRules: [:]
            )
            
            let request = DebugLogRequest(screenName: screenName ?? "unknown", debugLog: debugLog)
            
            self.apiClient.send(request: request) { result in
                switch result {
                case .success:
                    Logger.log(message: "Coupon validation failure debug log sent successfully")
                case .failure(let error):
                    Logger.log(message: "Error sending coupon validation failure debug log: \(error.localizedDescription)")
                }
            }
            
        }
    }

    func removeInAppMessageDisplay() {
        
        DengageLocalStorage.shared.set(value: true, for: .cancelInAppMessage)
        
    }
    
    
    func showInAppMessage(inAppMessage: InAppMessage, couponCode: String = "") {
        // Mark as showing immediately to prevent duplicate calls
        isInAppMessageShowing = true

        let hybridAppEnv = config.getHybridAppEnvironment()
        
        if hybridAppEnv
        {
            let inappShowTime = (Date().timeMiliseconds) + (config.remoteConfiguration?.minSecBetweenMessages ?? 0.0)

            DengageLocalStorage.shared.set(value: inappShowTime, for: .inAppMessageShowTime)

            let delay = inAppMessage.data.displayTiming.delay ?? 0

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {

                if let cancelInAppMessage = DengageLocalStorage.shared.value(for: .cancelInAppMessage) as? Bool
                {
                    if !cancelInAppMessage
                    {
                        if inAppMessage.data.isRealTime {
                            self.markAsRealTimeInAppMessageAsDisplayed(message: inAppMessage)
                        } else {
                            self.markAsInAppMessageAsDisplayed(inAppMessageId: inAppMessage.data.messageDetails, contentId: inAppMessage.data.content.contentId ?? "")
                        }
                        var updatedMessage = inAppMessage
                        if let showEveryXMinutes = inAppMessage.data.displayTiming.showEveryXMinutes,
                           showEveryXMinutes != 0 {
                            updatedMessage.nextDisplayTime = Date().timeMiliseconds + Double(showEveryXMinutes) * 60000.0
                            updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                            self.updateInAppMessageOnCache(updatedMessage)
                            DengageLocalStorage.shared.updateInAppMessageShowCount(messageId: updatedMessage.id, showCount: updatedMessage.showCount ?? 0)
                        } else {
                            if updatedMessage.data.isRealTime {
                                updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                self.updateInAppMessageOnCache(updatedMessage)
                                DengageLocalStorage.shared.updateInAppMessageShowCount(messageId: updatedMessage.id, showCount: updatedMessage.showCount ?? 0)
                            } else {
                                updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                DengageLocalStorage.shared.updateInAppMessageShowCount(messageId: updatedMessage.id, showCount: updatedMessage.showCount ?? 0)
                                self.removeInAppMessageFromCache(inAppMessage.data
                                    .messageDetails ?? "")
                            }
                        }

                        self.showInAppMessageController(with: updatedMessage, couponCode: couponCode)
                    } else {
                        self.isInAppMessageShowing = false
                    }

                }

            }
        }
        else
        {
            let inappShowTime = (Date().timeMiliseconds) + (config.remoteConfiguration?.minSecBetweenMessages ?? 0.0)
                  DengageLocalStorage.shared.set(value: inappShowTime, for: .inAppMessageShowTime)

                  let delay = inAppMessage.data.displayTiming.delay ?? 0
                  
                  inAppShowTimer = Timer.scheduledTimer(withTimeInterval: Double(delay), repeats: false, block: { _ in

                      if let cancelInAppMessage = DengageLocalStorage.shared.value(for: .cancelInAppMessage) as? Bool
                      {
                          if !cancelInAppMessage
                          {
                              if inAppMessage.data.isRealTime {
                                  self.markAsRealTimeInAppMessageAsDisplayed(message: inAppMessage)
                              } else {
                                  self.markAsInAppMessageAsDisplayed(inAppMessageId: inAppMessage.data.messageDetails, contentId: inAppMessage.data.content.contentId ?? "")
                              }
                              var updatedMessage = inAppMessage
                              if let showEveryXMinutes = inAppMessage.data.displayTiming.showEveryXMinutes,
                                 showEveryXMinutes != 0 {
                                  updatedMessage.nextDisplayTime = Date().timeMiliseconds + Double(showEveryXMinutes) * 60000.0
                                  updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                  self.updateInAppMessageOnCache(updatedMessage)
                                  DengageLocalStorage.shared.updateInAppMessageShowCount(messageId: updatedMessage.id, showCount: updatedMessage.showCount ?? 0)
                              } else {
                                  if updatedMessage.data.isRealTime {
                                      updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                      self.updateInAppMessageOnCache(updatedMessage)
                                      DengageLocalStorage.shared.updateInAppMessageShowCount(messageId: updatedMessage.id, showCount: updatedMessage.showCount ?? 0)
                                  } else {
                                      updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                      DengageLocalStorage.shared.updateInAppMessageShowCount(messageId: updatedMessage.id, showCount: updatedMessage.showCount ?? 0)
                                      self.removeInAppMessageFromCache(inAppMessage.data
                                          .messageDetails ?? "")
                                  }
                              }

                              self.showInAppMessageController(with: updatedMessage, couponCode: couponCode)
                          } else {
                              self.isInAppMessageShowing = false
                          }
                      }

                  })

        }
        
        
            
      
    }
    
    private func showInAppMessageController(with message:InAppMessage, couponCode: String){
       
        guard message.data.content.props.html != nil else {return}
        let controller = InAppMessageHTMLViewController(with: message, couponCode: couponCode)
        controller.delegate = self
        self.createInAppWindow(for: controller)
        
    }
    
    private func showInAppBrowserController(with url:String)
    {
        
        let controller = InAppBrowserViewController(with: url)
        controller.delegate = self
        self.createInAppBrowserWindow(for: controller)
        
    }
    
    private func createInAppBrowserWindow(for controller: UIViewController)
    {
        
        if #available(iOS 13.0, *) {
            if let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) {
                
                if let topNotch = windowScene.windows.first?.safeAreaInsets.top
                {
                    let frame = CGRect(x: 0, y: topNotch, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topNotch)
                    inAppBrowserWindow = UIWindow(frame: frame)
                    inAppBrowserWindow = UIWindow(windowScene: windowScene)
                    inAppBrowserWindow?.rootViewController = controller
                    inAppBrowserWindow?.makeKeyAndVisible()
                }
                else
                {
                    inAppBrowserWindow = UIWindow(frame: UIScreen.main.bounds)
                    inAppBrowserWindow = UIWindow(windowScene: windowScene)
                    inAppBrowserWindow?.rootViewController = controller
                    inAppBrowserWindow?.makeKeyAndVisible()
                }
               
            }
            else {
                
                if let topNotch = UIApplication.shared.delegate?.window??.safeAreaInsets.top
                {
                    if topNotch > 20
                    {
                        let frame = CGRect(x: 0, y: topNotch, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topNotch)
                        inAppBrowserWindow = UIWindow(frame: frame)
                        inAppBrowserWindow?.rootViewController = controller
                        inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                        inAppBrowserWindow?.makeKeyAndVisible()
                    }
                    else
                    {
                        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        inAppBrowserWindow = UIWindow(frame: frame)
                        inAppBrowserWindow?.rootViewController = controller
                        inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                        inAppBrowserWindow?.makeKeyAndVisible()
                    }
                }
                else
                {
                    let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    inAppBrowserWindow = UIWindow(frame: frame)
                    inAppBrowserWindow?.rootViewController = controller
                    inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                    inAppBrowserWindow?.makeKeyAndVisible()
                }
                
                
                
            }
        } else {
            if #available(iOS 11.0, *) {
              
                if let topNotch = UIApplication.shared.delegate?.window??.safeAreaInsets.top
                {
                    if topNotch > 20
                    {
                        let frame = CGRect(x: 0, y: topNotch, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topNotch)
                        inAppBrowserWindow = UIWindow(frame: frame)
                        inAppBrowserWindow?.rootViewController = controller
                        inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                        inAppBrowserWindow?.makeKeyAndVisible()
                    }
                    else
                    {
                        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        inAppBrowserWindow = UIWindow(frame: frame)
                        inAppBrowserWindow?.rootViewController = controller
                        inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                        inAppBrowserWindow?.makeKeyAndVisible()
                    }
                }
                else
                {
                    let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    inAppBrowserWindow = UIWindow(frame: frame)
                    inAppBrowserWindow?.rootViewController = controller
                    inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                    inAppBrowserWindow?.makeKeyAndVisible()
                }
                
                
                
            } else {
            //backward compatibility to previous versions?
                
                let frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                inAppBrowserWindow = UIWindow(frame: frame)
                inAppBrowserWindow?.rootViewController = controller
                inAppBrowserWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                inAppBrowserWindow?.makeKeyAndVisible()
                
                
            }
        }
    }
    
    private func createInAppWindow(for controller: UIViewController){
        
        
        if #available(iOS 13.0, *) {
            
            if let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) {
                inAppMessageWindow = UIWindow(frame: UIScreen.main.bounds)
                inAppMessageWindow = UIWindow(windowScene: windowScene)
                inAppMessageWindow?.rootViewController = controller
                inAppMessageWindow?.makeKeyAndVisible()
            }
            else {
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                inAppMessageWindow = UIWindow(frame: frame)
                inAppMessageWindow?.rootViewController = controller
                inAppMessageWindow?.windowLevel = UIWindow.Level(rawValue: 2)
                inAppMessageWindow?.makeKeyAndVisible()
            }
            
            
        } else {
            
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            inAppMessageWindow = UIWindow(frame: frame)
            inAppMessageWindow?.rootViewController = controller
            inAppMessageWindow?.windowLevel = UIWindow.Level(rawValue: 2)
            inAppMessageWindow?.makeKeyAndVisible()
        }
    
        
    }
    
    private func updateInAppMessageOnCache(_ message: InAppMessage){
        let previousMessages = DengageLocalStorage.shared.getInAppMessages()
        var updatedMessages = previousMessages.filter{$0.data.messageDetails != message.data.messageDetails}
        updatedMessages.append(message)
        DengageLocalStorage.shared.save(updatedMessages)
    }
    
    private func addInAppMessagesIfNeeded(_ messages: [InAppMessage], forRealTime: Bool = false) {
        DispatchQueue.main.async {
            let showHistory = DengageLocalStorage.shared.getInAppMessageShowHistory()

            if forRealTime {
                let previousMessages = DengageLocalStorage.shared.getInAppMessages()
                let inappMessages = previousMessages.filter { !$0.data.isRealTime }
                var realTimeMessages = previousMessages.filter { $0.data.isRealTime }

                // Filter and save only the previous messages that are also in the new messages list.
                if !realTimeMessages.isEmpty {
                    let localMessages = realTimeMessages.filter { messages.contains($0) }
                    DengageLocalStorage.shared.save(localMessages)
                    realTimeMessages = DengageLocalStorage.shared.getInAppMessages().filter { $0.data.isRealTime }
                }

                // Map each server message:
                // If a matching message exists in previousMessages, update it; otherwise, check show history.
                let updatedRealTimeMessages = messages.map { serverMsg -> InAppMessage in
                    if let prevMsg = realTimeMessages.first(where: { $0.id == serverMsg.id }) {
                        return InAppMessage(
                            id: serverMsg.id,
                            data: serverMsg.data,
                            nextDisplayTime: prevMsg.nextDisplayTime,
                            showCount: prevMsg.showCount,
                            dismissCount: prevMsg.dismissCount
                        )
                    }
                    // Check show history for messages not in cache
                    if let historyEntry = showHistory[serverMsg.id] {
                        return InAppMessage(
                            id: serverMsg.id,
                            data: serverMsg.data,
                            nextDisplayTime: serverMsg.nextDisplayTime,
                            showCount: historyEntry.showCount,
                            dismissCount: serverMsg.dismissCount
                        )
                    }
                    return serverMsg
                }
                DengageLocalStorage.shared.save(updatedRealTimeMessages + inappMessages)
            } else {
                var previousMessages = DengageLocalStorage.shared.getInAppMessages()

                let updatedIncomingMessages = messages.map { newMsg -> InAppMessage in
                    if let oldMsg = previousMessages.first(where: { $0.id == newMsg.id }) {
                        return InAppMessage(
                            id: newMsg.id,
                            data: newMsg.data,
                            nextDisplayTime: oldMsg.nextDisplayTime,
                            showCount: oldMsg.showCount,
                            dismissCount: oldMsg.dismissCount
                        )
                    }
                    // Check show history for messages not in cache
                    if let historyEntry = showHistory[newMsg.id] {
                        return InAppMessage(
                            id: newMsg.id,
                            data: newMsg.data,
                            nextDisplayTime: newMsg.nextDisplayTime,
                            showCount: historyEntry.showCount,
                            dismissCount: newMsg.dismissCount
                        )
                    }
                    return newMsg
                }

                previousMessages.removeAll { storedMsg in
                    updatedIncomingMessages.contains { $0.id == storedMsg.id }
                }
                previousMessages.append(contentsOf: updatedIncomingMessages)
                DengageLocalStorage.shared.save(previousMessages)
            }
        }
    }

    private func removeInAppMessageFromCache(_ messageDetails: String){
        let previousMessages = DengageLocalStorage.shared.getInAppMessages()
        DengageLocalStorage.shared.save(previousMessages.filter{($0.data.messageDetails ?? "") != messageDetails})
    }
    
    private func removeExpiredInAppMessageFromCache(_ messageIds:[InAppRemovalId]){
        let previousMessages = DengageLocalStorage.shared.getInAppMessages()
        for messageId in messageIds {
            DengageLocalStorage.shared.save(previousMessages.filter{($0.id) != messageId.id})
        }
    }
    
    private var isEnabledInAppMessage:Bool{
        guard let config = self.config.remoteConfiguration,
              config.accountName != nil else { return false }
        guard config.inAppEnabled else { return false }
        return true
    }
    
    private var isEnabledRealTimeInAppMessage:Bool{
        guard let config = self.config.remoteConfiguration,
              config.accountName != nil else { return false }
        guard config.realTimeInAppEnabled else { return false }
        return true
    }
    
    private var shouldFetchInAppMessages:Bool {
        
        if let appEnvironment = DengageLocalStorage.shared.value(for: .appEnvironment) as? Bool
        {
            if appEnvironment
            {
                guard isEnabledInAppMessage else {return false}
                return true
            }
            else
            {
                guard isEnabledInAppMessage else {return false}
                guard let lastFetchedTime = config.inAppMessageLastFetchedTime else { return true }
                guard Date().timeMiliseconds >= lastFetchedTime else { return false }
                return true
            }
        }
        else
        {
            guard isEnabledInAppMessage else {return false}
            guard let lastFetchedTime = config.inAppMessageLastFetchedTime else { return true }
            guard Date().timeMiliseconds >= lastFetchedTime else { return false }
            return true
        }
    }
    
    private var expiredMessagesFetchIntervalInMin:Bool{
        guard isEnabledInAppMessage else {return false}
        guard let expiredMessagesFetchIntervalInMin = config.expiredMessagesFetchIntervalInMin else {return true}
        guard Date().timeMiliseconds >= expiredMessagesFetchIntervalInMin else {return false}
        return true
    }
    
    private var shouldFetchRealTimeInAppMessages:Bool {
        
        if let appEnvironment = DengageLocalStorage.shared.value(for: .appEnvironment) as? Bool
        {
            if appEnvironment
            {
                guard isEnabledRealTimeInAppMessage else {return false}
                return true

            }
            else
            {
                guard isEnabledRealTimeInAppMessage else {return false}
                guard let lastFetchedTime = config.realTimeInAppMessageLastFetchedTime else { return true }
                guard Date().timeMiliseconds >= lastFetchedTime else { return false }
                return true
            }
        }
        else
        {
            guard isEnabledRealTimeInAppMessage else {return false}
            guard let lastFetchedTime = config.realTimeInAppMessageLastFetchedTime else { return true }
            guard Date().timeMiliseconds >= lastFetchedTime else { return false }
            return true
        }
      
    }
    
    private func registerLifeCycleTrackers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    @objc private func willEnterForeground() {
        fetchInAppMessages()
        Dengage.dengage?.eventManager.cleanupClientEvents()
        
        // Restart the hourly timer when app comes to foreground
        startHourlyFetchTimer()
        
        DengageLocalStorage.shared.set(value: Date().timeIntervalSince1970, for: .lastSessionStartTime)
        
        guard
            let lastSessionDuration = DengageLocalStorage.shared.value(for: .lastSessionDuration) as? Double,
            let remoteConfig = config.remoteConfiguration,
            let accountName = remoteConfig.accountName,
            let appId = remoteConfig.appId
        else {
            return
        }
        let request = AppForegroundEventRequest(sessionId: sessionManager.currentSessionId,
                                                contactKey: config.contactKey.key,
                                                deviceId: config.applicationIdentifier,
                                                accountName: accountName,
                                                appId: appId,
                                                duration: String(lastSessionDuration))
        apiClient.send(request: request) { result in
            switch result {
            case .success( _ ):
                DengageLocalStorage.shared.set(value: nil, for: .lastSessionDuration)
            case .failure(let error):
                Logger.log(message: "willEnterForeground_ERROR", argument: error.localizedDescription)
            }
        }
        
        
    }
    
    @objc private func didEnterBackground(){
        // Stop the hourly timer when app goes to background
        stopHourlyFetchTimer()
        
        DengageLocalStorage.shared.set(value: Date().timeIntervalSince1970, for: .lastVisitTime)
        guard let lastSessionStartTime = DengageLocalStorage.shared.value(for: .lastSessionStartTime) as? Double else { return }
        let lastSessionDuration = Date().timeIntervalSince1970 - lastSessionStartTime
        DengageLocalStorage.shared.set(value: lastSessionDuration, for: .lastSessionDuration)
    }
    
    private func startHourlyFetchTimer() {
        // Stop any existing timer first
        stopHourlyFetchTimer()
        
        // Start a new timer that fires every hour (3600 seconds)
        hourlyFetchTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            // Only fetch if app is in foreground
            if UIApplication.shared.applicationState == .active {
                self?.fetchInAppMessages()
            }
        }
    }
    
    private func stopHourlyFetchTimer() {
        hourlyFetchTimer?.invalidate()
        hourlyFetchTimer = nil
    }
}

//MARK: - InAppMessagesViewController Delegate

extension DengageInAppMessageManager: InAppMessagesActionsDelegate{
    func setTags(tags: [TagItem]) {
        Dengage.setTags(tags)
    }
    
    func open(url: String?) {
        isInAppMessageShowing = false
        inAppMessageWindow = nil

        guard let urlDeeplink = url, let urlStr = URL(string: urlDeeplink) else { return }
        
        let deeplink = config.getDeeplink()
        let retrieveLinkOnSameScreen = config.getRetrieveLinkOnSameScreen()
        let openInAppBrowser = config.getOpenInAppBrowser()
        
        if !deeplink.isEmpty {
            if urlDeeplink.contains(deeplink) || deeplink.contains(urlDeeplink) {
                if retrieveLinkOnSameScreen {
                    self.returnAfterDeeplinkRecieved?(urlDeeplink)
                } else {
                    self.returnAfterDeeplinkRecieved?(urlDeeplink)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                       
                        UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)

                    }
                    
                }
            } else {
                if retrieveLinkOnSameScreen && !openInAppBrowser {
                    self.returnAfterDeeplinkRecieved?(urlDeeplink)
                } else if !retrieveLinkOnSameScreen && openInAppBrowser {
                    self.showInAppBrowserController(with: urlDeeplink)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                       
                        UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)

                    }
                }
            }
        } else {
            if retrieveLinkOnSameScreen && !openInAppBrowser {
                self.returnAfterDeeplinkRecieved?(urlDeeplink)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   
                    UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)

                }
            }
        }
    }
    
    func sendDismissEvent(message: InAppMessage) {
        isInAppMessageShowing = false
        inAppMessageWindow = nil
        if message.data.isRealTime {
            setRealTimeInAppMessageAsDismissed(message)
        }else {
            setInAppMessageAsDismissed(message, contentId: message.data.content.contentId)
        }
    }
    
    func sendClickEvent(message: InAppMessage, buttonId:String?, buttonType: String?) {
        isInAppMessageShowing = false
        inAppMessageWindow = nil
        if message.data.isRealTime {
            setRealtimeInAppMessageAsClicked(message, buttonId, buttonType)
        } else {
            setInAppMessageAsClicked(message, buttonId, buttonType, message.data.content.contentId ?? "")
        }
    }
    
    func promptPushPermission(){
        Dengage.promptForPushNotifications { isUserGranted in
            if !isUserGranted {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
        }
    }
    
    func openApplicationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    func close() {
        isInAppMessageShowing = false
        inAppMessageWindow = nil
    }
    
    func closeInAppBrowser(){
        inAppBrowserWindow = nil
    }
    
}

//MARK: - StoryViewController Delegate

extension DengageInAppMessageManager: StoryActionsDelegate {
    
    func storyEvent(eventType: StoryEventType, message: InAppMessage, storyProfileId: String = "", storyProfileName: String = ""
                    , storyId: String = "", storyName: String = "", buttonUrl: String = "")  {
        
        guard let accountName = config.remoteConfiguration?.accountName,
              let appId = config.remoteConfiguration?.appId,
              let messageId = message.data.messageDetails,
              let publicId = message.data.publicId else { return }
        let request = StoryRequest(id: messageId,
                                   contactKey: config.contactKey.key,
                                   accountName: accountName,
                                   deviceID: config.applicationIdentifier,
                                   sessionId: sessionManager.currentSessionId,
                                   campaignId: publicId,
                                   appid: appId,
                                   contentId: message.data.content.contentId,
                                   storyEventType: eventType,
                                   storyProfileId: storyProfileId,
                                   storyProfileName: storyProfileName,
                                   storyId: storyId,
                                   storyName: storyName)
        
        apiClient.send(request: request) { result in
            switch result {
            case .success( _ ):
                break
            case .failure(let error):
                Logger.log(message: "storyEvent_\(eventType.rawValue)_ERROR", argument: error.localizedDescription)
            }
        }
        
        if eventType == .storyClick {
            guard let urlStr = URL(string: buttonUrl) else { return }
            let deeplink = config.getDeeplink()
            
            if !deeplink.isEmpty {
                if buttonUrl.contains(deeplink) || deeplink.contains(buttonUrl) {
                    self.returnAfterDeeplinkRecieved?(buttonUrl)
                    UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)
                }
            }
            else {
                UIApplication.shared.open(urlStr , options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func setStoryCoverShown(storyCoverId: String, storySetId: String) {
        var shownStoryCovers = DengageLocalStorage.shared.value(for: .shownStoryCoverDic) as? [String: [String]] ?? [String: [String]]()
        if shownStoryCovers["\(storySetId)"] == nil {
            shownStoryCovers["\(storySetId)"] = [storyCoverId]
        } else if let st = shownStoryCovers["\(storySetId)"], !st.contains(storyCoverId) {
            shownStoryCovers["\(storySetId)"]?.append(storyCoverId)
        }
        DengageLocalStorage.shared.set(value: shownStoryCovers, for: .shownStoryCoverDic)
    }
    
    func sortStoryCovers(storyCovers: [StoryCover], storySetId: String) -> [StoryCover] {
        var shownStoryCovers: [StoryCover] = []
        var notShownStoryCovers: [StoryCover] = []
        for storyCover in storyCovers.sorted(by: { $0.shown && !$1.shown }) {
            var shown = false
            if let shownStoryCovers = DengageLocalStorage.shared.value(for: .shownStoryCoverDic) as? [String: [String]] {
                if let shownStoryCoversWithSetId = shownStoryCovers["\(storySetId)"], shownStoryCoversWithSetId.contains(storyCover.id) {
                    shown = true
                }
            }
            if shown {
                shownStoryCovers.append(storyCover)
            } else {
                notShownStoryCovers.append(storyCover)
            }
        }
        return notShownStoryCovers + shownStoryCovers
    }
    
}


protocol DengageInAppMessageManagerInterface: AnyObject{
    
    func fetchInAppMessages()
    func setNavigation(screenName: String?, params: Dictionary<String,String>? , propertyID : String? , webView : InAppInlineElementView?
                       ,storyPropertyID: String?, storyCompletion: ((StoriesListView?) -> Void)?)
    func showInAppMessage(inAppMessage: InAppMessage, couponCode: String)
    func fetchInAppExpiredMessageIds()
    func removeInAppMessageDisplay()
    
    
}

extension DengageInAppMessageManagerInterface {
    func setNavigation(screenName: String? = nil, params: Dictionary<String,String>? = nil , propertyID : String? = nil , webView : InAppInlineElementView? = nil
                       , storyPropertyID: String?, storyCompletion: ((StoriesListView?) -> Void)?) {
        setNavigation(screenName: screenName, params: params, propertyID: propertyID, webView: webView, storyPropertyID: storyPropertyID, storyCompletion: storyCompletion)
    }
}

struct VisitData{
    let date:String
    let count: Int
}

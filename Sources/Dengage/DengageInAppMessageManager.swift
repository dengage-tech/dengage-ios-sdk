import Foundation
import WebKit
import UIKit
import SafariServices

public class DengageInAppMessageManager:DengageInAppMessageManagerInterface {
   
   
    
    var config: DengageConfiguration
    var apiClient: DengageNetworking
    var inAppMessageWindow: UIWindow?
    let sessionManager: DengageSessionManagerInterface
    var inAppBrowserWindow: UIWindow?
    public var returnAfterDeeplinkRecieved : ((String) -> Void)?
    var inAppShowTimer = Timer()
    

    init(config: DengageConfiguration,
         service: DengageNetworking,
         sessionManager: DengageSessionManagerInterface) {
        self.config = config
        self.apiClient = service
        self.sessionManager = sessionManager
        registerLifeCycleTrackers()
    }
}

//MARK: - API
extension DengageInAppMessageManager{
    func fetchInAppMessages(){
        fetchRealTimeMessages()
       // getVisitorInfo()
        Logger.log(message: "fetchInAppMessages called")
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
                self?.addInAppMessagesIfNeeded(response)
                self?.fetchInAppExpiredMessages()
                
            case .failure(let error):
                Logger.log(message: "fetchInAppMessages_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    func fetchInAppExpiredMessages(){
        Logger.log(message: "fetchInAppExpiredMessages called")
        guard expiredMessagesFetchIntervalInMin else {return}
        if DengageLocalStorage.shared.getInAppMessages().count == 0
        {
            return
        }
        guard let remoteConfig = config.remoteConfiguration, let accountName = remoteConfig.accountName ,let appid = remoteConfig.appId else { return }
        Logger.log(message: "fetchInAppMessages request started")
        let request = ExpiredInAppMessageRequest.init(accountName: accountName, contactKey: config.contactKey.key, appid: appid)
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchexpiredMessagesFetchIntervalInMin)
                DengageLocalStorage.shared.set(value: nextFetchTime, for: .expiredMessagesFetchIntervalInMin)
                self?.removeExpiredInAppMessageFromCache(response)
            case .failure(let error):
                Logger.log(message: "fetchInAppMessages_ERROR", argument: error.localizedDescription)
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
        let request = GetRealTimeMesagesRequest(accountName: accountName, appId: appId)
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchIntervalInMin)
                DengageLocalStorage.shared.set(value: nextFetchTime, for: .lastFetchedRealTimeInAppMessageTime)
                let arrRealTimeInAppMessages = InAppMessage.mapRealTime(source: response)
                self?.addInAppMessagesIfNeeded(arrRealTimeInAppMessages, forRealTime: true)
                
            case .failure(let error):
                Logger.log(message: "fetchRealTimeInAppMessages_ERROR", argument: error.localizedDescription)
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
    
    private func setInAppMessageAsClicked(_ messageId: String?, _ buttonId: String? , _ contentId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let messageId = messageId else { return }
        let request = MarkAsInAppMessageClickedRequest(type: config.contactKey.type,
                                                       deviceID: config.applicationIdentifier,
                                                       accountName: accountName,
                                                       contactKey: config.contactKey.key,
                                                       id: messageId,
                                                       buttonId: buttonId, contentId: contentId)
        
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success( _ ):
                self?.removeInAppMessageFromCache(messageId)
            case .failure(let error):
                Logger.log(message: "setInAppMessageAsClicked_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setInAppMessageAsDismissed(_ inAppMessageId: String? , contentId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let messageId = inAppMessageId else { return }
        let request = MarkAsInAppMessageAsDismissedRequest(type: config.contactKey.type,
                                                           deviceID: config.applicationIdentifier,
                                                           accountName: accountName,
                                                           contactKey: config.contactKey.key,
                                                           id: messageId, contentId: contentId ?? "")
        
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
    
    private func setRealtimeInAppMessageAsClicked(_ message: InAppMessage, _ buttonId: String?) {
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
//                if let count = message.showCount , let maxShowCount = message.data.displayTiming.maxShowCount
//                {
//                    if count >= maxShowCount
//                    {
//                        self?.removeInAppMessageFromCache(messageId)
//                    }
//                }
//                else
//                {
//                    self?.removeInAppMessageFromCache(messageId)
//
//                }
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
                Logger.log(message: "setInAppMessageAsDismissed_ERROR", argument: error.localizedDescription)
            }
        }
    }
}

//MARK: - Workers
extension DengageInAppMessageManager {
    

    
    func showinlineInapp(propertyId : String , webView : InAppInlineElementView , inAppMessage: InAppMessage)
    {
        if let htmlSTR = inAppMessage.data.content.props.html
        {
          
            webView.message = inAppMessage
            webView.delegate = self
            webView.loadHTMLString(htmlSTR, baseURL: nil)


        }
        

    }
    
    func setNavigation(screenName: String? = nil, params: Dictionary<String,String>? = nil , propertyID : String? = nil , inAppInlineElement : InAppInlineElementView? = nil , hideIfNotFound: Bool = false) {
        
        guard !(config.inAppMessageShowTime != 0 && Date().timeMiliseconds < config.inAppMessageShowTime) else {return}
        
        inAppShowTimer.invalidate()
        
        DengageLocalStorage.shared.set(value: false, for: .cancelInAppMessage)

        let messages = DengageLocalStorage.shared.getInAppMessages()
        guard !messages.isEmpty else {return}
        
        let inAppMessages = DengageInAppMessageUtils.findNotExpiredInAppMessages(untilDate: Date(), messages)
        
        guard let priorInAppMessage = DengageInAppMessageUtils.findPriorInAppMessage(inAppMessages: inAppMessages, screenName: screenName, params:params, config: config, propertyId: propertyID ) else {return}
       
        
        let delay = priorInAppMessage.data.displayTiming.delay ?? 0
        
        DengageLocalStorage.shared.set(value: delay, for: .delayForInAppMessage)
        
        if propertyID != nil
        {
            if let ID = propertyID ,  let vw = inAppInlineElement
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

        }
        else
        {
            showInAppMessage(inAppMessage: priorInAppMessage)

        }

    }

    func removeInAppMessageDisplay() {
        
        DengageLocalStorage.shared.set(value: true, for: .cancelInAppMessage)
        
    }
    
    
    func showInAppMessage(inAppMessage: InAppMessage) {
        
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
                        } else {
                            if updatedMessage.data.isRealTime {
                                updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                self.updateInAppMessageOnCache(updatedMessage)
                            } else {
                                self.removeInAppMessageFromCache(inAppMessage.data
                                    .messageDetails ?? "")
                            }
                        }
                        
                        self.showInAppMessageController(with: inAppMessage)
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
                              } else {
                                  if updatedMessage.data.isRealTime {
                                      updatedMessage.showCount = (updatedMessage.showCount ?? 0) + 1
                                      self.updateInAppMessageOnCache(updatedMessage)
                                  } else {
                                      self.removeInAppMessageFromCache(inAppMessage.data
                                          .messageDetails ?? "")
                                  }
                              }
                              
                              self.showInAppMessageController(with: inAppMessage)
                          }
                      }
                      
                  })
              
        }
        
        
            
      
    }
    
    private func showInAppMessageController(with message:InAppMessage){
       
        guard message.data.content.props.html != nil else {return}
        let controller = InAppMessageHTMLViewController(with: message)
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
    
    private func addInAppMessagesIfNeeded(_ messages:[InAppMessage], forRealTime: Bool = false){
        
        DispatchQueue.main.async {
            
            if forRealTime {
                
                var localArrMessages = [InAppMessage]()

                var previousMessages = DengageLocalStorage.shared.getInAppMessages()
                
                if previousMessages.count > 0
                {
                    for i in 0...previousMessages.count - 1
                    {
                        let prevMsg = previousMessages[i]
                        if (messages.contains(prevMsg))
                        {
                            localArrMessages.append(prevMsg)
                        }
                        
                    }
                    
                    DengageLocalStorage.shared.save(localArrMessages)
                    previousMessages = DengageLocalStorage.shared.getInAppMessages()
                }
               
                
                var updatedMessages = [InAppMessage]()

                if previousMessages.count > 0
                {
                    for serverMsg in messages
                    {
                        for prevMsg in previousMessages
                        {
                            if prevMsg.id == serverMsg.id  && !(updatedMessages.contains(where: {$0.id == serverMsg.id}))
                            {
                                let updatedMessage = InAppMessage(id: serverMsg.id,data: serverMsg.data,nextDisplayTime: prevMsg.nextDisplayTime,showCount: prevMsg.showCount)
                            
                                updatedMessages.append(updatedMessage)
                            }
                            else if !(previousMessages.contains(serverMsg))
                            {
                                updatedMessages.append(serverMsg)

                            }
                        }
                    }
                }
                else
                {
                    updatedMessages.append(contentsOf: messages)
                }

                DengageLocalStorage.shared.save(updatedMessages)
                
            }
            else  {
                var previousMessages = DengageLocalStorage.shared.getInAppMessages()
                previousMessages.removeAll{ message in
                    messages.contains{ $0.id == message.id }
                }
                
//                var msg = previousMessages.filter({$0.data.content.contentId == "a3300e2b-3d68-49bd-8571-4d2701247e3a"})
//                previousMessages.removeAll()
//                previousMessages.append(contentsOf: msg)
                
                previousMessages.append(contentsOf: messages)
                DengageLocalStorage.shared.save(previousMessages)

            }
            
        }
    }
    
    private func removeInAppMessageFromCache(_ messageId: String){
        let previousMessages = DengageLocalStorage.shared.getInAppMessages()
        DengageLocalStorage.shared.save(previousMessages.filter{($0.data.messageDetails ?? "") != messageId})
    }
    
    private func removeExpiredInAppMessageFromCache(_ messages:[InAppMessage]){
        let previousMessages = DengageLocalStorage.shared.getInAppMessages()
        for msg in messages
        {
            DengageLocalStorage.shared.save(previousMessages.filter{($0.id) != msg.id})
            
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
                Logger.log(message: "setInAppMessageAsDismissed_ERROR", argument: error.localizedDescription)
            }
        }
        
        
    }
    @objc private func didEnterBackground(){
        DengageLocalStorage.shared.set(value: Date().timeIntervalSince1970, for: .lastVisitTime)
        guard let lastSessionStartTime = DengageLocalStorage.shared.value(for: .lastSessionStartTime) as? Double else { return }
        let lastSessionDuration = Date().timeIntervalSince1970 - lastSessionStartTime
        DengageLocalStorage.shared.set(value: lastSessionDuration, for: .lastSessionDuration)
    }
    
}
//MARK: - InAppMessagesViewController Delegate

extension DengageInAppMessageManager: InAppMessagesActionsDelegate{
    func setTags(tags: [TagItem]) {
        Dengage.setTags(tags)
    }
    
    func open(url: String?) {
        
        inAppMessageWindow = nil
                
        guard let urlDeeplink = url, let urlStr = URL(string: urlDeeplink) else { return }
        
        let deeplink = config.getDeeplink()
        let RetrieveLinkOnSameScreen = config.getRetrieveLinkOnSameScreen()
        let OpenInAppBrowser = config.getOpenInAppBrowser()
        
        if deeplink != ""
        {
            if urlDeeplink.contains(deeplink) || deeplink.contains(urlDeeplink)
            {
                if RetrieveLinkOnSameScreen
                {
                    self.returnAfterDeeplinkRecieved!(urlDeeplink)
                }
                else
                {
                   
                    self.returnAfterDeeplinkRecieved!(urlDeeplink)
                    UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)
                }
              
            }
            else
            {
                if RetrieveLinkOnSameScreen && !OpenInAppBrowser
                {
                    self.returnAfterDeeplinkRecieved!(urlDeeplink)

                }
                else if !RetrieveLinkOnSameScreen && OpenInAppBrowser
                {
                    self.showInAppBrowserController(with: urlDeeplink)
                    
                }
                else
                {
                    UIApplication.shared.open(urlStr, options: [:], completionHandler: nil)
                }
            }
        }
        else
        {
            if RetrieveLinkOnSameScreen && !OpenInAppBrowser
            {
                self.returnAfterDeeplinkRecieved!(urlDeeplink)

            }
            else
            {
                UIApplication.shared.open(urlStr , options: [:], completionHandler: nil)

            }
                        
        }
      
        
   
    }
    
    func sendDissmissEvent(message: InAppMessage) {
        inAppMessageWindow = nil
        if message.data.isRealTime {
            setRealTimeInAppMessageAsDismissed(message)
        }else {
            setInAppMessageAsDismissed(message.data.messageDetails, contentId: message.data.content.contentId)
        }
    }
    
    func sendClickEvent(message: InAppMessage, buttonId:String?) {
        inAppMessageWindow = nil
        if message.data.isRealTime {
            setRealtimeInAppMessageAsClicked(message, buttonId)
        } else {
            setInAppMessageAsClicked(message.data.messageDetails, buttonId, message.data.content.contentId ?? "")
        }
    }
    
    func promptPushPermission(){
        
        Dengage.promptForPushNotifications { isUserGranted in
            
            if !isUserGranted
            {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    
                    DispatchQueue.main.async {
                        
                        UIApplication.shared.open(appSettings)

                    }
                    
                }
            }
        }
        
    }
    
    func close() {
        
        inAppMessageWindow = nil
    }
    
    func closeInAppBrowser()
    {
        inAppBrowserWindow = nil

    }
    
}


protocol DengageInAppMessageManagerInterface: AnyObject{
    
    func fetchInAppMessages()
    func setNavigation(screenName: String?, params: Dictionary<String,String>? , propertyID : String? , webView : InAppInlineElementView? )
    func showInAppMessage(inAppMessage: InAppMessage)
    func fetchInAppExpiredMessages()
    func removeInAppMessageDisplay()

    
    
}

extension DengageInAppMessageManagerInterface {
    func setNavigation(screenName: String? = nil, params: Dictionary<String,String>? = nil , propertyID : String? = nil , webView : InAppInlineElementView? = nil){
        setNavigation(screenName: screenName, params: params,propertyID: propertyID, webView: webView)
    }
}

struct VisitData{
    let date:String
    let count: Int
}


final class DengageLifeCycleTracker {
    
}


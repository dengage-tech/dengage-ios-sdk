import Foundation
import UIKit

final class DengageInAppMessageManager:DengageInAppMessageManagerInterface {
    
    
       
    var config: DengageConfiguration
    var apiClient: DengageNetworking
    var inAppMessageWindow: UIWindow?
    var deeplinkURL: String?

    init(config: DengageConfiguration, service: DengageNetworking){
        self.config = config
        self.apiClient = service
        registerLifeCycleTrackers()
    }
}

//MARK: - API
extension DengageInAppMessageManager{
    func fetchInAppMessages(){
        Logger.log(message: "fetchInAppMessages called")
        guard shouldFetchInAppMessages else {return}
        guard let remoteConfig = config.remoteConfiguration, let accountName = remoteConfig.accountName else { return }
        Logger.log(message: "fetchInAppMessages request started")
        let request = GetInAppMessagesRequest(accountName: accountName,
                                              contactKey: config.contactKey.key,
                                              type: config.contactKey.type,
                                              deviceId: config.applicationIdentifier)
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let nextFetchTime = (Date().timeMiliseconds) + (remoteConfig.fetchexpiredMessagesFetchIntervalInMin)
                DengageLocalStorage.shared.set(value: nextFetchTime, for: .expiredMessagesFetchIntervalInMin)
                
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
    
    private func markAsInAppMessageAsDisplayed(inAppMessageId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let accountName = config.remoteConfiguration?.accountName,
              let messageId = inAppMessageId else { return }
        let request = MarkAsInAppMessageDisplayedRequest(type: config.contactKey.type,
                                                         deviceID: config.applicationIdentifier,
                                                         accountName: accountName,
                                                         contactKey: config.contactKey.key,
                                                         id: messageId)
        
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                Logger.log(message: "markAsInAppMessageAsDisplayed_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setInAppMessageAsClicked(_ messageId: String?, _ buttonId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let messageId = messageId else { return }
        let request = MarkAsInAppMessageClickedRequest(type: config.contactKey.type,
                                                       deviceID: config.applicationIdentifier,
                                                       accountName: accountName,
                                                       contactKey: config.contactKey.key,
                                                       id: messageId,
                                                       buttonId: buttonId)
        
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success( _ ):
                self?.removeInAppMessageFromCache(messageId)
            case .failure(let error):
                Logger.log(message: "setInAppMessageAsClicked_ERROR", argument: error.localizedDescription)
            }
        }
    }
    
    private func setInAppMessageAsDismissed(_ inAppMessageId: String?) {
        guard isEnabledInAppMessage else {return}
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              let messageId = inAppMessageId else { return }
        let request = MarkAsInAppMessageAsDismissedRequest(type: config.contactKey.type,
                                                           deviceID: config.applicationIdentifier,
                                                           accountName: accountName,
                                                           contactKey: config.contactKey.key,
                                                           id: messageId)
        
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
    
    func setNavigation(screenName: String? = nil) {
        guard !(config.inAppMessageShowTime != 0 && Date().timeMiliseconds < config.inAppMessageShowTime) else {return}
        let messages = DengageLocalStorage.shared.getInAppMessages()
        guard !messages.isEmpty else {return}
        let inAppMessages = DengageInAppMessageUtils.findNotExpiredInAppMessages(untilDate: Date(), messages)
        guard let priorInAppMessage = DengageInAppMessageUtils.findPriorInAppMessage(inAppMessages: inAppMessages, screenName: screenName) else {return}
        showInAppMessage(inAppMessage: priorInAppMessage)
    }
    
    
    func handleInAppDeeplink(completion: @escaping (String) -> Void) {
        
        completion(self.deeplinkURL ?? "")

        
    }
    
    func showInAppMessage(inAppMessage: InAppMessage) {
        markAsInAppMessageAsDisplayed(inAppMessageId: inAppMessage.data.messageDetails)

        if let showEveryXMinutes = inAppMessage.data.displayTiming.showEveryXMinutes, showEveryXMinutes != 0 {
            var updatedMessage = inAppMessage
            updatedMessage.nextDisplayTime = Date().timeMiliseconds + Double(showEveryXMinutes) * 60000.0
            updateInAppMessageOnCache(updatedMessage)
        } else {
            removeInAppMessageFromCache(inAppMessage.data
                                            .messageDetails ?? "")
        }
        let inappShowTime = (Date().timeMiliseconds) + (config.remoteConfiguration?.minSecBetweenMessages ?? 0.0)
        DengageLocalStorage.shared.set(value: inappShowTime, for: .inAppMessageShowTime)
        
        let delay = 0 //inAppMessage.data.displayTiming.delay ?? 0

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
            self.showInAppMessageController(with: inAppMessage)
        }
    }
    
    private func showInAppMessageController(with message:InAppMessage){
        switch message.data.content.type {
        case .html:
            guard message.data.content.props.html != nil else {return}
            let controller = InAppMessageHTMLViewController(with: message)
            controller.delegate = self
            self.createInAppWindow(for: controller)
        default:
            break
        }
    }
    
    private func createInAppWindow(for controller: UIViewController){
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        inAppMessageWindow = UIWindow(frame: frame)
        inAppMessageWindow?.rootViewController = controller
        inAppMessageWindow?.windowLevel = UIWindow.Level(rawValue: 2)
        inAppMessageWindow?.makeKeyAndVisible()
    }
    
    private func updateInAppMessageOnCache(_ message: InAppMessage){
        let previousMessages = DengageLocalStorage.shared.getInAppMessages()
        var updatedMessages = previousMessages.filter{$0.data.messageDetails != message.data.messageDetails}
        updatedMessages.append(message)
        DengageLocalStorage.shared.save(updatedMessages)
    }
    
    private func addInAppMessagesIfNeeded(_ messages:[InAppMessage]){
        DispatchQueue.main.async {
        var previousMessages = DengageLocalStorage.shared.getInAppMessages()
        previousMessages.append(contentsOf: messages)
           DengageLocalStorage.shared.save(previousMessages)
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
              config.accountName != nil else {return false}
        guard config.inAppEnabled else {return false}
        return true
    }
    
    private var shouldFetchInAppMessages:Bool{
        guard isEnabledInAppMessage else {return false}
        guard let lastFetchedTime = config.inAppMessageLastFetchedTime else {return true}
        guard Date().timeMiliseconds >= lastFetchedTime else {return false}
        return true
    }
    
    private var expiredMessagesFetchIntervalInMin:Bool{
        guard isEnabledInAppMessage else {return false}
        guard let expiredMessagesFetchIntervalInMin = config.expiredMessagesFetchIntervalInMin else {return true}
        guard Date().timeMiliseconds >= expiredMessagesFetchIntervalInMin else {return false}
        return true
    }
    
    private func registerLifeCycleTrackers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func willEnterForeground(){
        fetchInAppMessages()
    }
}
//MARK: - InAppMessagesViewController Delegate
extension DengageInAppMessageManager: InAppMessagesActionsDelegate{
    func setTags(tags: [TagItem]) {
        Dengage.setTags(tags)
    }
    
    func open(url: String?) {
        
        inAppMessageWindow = nil
        
        guard let urlString = url, let url = URL(string: urlString) else { return }

        self.deeplinkURL = urlString
        self.handleInAppDeeplink { str in
            
            
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func sendDissmissEvent(messageId: String?) {
        inAppMessageWindow = nil
        setInAppMessageAsDismissed(messageId)
    }
    
    func sendClickEvent(messageId: String?, buttonId:String?) {
        inAppMessageWindow = nil

        setInAppMessageAsClicked(messageId, buttonId)
    }
    
    func promptPushPermission(){
        Dengage.promptForPushNotifications()
    }
    
    func close() {
        inAppMessageWindow = nil
    }
    
    
}


protocol DengageInAppMessageManagerInterface: AnyObject{
    func fetchInAppMessages()
    func fetchInAppExpiredMessages()
    func setNavigation(screenName: String?)
    func showInAppMessage(inAppMessage: InAppMessage)
    func handleInAppDeeplink(completion: @escaping (String) -> Void)
    

}

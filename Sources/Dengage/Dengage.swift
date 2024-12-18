import Foundation
import UIKit
import StoreKit

public class Dengage  {
    
    static var manager: DengageManager?
    
    static var dengage: DengageManager? {
        get{
            if self.manager == nil {
                Logger.log(message: "Dengage not started correctly", argument: "")
            }
            return self.manager
        }
        set{
            manager = newValue
        }
    }
    
    
    @objc public static func start(apiKey: String,
                                   application: UIApplication? = nil,
                                   launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                   dengageOptions options: DengageOptions = DengageOptions() , deviceId : String? = nil, contactKey : String? = nil , partnerDeviceId :String? = nil) {
        
    
        if let id = deviceId
        {
            if id != ""
            {
                DengageKeychain.set(id, forKey: "\(Bundle.main.bundleIdentifier ?? "DengageApplicationIdentifier")")
                dengage?.config.applicationIdentifier = id
            }
            
        }
        
        if let id = partnerDeviceId
        {
            if id != ""
            {
                DengageLocalStorage.shared.set(value: id, for: .PartnerDeviceId)
                dengage?.config.partnerDeviceId = id

            }

        }
        
        if let key = contactKey
        {
            
            if key != ""
            {
                DengageLocalStorage.shared.set(value: key, for: .contactKey)

            }

        }
        
        
        dengage = .init(with: apiKey, application: application,launchOptions:launchOptions,
                        dengageOptions: options)
        
        
    }
    
    
    @objc public static func initWithLaunchOptions(categories: Set<UNNotificationCategory>? = nil,application: UIApplication,withLaunchOptions: [UIApplication.LaunchOptionsKey: Any],badgeCountReset: Bool = false, deviceId : String? = nil , contactKey : String? = nil , partnerDeviceId :String? = nil,dengageOptions : DengageOptions = DengageOptions())
    {
        let key =  DengageLocalStorage.shared.value(for: .integrationKey) as? String

        self.start(apiKey: key ?? "", application: application, launchOptions: withLaunchOptions, dengageOptions: dengageOptions ,deviceId: deviceId,contactKey: contactKey,partnerDeviceId: partnerDeviceId)
        
        
        
    }
    
    @objc public static func setIntegrationKey(key: String) {
       
        DengageLocalStorage.shared.set(value: key, for: .integrationKey)
    }
    
    @objc public static func register(deviceToken: Data) {
         dengage?.register(deviceToken)
    }
    
    @objc public static func setContactKey(contactKey: String?) {
        self.set(contactKey: contactKey)
    }
    
    @objc public static func getContactKey(contactKey: String?) -> String{
        return self.getContactKey() ?? ""
    }
    
    @objc public static func set(contactKey: String?) {
        dengage?.set(contactKey)
    }
    
    @objc public static func set(deviceId: String) {
        dengage?.config.set(deviceId: deviceId)
        
    }
    
    @objc public static func syncSDK() {
       
        dengage?.sync()
        
    }
    
    @objc public static func set(permission: Bool){
        dengage?.set(permission)
        
    }
    
    @objc public static func setUserPermission(permission: Bool) {

        self.set(permission: permission)
    }
    
    @objc public static func getPermission() -> Bool {
        dengage?.config.permission ?? false
    }
    
    @objc public static func getDeviceId() -> String? {
        dengage?.config.applicationIdentifier
    }
    
    @objc public static func getContactKey() -> String? {
        dengage?.config.getContactKey()
    }
    
    @objc public static func getDeviceToken() -> String? {
        dengage?.config.deviceToken
    }
    
    @objc public static func getLastPushPayload() -> String? {
        
        let pushPayload = DengageLocalStorage.shared.value(for: .lastPushPayload) as? String
        DengageLocalStorage.shared.set(value: "", for: .lastPushPayload)
        return pushPayload
        
    }
    
    @objc public static func setToken(token: String) {
        dengage?.config.set(token: token)
    }
    
    
    @objc public static func setLogStatus(isVisible: Bool) {
        
        self.setLog(isVisible: isVisible)
    }
    
    @objc public static func setDeviceId(applicationIdentifier: String) {
        
        self.set(deviceId: applicationIdentifier)
    }
    
    @objc public static func setDevelopmentStatus(isDebug:Bool)
    {
        DengageLocalStorage.shared.set(value: isDebug, for: .appEnvironment)

    }
    
    @objc public static func isPushSilent(response: UNNotificationResponse? = nil ,userInfo: [AnyHashable: Any]? = nil ) -> Bool
    {
        if let userInfoData = userInfo
        {
            if let jsonData = try? JSONSerialization.data(withJSONObject: userInfoData, options: .prettyPrinted),
               let message = try? JSONDecoder().decode(PushContent.self, from: jsonData)  {
                
                if let messageSource = message.messageSource
                {
                    if MESSAGE_SOURCE == messageSource
                    {
                        return false

                    }
                    else
                    {
                        return true

                    }
                }
                else
                {
                    return false
                }
            }
        }
        else if let responseData = response
        {
            let content = responseData.notification.request.content
            
            if let messageSource = content.message?.messageSource
            {
                if MESSAGE_SOURCE == messageSource
                {
                    return false

                }
                else
                {
                    return true

                }
            }
            else
            {
                return false
            }
        }
    
        return false
       
    }
    
    //todo add objc
    public static func getInboxMessages(offset: Int,
                                        limit: Int = 20,
                                        completion: @escaping (Result<[DengageMessage], Error>) -> Void) {
        
        dengage?.inboxManager.getInboxMessages(offset: offset, limit: limit) { result in
            completion(result)
        }
    }
    
    public static func deleteInboxMessage(with id: String,
                                          completion: @escaping (Result<Void, Error>) -> Void){
        
        dengage?.inboxManager.deleteInboxMessage(with: id) { result in
            completion(result)
        }
    }
    
    public static func setInboxMessageAsClicked(with id: String,
                                                completion: @escaping (Result<Void, Error>) -> Void){
        
        dengage?.inboxManager.setInboxMessageAsClicked(with: id) { result in
            completion(result)
        }
    }
    
    @objc public static func setTags(_ tags: [TagItem]){
        dengage?.set(tags)
    }
    
    @objc public static func promptForPushNotifications(){
        dengage?.notificationManager.promptForPushNotifications()
    }
    
    @objc public static func callVisitorInfoAPI(){
        
        dengage?.inAppManager.getVisitorInfo()
        
    }
    
    @objc public static func promptForPushNotifications(completion: @escaping (_ isUserGranted: Bool) -> Void) {
        dengage?.notificationManager.promptForPushNotifications(callback: completion)
    }
    
    @objc public static func setNavigation(screenName:String? = nil ){
        dengage?.inAppManager.setNavigation(screenName:screenName)
    }
    
    @objc public static func showInAppInLine(propertyID : String? = nil , inAppInlineElement : InAppInlineElementView? = nil,screenName:String? = nil , customParams: Dictionary<String, String>? = nil , hideIfNotFound: Bool = false ){
        dengage?.inAppManager.setNavigation(screenName:screenName,params: customParams, propertyID: propertyID ,inAppInlineElement:inAppInlineElement , hideIfNotFound : hideIfNotFound)
    }
    
    @objc public static func removeInAppMessageDisplay(){
        dengage?.inAppManager.removeInAppMessageDisplay()
    }
    
    
    @objc public static func showRealTimeInApp(
        screenName: String? = nil,
        params: Dictionary<String, String>? = nil
    ) {
        dengage?.inAppManager.setNavigation(screenName:screenName, params: params)
    }
    
    @objc public static func setCategory(path: String?) {
        dengage?.config.setCategory(path: path)
    }
    
    @objc public static func setCart(itemCount: String?) {
        dengage?.config.setCart(itemCount: itemCount)
    }
    
    @objc public static func setCart(amount: String?) {
        dengage?.config.setCart(amount: amount)
    }
    
    @objc public static func setState(name: String?) {
        dengage?.config.setState(name: name)
    }

    @objc public static func setCity(name: String?) {
        dengage?.config.setCity(name: name)
    }
    
    @objc public static func setPartnerDeviceId(adid: String?) {
       
        dengage?.config.setPartnerDeviceId(adid: adid)
    }
    
    @objc public static func inAppLinkConfiguration(deeplink : String)
    {
        dengage?.config.setinAppLinkConfiguration(deeplink: deeplink)

    }
    
    @objc public static func handleNotificationActionBlock(callback: @escaping (_ notificationResponse: UNNotificationResponse) -> Void) {
        dengage?.notificationManager.openTriggerCompletionHandler = {
            response in
            callback(response)
        }
    }
    
    @objc static public func didReceiveNotificationRequest(_ bestAttemptContent: UNMutableNotificationContent?,
                                                           withContentHandler contentHandler:  @escaping (UNNotificationContent) -> Void) {
        
        if #available(iOS 15.0, *) {
            bestAttemptContent?.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
        DengageNotificationExtension.didReceiveNotificationRequest(bestAttemptContent, withContentHandler: contentHandler)
    }
    
    @objc static public func didReceivePush(_ center: UNUserNotificationCenter,
                                            _ response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping () -> Void) {
        dengage?.notificationManager.didReceivePush(center, response, withCompletionHandler: completionHandler)
    }
    
    @objc static public func didReceive(with userInfo: [AnyHashable: Any]) {
        dengage?.notificationManager.didReceive(with: userInfo)
    }
    
    @objc static public func pageView(parameters: [String: Any]){
        dengage?.eventManager.pageView(parameters: parameters)
    }
    
    @objc static public func addToCart(parameters: [String: Any]){
        dengage?.eventManager.addToCart(parameters: parameters)
    }
    
    @objc static public func removeFromCart(parameters: [String: Any]){
        dengage?.eventManager.removeFromCart(parameters: parameters)
    }
    
    @objc static public func viewCart(parameters: [String: Any]){
        dengage?.eventManager.viewCart(parameters: parameters)
    }
    
    @objc static public func beginCheckout(parameters: [String: Any]){
        dengage?.eventManager.beginCheckout(parameters: parameters)
    }
    
    @objc static public func order(parameters: [String: Any]){
        dengage?.eventManager.order(parameters: parameters)
    }
    
    @objc static public func cancelOrder(parameters: [String: Any]){
        dengage?.eventManager.cancelOrder(parameters: parameters)
    }
    
    @objc static public func search(parameters: [String: Any]){
        dengage?.eventManager.search(parameters: parameters)
    }
    
    @objc static public func addToWithList(parameters: [String: Any]){
        dengage?.eventManager.addToWithList(parameters: parameters)
    }
    
    @objc static public func removeFromWithList(parameters: [String: Any]){
        dengage?.eventManager.removeFromWithList(parameters: parameters)
    }
    
    @objc static public func sendCustomEvent(eventTable: String, parameters: [String: Any]){
        dengage?.eventManager.sendCustomEvent(eventTable: eventTable, parameters: parameters)
    }
    
    @objc static public func showTestPage(){
        dengage?.showTestPage()
    }
    
    @objc static public func setLog(isVisible: Bool){
        Logger.isEnabled = isVisible
    }
    
    @objc static public func setLanguage(language:String)
    {
        dengage?.config.setLanguage(language: language)
    }
    
   static func syncSubscription() {
        dengage?.makeSubscriptionRequestAPICall()
    }
    
    @objc public static func setHybridAppEnvironment() {
        
        DengageLocalStorage.shared.set(value: true, for: .hybridAppEnvironment)
        
    }
    
    
    
}

extension Dengage {
    public static func saveRFM(scores: [RFMScore]) {
        dengage?.dengageRFMManager.saveRFM(scores: scores)
    }
    
    public static func categoryView(id: String){
        dengage?.dengageRFMManager.categoryView(id: id)
    }
    
    public static func sortRFMItems(gender: RFMGender, items: [RFMItemProtocol]) -> [RFMItemProtocol] {
        dengage?.dengageRFMManager.sortRFMItems(gender: gender,
                                                items: items) ?? []
    }
}

extension Dengage {
    
    @objc public static func getInboxMessages(offset: Int,
                                              limit: Int = 20,
                                              success: @escaping (([DengageMessage]) -> Void),
                                              error: @escaping ((Error) -> Void)) {
        Dengage.getInboxMessages(offset: offset, limit: limit) { result in
            switch result {
            case .success(let messages):
                success(messages)
            case .failure(let errorValue):
                error(errorValue)
            }
        }
    }
    
    @objc public static func deleteInboxMessage(with id: String,
                                                success: @escaping (() -> Void),
                                                error: @escaping ((Error) -> Void)){
        Dengage.deleteInboxMessage(with: id) { result in
            switch result {
            case .success(_):
                success()
            case .failure(let errorValue):
                error(errorValue)
            }
        }
    }
    
    @objc public static func setInboxMessageAsClicked(with id: String,
                                                      success: @escaping (() -> Void),
                                                      error: @escaping ((Error) -> Void)){
        Dengage.setInboxMessageAsClicked(with: id) { result in
            switch result {
            case .success(_):
                success()
            case .failure(let errorValue):
                error(errorValue)
            }
        }
    }
    
    public static func showRatingView() {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
}

//MARK: - DengageDeviceIdApiUrl
extension Dengage{

    @objc public static func sendDeviceIdToServer(route:String , token : String) {
        DengageLocalStorage.shared.set(value: route, for: .deviceIdRoute)
        dengage?.dengageDeviceIdSendToServer(token: token)
    }
    
    @objc public static func handleInAppDeeplink(completion: @escaping (String) -> Void) {
        
        dengage?.inAppManager.returnAfterDeeplinkRecieved = { deeplink in
            
            completion(deeplink)
            
        }
        
        
     
    }
    
}



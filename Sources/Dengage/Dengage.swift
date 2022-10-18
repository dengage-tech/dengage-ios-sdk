import Foundation
import UIKit

public class Dengage{
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
                                   application: UIApplication,
                                   launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                   dengageOptions options: DengageOptions = DengageOptions()) {
        dengage = .init(with: apiKey,
                        application: application,
                        launchOptions:launchOptions,
                        dengageOptions: options)
    }
    
    
    @objc public static func initWithLaunchOptions(categories: Set<UNNotificationCategory>? = nil,application: UIApplication,withLaunchOptions: [UIApplication.LaunchOptionsKey: Any],badgeCountReset: Bool = false)
    {
        let key =  DengageLocalStorage.shared.value(for: .integrationKey) as? String

        self.start(apiKey: key ?? "", application: application, launchOptions: withLaunchOptions, dengageOptions: DengageOptions())
        
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
    
    @objc public static func setToken(token: String) {
        dengage?.config.set(token: token)
    }
    
    
    @objc public static func setLogStatus(isVisible: Bool) {
        
        self.setLog(isVisible: isVisible)
    }
    
    @objc public static func setDeviceId(applicationIdentifier: String) {
        
        self.set(deviceId: applicationIdentifier)
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
    
    @objc public static func promptForPushNotifications(completion: @escaping (_ isUserGranted: Bool) -> Void) {
        dengage?.notificationManager.promptForPushNotifications(callback: completion)
    }
    
    @objc public static func setNavigation(screenName:String? = nil ){
        dengage?.inAppManager.setNavigation(screenName:screenName)
    }
    
    @objc public static func handleInAppDeeplink(completion: @escaping (String) -> Void) {
        
        dengage?.inAppManager.handleInAppDeeplink(completion: { url in
            
            completion(url)
            
        })
    }
    
    @objc public static func handleNotificationActionBlock(callback: @escaping (_ notificationResponse: UNNotificationResponse) -> Void) {
        dengage?.notificationManager.openTriggerCompletionHandler = {
            response in
            callback(response)
        }
    }
    
    @objc static public func didReceiveNotificationRequest(_ bestAttemptContent: UNMutableNotificationContent?,
                                                           withContentHandler contentHandler:  @escaping (UNNotificationContent) -> Void) {
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
    
    static func syncSubscription() {
        dengage?.sync()
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
}

//MARK: - DengageDeviceIdApiUrl
extension Dengage{

    @objc public static func sendDeviceIdToServer(route:String , token : String) {
        DengageLocalStorage.shared.set(value: route, for: .deviceIdRoute)
        dengage?.dengageDeviceIdSendToServer(token: token)
    }
    
    
    
}

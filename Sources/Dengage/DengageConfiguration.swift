import Foundation
import AdSupport
import CoreTelephony
import UIKit
import AppTrackingTransparency

final public class DengageConfiguration: Encodable {
    
    let subscriptionURL: URL
    let eventURL: URL
    let deviceCountryCode: String
    var deviceLanguage: String
    let deviceTimeZone: String
    let appVersion: String
    public var applicationIdentifier: String
    let advertisingIdentifier: String
    let getCarrierIdentifier: String
    let sdkVersion: String
    public let integrationKey: String
    let options: DengageOptions
    public var deviceToken: String?
    let userAgent: String
    var permission: Bool
    let dengageDeviceIdApiUrl: URL
    var partnerDeviceId: String?
    
    var inboxLastFetchedDate: Date?
    var realTimeCategoryPath: String?
    var realTimeCartItemCount: String?
    var realTimeCartAmount: String?
    var city: String?
    var state: String?
    var pageViewCount = 0
    let inAppURL: URL
    let geofenceURL: URL
    let inAppRealTimeURL: URL
    var locationPermission: String?
    
    
    init(integrationKey: String, options: DengageOptions) {
        subscriptionURL = DengageConfiguration.getSubscriptionUrl()
        eventURL = DengageConfiguration.getEventUrl()
        deviceCountryCode = DengageConfiguration.getDeviceCountry()
        deviceLanguage = Locale.current.languageCode ?? "Null"
        deviceTimeZone = TimeZone.current.identifier
        appVersion = DengageConfiguration.getAppVersion()
        applicationIdentifier = DengageConfiguration.getApplicationId()
        advertisingIdentifier = DengageConfiguration.getAdvertisingId()
        getCarrierIdentifier = DengageConfiguration.getCarrierId()
        sdkVersion = SDK_VERSION
        self.integrationKey = integrationKey
        self.options = options
        self.userAgent = UserAgentUtils.userAgent
        self.permission = DengageConfiguration.getPermission()
        self.deviceToken = DengageConfiguration.getToken()
        inAppURL = DengageConfiguration.getInAppURL()
        geofenceURL = DengageConfiguration.getGeofenceUrl()
        inAppRealTimeURL = DengageConfiguration.getInAppRealTimeURL()
        
        dengageDeviceIdApiUrl = DengageConfiguration.dengageDeviceIdApiUrl()
        
    }
    
    public var contactKey: (key: String, type:String) {
        let key = getContactKey() ?? applicationIdentifier
        let type = getContactKey() != nil ? "c" : "d"
        return (key, type)
    }
    
    var shouldFetchFromAPI: Bool {
        guard let date = inboxLastFetchedDate else { return true}
        if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute,
           diff > INBOX_FETCH_INTERVAL {
            return true
        }
        return false
    }
    
    var remoteConfiguration: GetSDKParamsResponse? {
        return DengageLocalStorage.shared.getConfig()
    }
    
    var realTimeInAppMessageLastFetchedTime:Double? {
        return (DengageLocalStorage.shared.value(for: .lastFetchedRealTimeInAppMessageTime) as? Double)
    }
    
    
    var inAppMessageLastFetchedTime:Double? {
        return (DengageLocalStorage.shared.value(for: .lastFetchedInAppMessageTime) as? Double)
    }
    
    var lastSuccessfulInAppMessageFetchTime: Double? {
        return (DengageLocalStorage.shared.value(for: .lastSuccessfulInAppMessageFetchTime) as? Double)
    }
    
    var lastSuccessfulRealTimeInAppMessageFetchTime: Double? {
        return (DengageLocalStorage.shared.value(for: .lastSuccessfulRealTimeInAppMessageFetchTime) as? Double)
    }
    
    var expiredMessagesFetchIntervalInMin:Double? {
        return (DengageLocalStorage.shared.value(for: .expiredMessagesFetchIntervalInMin) as? Double)
    }
    
    
    var inAppMessageShowTime: Double{
        return (DengageLocalStorage.shared.value(for: .inAppMessageShowTime) as? Double) ?? 0
    }
    
    func set(token:String){
        DengageLocalStorage.shared.set(value: token, for: .token)
        deviceToken = token
    }
    
    func getLanguage() -> String {
        
        if let lang = DengageLocalStorage.shared.value(for: .language) as? String
        {
            self.deviceLanguage = lang
        }
        else
        {
            deviceLanguage = Locale.current.languageCode ?? "Null"
        }
        
        return self.deviceLanguage
    }
    
    func setLanguage(language:String) {
        let languageSubscription = DengageLocalStorage.shared.value(for: .languageSubscription) as? String
        self.deviceLanguage = language
        DengageLocalStorage.shared.set(value: language, for: .language)

        if (languageSubscription != nil) && (self.deviceLanguage != languageSubscription)
        {
            Dengage.syncSubscription()

        }
        
    }
    
    func getLocationPermission() -> String? {
        locationPermission = DengageLocalStorage.shared.value(for: .locationPermission) as? String
        return locationPermission
    }
    
    func setLocationPermission(locationPermission: String) {
        DengageLocalStorage.shared.set(value: locationPermission, for: .locationPermission)
        self.locationPermission = locationPermission
        /*
        let previous = self.config.getContactKey()
        if previous != contactKey {
            let newKey = (contactKey?.isEmpty ?? true) ? nil : contactKey
            DengageLocalStorage.shared.set(value: newKey, for: .contactKey)
            inboxManager.inboxMessages.removeAll()
            inboxManager.inboxMessages = []
            _ = sessionManager.createSession(force: true)
            resetUsageStats()
            Dengage.syncSubscription()
        }
         */
    }
    
    
    
    func setPartnerDeviceId(adid: String?){
        
        if let partnerId = DengageLocalStorage.shared.value(for: .PartnerDeviceId) as? String
        {
            if partnerId != adid
            {
                DengageLocalStorage.shared.set(value: adid, for: .PartnerDeviceId)
                partnerDeviceId = adid
                Dengage.syncSubscription()
                
            }
        }
        else
        {
            DengageLocalStorage.shared.set(value: adid, for: .PartnerDeviceId)
            partnerDeviceId = adid
            Dengage.syncSubscription()
            
        }
        
        
    }
    
    func setinAppLinkConfiguration( deeplink : String){
        
        
        DengageLocalStorage.shared.set(value: deeplink, for: .deeplink)
        
    }
    
    func getOpenInAppBrowser()-> Bool
    {
        return DengageLocalStorage.shared.value(for: .openInAppBrowser) as? Bool ?? false
        
    }
    
    func getHybridAppEnvironment()-> Bool
    {
        return DengageLocalStorage.shared.value(for: .hybridAppEnvironment) as? Bool ?? false
        
    }
    
    func getRetrieveLinkOnSameScreen()-> Bool
    {
        return DengageLocalStorage.shared.value(for: .retrieveLinkOnSameScreen) as? Bool ?? false
        
    }
    
    func getDeeplink()-> String
    {
        return DengageLocalStorage.shared.value(for: .deeplink) as? String ?? ""
        
    }
    
    func set(deviceId: String){
        
        DengageKeychain.set(deviceId, forKey: "\(Bundle.main.bundleIdentifier ?? "DengageApplicationIdentifier")")
        let previous = self.applicationIdentifier
        
        if previous != deviceId {
            
            applicationIdentifier = deviceId
            Dengage.syncSubscription()
            
        }
        
        
    }
    
    func set(permission: Bool) {
        self.permission = permission
        DengageLocalStorage.shared.set(value: permission, for: .userPermission)
    }
    
    func setCategory(path: String?) {
        realTimeCategoryPath = path
    }
    
    func setCart(cart: Cart) {
        DengageLocalStorage.shared.saveClientCart(cart)
    }
    
    func getCart() -> Cart {
        return DengageLocalStorage.shared.getClientCart() ?? Cart(items: [])
    }
    
    func setCart(itemCount: String?) {
        realTimeCartItemCount = itemCount
    }
    
    func setCart(amount: String?) {
        realTimeCartAmount = amount
    }
    
    func setState(name: String?) {
        state = name
    }
    
    func setCity(name: String?) {
        city = name
    }
    
    func incrementPageViewCount(){
        pageViewCount += 1
    }
    
    func resetPageViewCount(){
        pageViewCount = 0
    }
    
    func setClientPageInfo(eventDetails: [String: Any]) {
        let currentPageInfo = getClientPageInfo()
        
        var updatedPageInfo = ClientPageInfo(
            lastProductId: currentPageInfo.lastProductId,
            lastProductPrice: currentPageInfo.lastProductPrice,
            lastCategoryPath: currentPageInfo.lastCategoryPath,
            currentPageTitle: eventDetails["page_title"] as? String ?? currentPageInfo.currentPageTitle,
            currentPageType: eventDetails["page_type"] as? String ?? currentPageInfo.currentPageType
        )
        
        // If page_type is "product", update last product information
        if eventDetails["page_type"] as? String == "product" {
            updatedPageInfo = ClientPageInfo(
                lastProductId: eventDetails["product_id"] as? String ?? currentPageInfo.lastProductId,
                lastProductPrice: eventDetails["price"] as? String ?? currentPageInfo.lastProductPrice,
                lastCategoryPath: eventDetails["category_path"] as? String ?? currentPageInfo.lastCategoryPath,
                currentPageTitle: updatedPageInfo.currentPageTitle,
                currentPageType: updatedPageInfo.currentPageType
            )
        }
        
        DengageLocalStorage.shared.saveClientPageInfo(updatedPageInfo)
    }
    
    func getClientPageInfo() -> ClientPageInfo {
        return DengageLocalStorage.shared.getClientPageInfo() ?? ClientPageInfo()
    }
    
    func getLastProductId() -> String? {
        return getClientPageInfo().lastProductId
    }
    
    func getLastProductPrice() -> String? {
        return getClientPageInfo().lastProductPrice
    }
    
    func getLastCategoryPath() -> String? {
        return getClientPageInfo().lastCategoryPath
    }
    
    func getCurrentPageTitle() -> String? {
        return getClientPageInfo().currentPageTitle
    }
    
    func getCurrentPageType() -> String? {
        return getClientPageInfo().currentPageType
    }
    
    func getContactKey() -> String? {
        DengageLocalStorage.shared.value(for: .contactKey) as? String
    }
    
    func getPartnerDeviceID()-> String? {
        return DengageLocalStorage.shared.value(for: .PartnerDeviceId) as? String
        
    }
    
    private static func getToken() -> String? {
        return DengageLocalStorage.shared.value(for: .token) as? String
    }
    
    static func getPermission() -> Bool{
        return DengageLocalStorage.shared.value(for: .userPermission) as? Bool ?? true
    }
    
    private static func getSubscriptionUrl() -> URL {
        if let apiUrlString = DengageLocalStorage.shared.getApiUrlConfiguration()?.denPushApiUrl,
           !apiUrlString.isEmpty {
            guard let apiUrl = URL(string: apiUrlString) else {
                fatalError("[DENGAGE] 'DengageApiUrl' not correct in ApiUrlConfiguration")
            }
            return apiUrl
        }
        
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "DengageApiUrl") as? String else {
            fatalError("[DENGAGE] 'DengageApiUrl' not found in plist file")
        }
        
        guard let apiUrl = URL(string: apiUrlString) else {
            fatalError("[DENGAGE] 'DengageApiUrl' not correct in plist file")
        }
        
        return apiUrl
    }
    
    private static func getGeofenceUrl() -> URL {
        if let apiUrlString = DengageLocalStorage.shared.getApiUrlConfiguration()?.denGeofenceApiUrl,
           !apiUrlString.isEmpty {
            guard let apiUrl = URL(string: apiUrlString) else {
                return getSubscriptionUrl()
            }
            return apiUrl
        }
        
        
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "DengageGeofenceApiUrl") as? String else {
            return getSubscriptionUrl()
        }
        
        guard let apiUrl = URL(string: apiUrlString) else {
            
            return getSubscriptionUrl()
        }
        
        return apiUrl
    }
    
    
    private static func getEventUrl() -> URL {
        if let apiUrlString = DengageLocalStorage.shared.getApiUrlConfiguration()?.denEventApiUrl,
           !apiUrlString.isEmpty {
            guard let apiUrl = URL(string: apiUrlString) else {
                fatalError("[DENGAGE] 'DengageEventApiUrl' not correct in ApiUrlConfiguration")
            }
            return apiUrl
        }
        
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "DengageEventApiUrl") as? String else {
            fatalError("[DENGAGE] 'DengageEventApiUrl' not found in plist file")
        }
        
        guard let apiUrl = URL(string: apiUrlString) else {
            fatalError("[DENGAGE] 'DengageEventApiUrl' not correct in plist file")
        }
        
        return apiUrl
    }
    
    private static func getInAppURL() -> URL {
        if let apiUrlString = DengageLocalStorage.shared.getApiUrlConfiguration()?.denInAppApiUrl,
           !apiUrlString.isEmpty {
            guard let apiUrl = URL(string: apiUrlString) else {
                fatalError("[DENGAGE] 'DengageInAppApiUrl' not correct in ApiUrlConfiguration")
            }
            return apiUrl
        }
        
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "DengageInAppApiUrl") as? String else {
            return getSubscriptionUrl()
        }
        
        guard let apiUrl = URL(string: apiUrlString) else {
            return getSubscriptionUrl()
        }
        
        return apiUrl
    }
    
    
    private static func getInAppRealTimeURL() -> URL {
        if let apiUrlString = DengageLocalStorage.shared.getApiUrlConfiguration()?.fetchRealTimeInAppApiUrl,
           !apiUrlString.isEmpty {
            guard let apiUrl = URL(string: apiUrlString) else {
                fatalError("[DENGAGE] 'fetchRealTimeInAppApiUrl' not correct in ApiUrlConfiguration")
            }
            return apiUrl
        }
        
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "fetchRealTimeINAPPURL") as? String else {
            return URL(string: "https://tr-inapp.lib.dengage.com") ?? getSubscriptionUrl()
        }
        
        guard let apiUrl = URL(string: apiUrlString) else {
            return URL(string: "https://tr-inapp.lib.dengage.com") ?? getSubscriptionUrl()
        }
        
        return apiUrl
    }
    
    
    
    private static func getDeviceCountry() -> String {
        guard let regionCode = Locale.current.regionCode else { return "Null" }
        let countryId = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: regionCode])
        guard let countryName = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier,
                                                                                value: countryId) else { return "Null" }
        return countryName
    }
    
    private static func dengageDeviceIdApiUrl() -> URL {
        
        guard let apiURLString = Bundle.main.object(forInfoDictionaryKey: "DengageDeviceIdApiUrl") as? String else {
            return getSubscriptionUrl()
        }
        
        guard let apiURL = URL(string: apiURLString) else {
            return getSubscriptionUrl()
        }
        
        return apiURL
        
    }
    
    private static func getAppVersion() -> String {
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "Null"
        return versionString
    }
    
    static func getApplicationId() -> String {
        
        if let uuidString = DengageKeychain.string(forKey: "DengageApplicationIdentifier"), !uuidString.isEmpty {
            
            DengageKeychain.remove("DengageApplicationIdentifier")
            DengageKeychain.set(uuidString, forKey: "\(Bundle.main.bundleIdentifier ?? "DengageApplicationIdentifier")")
            
        }
        
        if let uuidString = DengageKeychain.string(forKey: "\(Bundle.main.bundleIdentifier ?? "DengageApplicationIdentifier")"), !uuidString.isEmpty {
            return uuidString
        } else {
            let uuidString = NSUUID().uuidString.lowercased()
            DengageKeychain.set(uuidString, forKey: "\(Bundle.main.bundleIdentifier ?? "DengageApplicationIdentifier")")
            return uuidString
        }
    }
    
    static func getAdvertisingId() -> String{
        
        var advertisingId = ""
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    
                    // Now that we are authorized we can get the IDFA
                    advertisingId =  ASIdentifierManager.shared().advertisingIdentifier.uuidString.lowercased()
                    
                    
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        } else {
            // Fallback on earlier versions
            
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled,
                  ASIdentifierManager.shared().advertisingIdentifier.isNotEmpty else {
                return ""
            }
            
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString.lowercased()
            
        }
        
        
        return advertisingId
        
        
        
        
    }
    
    static func getCarrierId() -> String { // *.*
        var carrierId = DEFAULT_CARRIER_ID
        let networkStatus = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let info = networkStatus.serviceSubscriberCellularProviders,
               let carrier = info["serviceSubscriberCellularProvider"] {
                carrierId = carrier.mobileCountryCode ?? carrierId
                carrierId += carrier.mobileNetworkCode ?? carrierId
            }
            return carrierId
        } else {
            let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
            carrierId = carrier?.mobileCountryCode ?? carrierId
            carrierId += carrier?.mobileNetworkCode ?? carrierId
            return carrierId
        }
    }
}


extension DengageConfiguration: CustomStringConvertible{
    public var description: String{
        var desc = "Dengage Configrations\n"
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                desc.append("\(label): \(child.value)\n")
            }
        }
        return desc
    }
}

private extension UUID{
    var isNotEmpty: Bool{
        let emptyUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        return self.uuidString.elementsEqual(emptyUUID.uuidString)
    }
}

final class UserAgentUtils { // todo dusun
    
    //eg. Darwin/16.3.0
    class var darwinVersion: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let bytes = Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN))
        guard let darwinString = String(bytes: bytes, encoding: .ascii) else { return "Null"}
        return "Darwin/\(darwinString.trimmingCharacters(in: .controlCharacters))"
    }
    
    //eg. CFNetwork/808.3
    class var CFNetworkVersion: String {
        guard let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary else { return "Null" }
        let version = dictionary["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    //eg. iOS/10_1
    class var deviceVersion: String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    
    //eg. iPhone 13 Pro
    class var deviceName: String {
        return UIDevice.modelName
    }
    
    //eg. MyApp/1
    class var appNameAndVersion:String {
        guard let dictionary = Bundle.main.infoDictionary else {return "Null"}
        let version = dictionary["CFBundleShortVersionString"] as? String ?? "1.0"
        let name = dictionary["CFBundleName"] as! String
        return "\(name)/\(version)"
    }
    
    class var userAgent: String {
        return "\(appNameAndVersion) \(deviceName) \(deviceVersion) \(CFNetworkVersion) \(darwinVersion)"
    }
}

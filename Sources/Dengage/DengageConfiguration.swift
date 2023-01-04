import Foundation
import AdSupport
import CoreTelephony
import UIKit

final class DengageConfiguration:Encodable {
    
    let subscriptionURL: URL
    let eventURL: URL
    let deviceCountryCode: String
    let deviceLanguage: String
    let deviceTimeZone: String
    let appVersion: String
    var applicationIdentifier: String
    let advertisingIdentifier: String
    let getCarrierIdentifier: String
    let sdkVersion: String
    let integrationKey: String
    let options: DengageOptions
    var deviceToken: String?
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

    
    init(integrationKey: String, options: DengageOptions) {
        subscriptionURL = DengageConfiguration.getSubscriptionURL()
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

        dengageDeviceIdApiUrl = DengageConfiguration.dengageDeviceIdApiUrl()

    }
    
    var contactKey: (key: String, type:String) {
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
    
    func set(deviceId: String){
        DengageLocalStorage.shared.set(value: deviceId, for: .applicationIdentifier)
        DengageKeychain.set(deviceId, forKey: .applicationIdentifier)
        applicationIdentifier = deviceId
    }
    
    func set(permission: Bool){
        self.permission = permission
        DengageLocalStorage.shared.set(value: permission, for: .userPermission)
    }
    
    func setPartnerDeviceId(adid: String?){
        DengageLocalStorage.shared.set(value: adid, for: .PartnerDeviceId)
        partnerDeviceId = adid
    }
    
    func setinAppLinkConfiguration(openInAppBrowser : Bool,  retrieveLinkOnSameScreen : Bool , deeplink : String){

        DengageLocalStorage.shared.set(value: openInAppBrowser, for: .openInAppBrowser)
        DengageLocalStorage.shared.set(value: retrieveLinkOnSameScreen, for: .retrieveLinkOnSameScreen)
        DengageLocalStorage.shared.set(value: deeplink, for: .deeplink)

    }
    
    func getOpenInAppBrowser()-> Bool
    {
        return DengageLocalStorage.shared.value(for: .openInAppBrowser) as? Bool ?? false

    }
    
    func getRetrieveLinkOnSameScreen()-> Bool
    {
        return DengageLocalStorage.shared.value(for: .retrieveLinkOnSameScreen) as? Bool ?? false

    }
    
    func getDeeplink()-> String
    {
        return DengageLocalStorage.shared.value(for: .deeplink) as? String ?? ""

    }
    
    func getPartnerDeviceID()-> String?
    {
        return DengageLocalStorage.shared.value(for: .PartnerDeviceId) as? String

    }
    
    func setCategory(path: String?) {
        realTimeCategoryPath = path
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
    
    func getContactKey() -> String? {
        DengageLocalStorage.shared.value(for: .contactKey) as? String
    }
    
    private static func getToken() -> String? {
        return DengageLocalStorage.shared.value(for: .token) as? String
    }
    
    static func getPermission() -> Bool{
        return DengageLocalStorage.shared.value(for: .userPermission) as? Bool ?? true
    }
    
    private static func getSubscriptionURL() -> URL {
        guard let apiURLString = Bundle.main.object(forInfoDictionaryKey: "DengageApiUrl") as? String else {
            fatalError("[DENGAGE] 'DengageApiUrl' not found on plist file")
        }

        guard let apiURL = URL(string: apiURLString) else {
            fatalError("[DENGAGE] 'DengageApiUrl' not correct on plist file")
        }
        
        return apiURL
    }
    
    private static func getEventUrl() -> URL {
        guard let apiURLString = Bundle.main.object(forInfoDictionaryKey: "DengageEventApiUrl") as? String else {
            fatalError("[DENGAGE] 'DengageEventApiUrl' not found on plist file")
        }
        
        guard let apiURL = URL(string: apiURLString) else {
            fatalError("[DENGAGE] 'DengageEventApiUrl' not correct on plist file")
        }
 
        return apiURL
    }
    
    private static func getInAppURL() -> URL {
            guard let apiURLString = Bundle.main.object(forInfoDictionaryKey: "DengageInAppApiUrl") as? String else {
                return getSubscriptionURL()
            }

            guard let apiURL = URL(string: apiURLString) else {
                return getSubscriptionURL()
            }

            return apiURL
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
            return getSubscriptionURL()
        }

        guard let apiURL = URL(string: apiURLString) else {
            return getSubscriptionURL()
        }

        return apiURL
     
    }
    
    private static func getAppVersion() -> String {
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "Null"
        return versionString
    }
    
    static func getApplicationId() -> String {
        if let uuidString = DengageLocalStorage.shared.value(for: .applicationIdentifier) as? String, !uuidString.isEmpty {
            DengageKeychain.set(uuidString, forKey: .applicationIdentifier)
            return uuidString
        } else if let uuidString = DengageKeychain.string(forKey: .applicationIdentifier), !uuidString.isEmpty {
            DengageLocalStorage.shared.set(value: uuidString, for: .applicationIdentifier)
            return uuidString
        } else {
            let uuidString = NSUUID().uuidString.lowercased()
            DengageLocalStorage.shared.set(value: uuidString, for: .applicationIdentifier)
            DengageKeychain.set(uuidString, forKey: .applicationIdentifier)
            return uuidString
        }
    }
    
    static func getAdvertisingId() -> String{
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled,
              ASIdentifierManager.shared().advertisingIdentifier.isNotEmpty else {
            return ""
        }
        
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString.lowercased()
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

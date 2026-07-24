import Foundation

/// Silent push → Geofence Engine köprüsü için ObjC-runtime protokolü.
/// `Dengage` (core) hedefi `DengageGeofence` hedefine compile-time bağımlı olamadığı için
/// (bağımlılık ters yönde), engine bu protokole uyar ve core onu `NSClassFromString` ile bulur.
@objc public protocol DengageGeofenceSilentPushBridging {
    @objc static func dengage_handleSilentPush(_ userInfo: [AnyHashable: Any])
}

/// `sourceType == geofence` olan silent push'u Geofence Engine'e iletir.
/// Engine classpath/runtime'da yoksa (geofence kullanmayan entegrasyonlar) sessizce no-op olur.
public enum GeofenceSilentPushDispatcher {

    private static let sourceTypeKey = "sourceType"
    private static let dataKey = "data"
    private static let sourceTypeGeofence = "geofence"
    private static let engineClassName = "DengageGeofenceEngine"

    public static func isGeofenceSilentPush(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let sourceType = sourceType(from: userInfo) else { return false }
        return sourceType.caseInsensitiveCompare(sourceTypeGeofence) == .orderedSame
    }

    /// `sourceType`'ı iç içe `data` bloğundan (iOS payload) veya top-level'dan (fallback) okur.
    private static func sourceType(from userInfo: [AnyHashable: Any]) -> String? {
        // iOS silent push: { "aps": {...}, "data": { "sourceType": "geofence" } }
        if let data = userInfo[dataKey] as? [AnyHashable: Any],
           let nested = data[sourceTypeKey] as? String {
            return nested
        }
        // data bir JSON string olarak gelirse
        if let dataString = userInfo[dataKey] as? String,
           let dataObj = try? JSONSerialization.jsonObject(with: Data(dataString.utf8)) as? [String: Any],
           let nested = dataObj[sourceTypeKey] as? String {
            return nested
        }
        // top-level fallback
        return userInfo[sourceTypeKey] as? String
    }

    @discardableResult
    public static func dispatch(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard isGeofenceSilentPush(userInfo) else { return false }
        guard let engineType = NSClassFromString(engineClassName) as? DengageGeofenceSilentPushBridging.Type else {
            Logger.log(message: "GeofenceSilentPushDispatcher -> geofence engine not available, ignoring")
            return false
        }
        engineType.dengage_handleSilentPush(userInfo)
        Logger.log(message: "GeofenceSilentPushDispatcher -> dispatched geofence silent push")
        return true
    }
}

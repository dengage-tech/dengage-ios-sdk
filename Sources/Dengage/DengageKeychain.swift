import Security
import Foundation

final class DengageKeychain {

    private static var lastResultCode: OSStatus = noErr
    private static let coreFoundationBooleanTrue: CFBoolean = kCFBooleanTrue
    private static let lock = NSLock()
    private static let accessLevel = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    
    @discardableResult
    static func set(_ value: String, forKey key: String) -> Bool {
        defer {
            lock.unlock()
        }
        guard let value = value.data(using: String.Encoding.utf8) else {
            return false
        }
        lock.lock()
        remove(key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: accessLevel
        ]
        lastResultCode = SecItemAdd(query as CFDictionary, nil)
        return lastResultCode == noErr
    }

    @discardableResult
    static func remove(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        lastResultCode = SecItemDelete(query as CFDictionary)
        return lastResultCode == noErr
    }
    
    static func string(forKey key: String) -> String? {
        defer {
            lock.unlock()
        }
        lock.lock()
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: coreFoundationBooleanTrue
        ]
        lastResultCode = withUnsafeMutablePointer(to: &result) {
          SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard lastResultCode == noErr else { return nil } // data bos geliyor
        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else { return nil }
        
        return value
    }

    /// Reads a legacy device id, returning it **only** when the matching keychain item has an
    /// empty `kSecAttrService`.
    ///
    /// Legacy items were written without a service, so a service-less match is one this SDK
    /// itself created. Items carrying a non-empty service under the same account belong to
    /// other SDKs and must be ignored — otherwise migration could copy a foreign value and
    /// the device id would change. Used only for the one-time migration into
    /// `DengageDeviceIdKeychainStore`.
    static func legacyDeviceId(forKey key: String) -> String? {
        defer {
            lock.unlock()
        }
        lock.lock()
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: coreFoundationBooleanTrue,
            kSecReturnData as String: coreFoundationBooleanTrue
        ]
        lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard lastResultCode == noErr, let items = result as? [[String: Any]] else { return nil }

        for item in items {
            let service = item[kSecAttrService as String] as? String ?? ""
            guard service.isEmpty else { continue } // belongs to another SDK
            if let data = item[kSecValueData as String] as? Data,
               let value = String(data: data, encoding: .utf8), !value.isEmpty {
                return value
            }
        }
        return nil
    }
}

/// Keychain store dedicated to the Dengage device id.
///
/// The legacy `DengageKeychain` writes its items with **no** `kSecAttrService`. For
/// `kSecClassGenericPassword` the primary key is the (`kSecAttrAccount` + `kSecAttrService`)
/// pair, so an item identified only by account lives in the most generic, collision-prone
/// slot of the keychain: another SDK that also writes a service-less generic password with
/// the same account can shadow, overwrite or delete it, which makes the device id change.
///
/// This store gives Dengage its own `kSecAttrService` namespace so the device id can no
/// longer collide with items written by other SDKs.
final class DengageDeviceIdKeychainStore {

    /// Namespace that isolates Dengage's device id from every other keychain item.
    static let service = "com.dengage.sdk.deviceId"
    static let account = "dn.deviceid.identifier"

    private static let accessLevel = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    private static let lock = NSLock()

    /// Stores `value` for `key`, replacing any existing item in this namespace.
    /// - Returns: the `OSStatus` of the underlying `SecItemAdd` (`noErr` on success).
    @discardableResult
    static func set(_ value: String) -> OSStatus {
        lock.lock()
        defer { lock.unlock() }

        guard let data = value.data(using: .utf8) else { return errSecParam }

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let deleteResult = SecItemDelete(deleteQuery as CFDictionary)
        
        if deleteResult != errSecItemNotFound && deleteResult != errSecSuccess {
            return deleteResult
        }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessLevel
        ]
        return SecItemAdd(addQuery as CFDictionary, nil)
    }

    static func string() -> String? {
        lock.lock()
        defer { lock.unlock() }

        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue as Any
        ]
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard status == noErr,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    @discardableResult
    static func remove() -> OSStatus {
        lock.lock()
        defer { lock.unlock() }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        return SecItemDelete(query as CFDictionary)
    }
}

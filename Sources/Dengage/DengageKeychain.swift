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
}


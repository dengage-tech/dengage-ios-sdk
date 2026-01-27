import Foundation

/// Handler for storage operations from WebView
/// Provides key-value storage using UserDefaults
final class StorageHandler: SyncBridgeHandler, AsyncBridgeHandler {

    private static let bridgePrefsName = "dengage_bridge_storage"

    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: StorageHandler.bridgePrefsName) ?? UserDefaults.standard
    }

    struct SetStoragePayload: Decodable {
        let key: String
        let value: String?
    }

    struct GetStoragePayload: Decodable {
        let key: String
    }

    struct RemoveStoragePayload: Decodable {
        let key: String
    }

    func supportedActions() -> [String] {
        return [
            "storage_get",
            "storage_set",
            "storage_remove",
            "storage_clear",
            "storage_getAll"
        ]
    }

    // Sync implementation for read operations
    func handleSync(message: BridgeMessage) -> BridgeResponse {
        do {
            switch message.action {
            case "storage_get":
                guard let payloadData = message.payload?.data(using: .utf8),
                      let payload = try? JSONDecoder().decode(GetStoragePayload.self, from: payloadData) else {
                    return BridgeResponse.error(
                        callId: message.callId,
                        errorCode: BridgeErrorCodes.invalidPayload,
                        errorMessage: "Invalid payload"
                    )
                }
                let value = userDefaults.string(forKey: payload.key)
                return BridgeResponse.success(callId: message.callId, data: value)

            case "storage_getAll":
                let allValues = userDefaults.dictionaryRepresentation()
                    .compactMapValues { $0 as? String }
                return BridgeResponse.success(callId: message.callId, data: allValues)

            default:
                return BridgeResponse.error(
                    callId: message.callId,
                    errorCode: BridgeErrorCodes.unknownAction,
                    errorMessage: "Use async for this action"
                )
            }
        } catch {
            Logger.log(message: "StorageHandler sync error: \(error)")
            return BridgeResponse.error(
                callId: message.callId,
                errorCode: BridgeErrorCodes.storageError,
                errorMessage: error.localizedDescription
            )
        }
    }

    // Async implementation for write operations
    func handle(message: BridgeMessage, callback: BridgeCallback) {
        switch message.action {
        case "storage_set":
            guard let payloadData = message.payload?.data(using: .utf8),
                  let payload = try? JSONDecoder().decode(SetStoragePayload.self, from: payloadData) else {
                callback.onError(errorCode: BridgeErrorCodes.invalidPayload, errorMessage: "Invalid payload")
                return
            }
            userDefaults.set(payload.value, forKey: payload.key)
            callback.onSuccess(data: true)

        case "storage_remove":
            guard let payloadData = message.payload?.data(using: .utf8),
                  let payload = try? JSONDecoder().decode(RemoveStoragePayload.self, from: payloadData) else {
                callback.onError(errorCode: BridgeErrorCodes.invalidPayload, errorMessage: "Invalid payload")
                return
            }
            userDefaults.removeObject(forKey: payload.key)
            callback.onSuccess(data: true)

        case "storage_clear":
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                userDefaults.removePersistentDomain(forName: bundleIdentifier)
            }
            callback.onSuccess(data: true)

        case "storage_get":
            guard let payloadData = message.payload?.data(using: .utf8),
                  let payload = try? JSONDecoder().decode(GetStoragePayload.self, from: payloadData) else {
                callback.onError(errorCode: BridgeErrorCodes.invalidPayload, errorMessage: "Invalid payload")
                return
            }
            callback.onSuccess(data: userDefaults.string(forKey: payload.key))

        case "storage_getAll":
            let allValues = userDefaults.dictionaryRepresentation()
                .compactMapValues { $0 as? String }
            callback.onSuccess(data: allValues)

        default:
            callback.onError(errorCode: BridgeErrorCodes.unknownAction, errorMessage: "Unknown storage action")
        }
    }
}

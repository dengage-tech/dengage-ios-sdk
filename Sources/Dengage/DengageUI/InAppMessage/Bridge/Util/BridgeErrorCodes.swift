import Foundation

/// Error codes for bridge operations
struct BridgeErrorCodes {
    // Handler errors
    static let handlerNotFound = "HANDLER_NOT_FOUND"
    static let invalidPayload = "INVALID_PAYLOAD"
    static let unknownAction = "UNKNOWN_ACTION"

    // Network errors
    static let httpError = "HTTP_ERROR"
    static let networkUnavailable = "NETWORK_UNAVAILABLE"
    static let timeout = "TIMEOUT"

    // Storage errors
    static let storageError = "STORAGE_ERROR"
    static let keyNotFound = "KEY_NOT_FOUND"

    // Permission errors
    static let permissionDenied = "PERMISSION_DENIED"
    static let permissionNotGranted = "PERMISSION_NOT_GRANTED"

    // General errors
    static let internalError = "INTERNAL_ERROR"
    static let contextNull = "CONTEXT_NULL"
}

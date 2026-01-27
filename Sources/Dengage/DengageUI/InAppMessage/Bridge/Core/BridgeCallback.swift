import Foundation

/// Callback protocol for async bridge operations
protocol BridgeCallback {
    func onSuccess(data: Any?)
    func onError(errorCode: String, errorMessage: String)
}

/// Default implementation using closures
class BridgeCallbackImpl: BridgeCallback {
    private let successHandler: (Any?) -> Void
    private let errorHandler: (String, String) -> Void

    init(onSuccess: @escaping (Any?) -> Void, onError: @escaping (String, String) -> Void) {
        self.successHandler = onSuccess
        self.errorHandler = onError
    }

    func onSuccess(data: Any?) {
        successHandler(data)
    }

    func onError(errorCode: String, errorMessage: String) {
        errorHandler(errorCode, errorMessage)
    }
}

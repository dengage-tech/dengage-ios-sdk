import Foundation

/// Handler protocol for async operations with callback response
protocol AsyncBridgeHandler: BridgeHandler {
    /// Handle an async message with callback
    /// - Parameters:
    ///   - message: The bridge message to handle
    ///   - callback: Callback to invoke when operation completes
    func handle(message: BridgeMessage, callback: BridgeCallback)
}

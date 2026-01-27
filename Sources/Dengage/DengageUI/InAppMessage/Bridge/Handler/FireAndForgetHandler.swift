import Foundation

/// Handler protocol for fire-and-forget operations (no response needed)
protocol FireAndForgetHandler: BridgeHandler {
    /// Handle a fire-and-forget message
    /// - Parameter message: The bridge message to handle
    func handle(message: BridgeMessage)
}

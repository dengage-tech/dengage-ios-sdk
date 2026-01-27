import Foundation

/// Handler protocol for synchronous operations with immediate response
protocol SyncBridgeHandler: BridgeHandler {
    /// Handle a sync message and return response immediately
    /// - Parameter message: The bridge message to handle
    /// - Returns: BridgeResponse with the result
    func handleSync(message: BridgeMessage) -> BridgeResponse
}

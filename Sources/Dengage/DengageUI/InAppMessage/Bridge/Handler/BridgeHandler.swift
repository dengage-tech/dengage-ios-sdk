import Foundation

/// Base protocol for all bridge handlers
protocol BridgeHandler {
    /// Returns the list of actions this handler supports
    func supportedActions() -> [String]
}

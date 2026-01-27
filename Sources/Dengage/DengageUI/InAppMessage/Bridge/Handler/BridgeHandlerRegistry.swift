import Foundation

/// Registry for managing bridge handlers
/// Thread-safe implementation
final class BridgeHandlerRegistry {
    private var handlers: [String: BridgeHandler] = [:]
    private let lock = NSLock()

    /// Register a handler for its supported actions
    /// - Parameter handler: The handler to register
    func register(_ handler: BridgeHandler) {
        lock.lock()
        defer { lock.unlock() }

        for action in handler.supportedActions() {
            handlers[action] = handler
        }
    }

    /// Unregister a handler for a specific action
    /// - Parameter action: The action to unregister
    func unregister(action: String) {
        lock.lock()
        defer { lock.unlock() }

        handlers.removeValue(forKey: action)
    }

    /// Get the handler for a specific action
    /// - Parameter action: The action to get handler for
    /// - Returns: The handler or nil if not found
    func getHandler(for action: String) -> BridgeHandler? {
        lock.lock()
        defer { lock.unlock() }

        return handlers[action]
    }

    /// Check if a handler exists for a specific action
    /// - Parameter action: The action to check
    /// - Returns: true if handler exists
    func hasHandler(for action: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return handlers[action] != nil
    }

    /// Get all registered actions
    /// - Returns: Set of all registered action names
    func getRegisteredActions() -> Set<String> {
        lock.lock()
        defer { lock.unlock() }

        return Set(handlers.keys)
    }

    /// Clear all registered handlers
    func clear() {
        lock.lock()
        defer { lock.unlock() }

        handlers.removeAll()
    }
}

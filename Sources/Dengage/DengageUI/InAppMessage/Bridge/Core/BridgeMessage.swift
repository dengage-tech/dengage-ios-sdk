import Foundation

/// Represents a message from JavaScript to Native
struct BridgeMessage {
    let callId: String
    let action: String
    let payload: String?
    let type: MessageType

    enum MessageType {
        case fireForget  // No response needed
        case async       // Callback response
        case sync        // Blocking response
    }
}

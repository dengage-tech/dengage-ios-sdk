import Foundation

/// Push notification events reported to the push api. Open and dismiss share the same request
/// body and the same regular/transactional routing; only the endpoint differs.
enum PushEventType: String {
    case open
    case dismiss

    func path(isTransactional: Bool) -> String {
        switch (self, isTransactional) {
        case (.open, false): return "/api/mobile/open"
        case (.open, true): return "/api/transactional/mobile/open"
        case (.dismiss, false): return "/api/mobile/dismiss"
        case (.dismiss, true): return "/api/transactional/mobile/dismiss"
        }
    }

    /// Local storage key holding the last messageDetails this event was sent for.
    var sentMessageDetailsKey: DengageLocalStorage.Key {
        switch self {
        case .open: return .sentOpenEventMessageDetails
        case .dismiss: return .sentDismissEventMessageDetails
        }
    }
}

import Foundation
import UserNotifications

/// Keeps track of the app icon badge so that pushes with `aps.isIncrementalBadge` can add to it.
///
/// A notification service extension cannot read the current badge (`UIApplication` is unavailable there),
/// so the badge last set by Dengage is stored in the App Group (`appGroupsKey` in the app and
/// `DengageLocalStorage.shared.setAppGroupsUserDefaults(appGroupName:)` in the extension).
/// Without an App Group the badge of the most recently delivered notification is used as the current value.
final class DengageBadgeManager {

    private static let badgeCountKey = "DengageBadgeCount"
    private static let lock = NSLock()

    /// When `aps.isIncrementalBadge` is set (1 / true), replaces the payload badge with the current badge + 1.
    /// Other pushes keep their payload badge, which is stored as the new current badge.
    static func applyBadge(_ content: UNMutableNotificationContent, aps: PushContent.APS?) {
        guard let aps = aps else { return }

        lock.lock()
        defer { lock.unlock() }

        guard aps.isIncrementalBadge else {
            if let badge = aps.badge {
                storeBadgeCount(badge)
            }
            return
        }

        let newBadge = max(currentBadgeCount(), 0) + 1
        content.badge = NSNumber(value: newBadge)
        storeBadgeCount(newBadge)
        Logger.log(message: "Incremental badge applied", argument: String(newBadge))
    }

    /// Called from the app when the real badge is known (app became active, badge reset),
    /// so the next incremental push starts from the badge the user actually sees.
    static func syncBadgeCount(_ badge: Int) {
        lock.lock()
        defer { lock.unlock() }
        storeBadgeCount(badge)
    }

    // MARK: - Private

    private static var appGroupUserDefaults: UserDefaults? {
        return DengageLocalStorage.shared.appGroupUserDefaults
    }

    private static func storeBadgeCount(_ badge: Int) {
        appGroupUserDefaults?.set(max(badge, 0), forKey: badgeCountKey)
    }

    private static func currentBadgeCount() -> Int {
        if let defaults = appGroupUserDefaults {
            return defaults.integer(forKey: badgeCountKey)
        }
        Logger.log(message: "App Group not set, incremental badge is based on delivered notifications")
        return lastDeliveredBadgeCount()
    }

    /// The badge of the newest delivered notification that set one, 0 when there is none.
    private static func lastDeliveredBadgeCount() -> Int {
        var badge = 0
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            badge = notifications
                .filter { $0.request.content.badge != nil }
                .max { $0.date < $1.date }?
                .request.content.badge?.intValue ?? 0
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 2)
        return badge
    }
}

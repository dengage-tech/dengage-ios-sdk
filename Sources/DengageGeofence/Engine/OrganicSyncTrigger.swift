import Foundation
import Dengage

/// Organik sync mekanizması (K6, contract §5). Push delivery + app lifecycle + movement event'lerinden
/// ETag bazlı sync check tetikler. `dgs_sync_check` field'ı opsiyonel opt-out hint'idir.
final class OrganicSyncTrigger {

    enum Reason { case pushDelivered, appForeground, movement, boot, manual }

    static let syncHintKey = "dgs_sync_check"

    /// Push payload'ına göre sync yapılmalı mı? `dgs_sync_check` açıkça "false" değilse true.
    func shouldSyncForPush(_ userInfo: [AnyHashable: Any]?) -> Bool {
        let hint = (userInfo?[OrganicSyncTrigger.syncHintKey] as? String)?.lowercased()
        let shouldSync = hint != "false"
        Logger.log(message: "OrganicSyncTrigger -> push delivered, dgs_sync_check=\(hint ?? "nil"), sync=\(shouldSync)")
        return shouldSync
    }
}

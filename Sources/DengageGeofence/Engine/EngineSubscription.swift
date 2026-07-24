import Foundation
import Dengage

/// Engine bileşenleri için abonelik bilgisi (integrationKey/deviceId/contactKey).
/// `config.getContactKey()` core'da `internal` olduğu için public `config.contactKey` tuple'ından türetilir
/// (type == "c" ise gerçek contact key, aksi halde device fallback → nil).
struct EngineSubscription {
    let integrationKey: String
    let deviceId: String
    let contactKey: String?
    let token: String?

    static func current() -> EngineSubscription? {
        guard let config = Dengage.dengage?.config, !config.integrationKey.isEmpty else { return nil }
        let contact = config.contactKey
        let realContactKey: String? = contact.type == "c" ? contact.key : nil
        return EngineSubscription(
            integrationKey: config.integrationKey,
            deviceId: config.applicationIdentifier,
            contactKey: realContactKey,
            token: config.deviceToken
        )
    }
}

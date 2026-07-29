import Foundation

/// Uyarlamalı fetch gate'i.
///
/// Sabit bir aralık, boş yanıt oranının %97 olduğu bir sistemde zamanın çoğunda gereksiz sık
/// demektir. Gate son yanıtlara bakarak kendini ayarlar: boş yanıtta kademeli geri çekilir, dolu
/// yanıtta tabana döner. Karar cihazda verilir; sunucuya sormaya gerek yok, çünkü boş/dolu bilgisi
/// zaten yanıtın kendisinde.
///
/// - Taban: hesabın `inAppFetchIntervalInMin` ayarı (sunucudan gelir, hesap bazında değiştirilebilir)
/// - Tavan: `max(taban, 15 dk)` — ayarını tavanın üstüne çekmiş bir hesapta geri çekilme, hesabın
///   istediğinden daha sık fetch etmeye **dönüşmemeli**
/// - Sıfırlama: uygulama ön plana geldiğinde. Oturum başı çapası kayan pencereyle birlikte
///   neredeyse hiç tetiklenmeyen bir olaya dönüştüğü için tercih edilmedi.
///
/// Durum yalnızca bellekte tutulur: process ölürse zaten sıfırlanması gerekir.
final class InAppFetchGate {

    enum Channel: CaseIterable {
        case bulk
        case realTime
    }

    static let shared = InAppFetchGate()

    private static let backoffMultiplier: Double = 1.2
    private static let ceiling: TimeInterval = 15 * 60

    private let lock = NSLock()
    private var gates: [Channel: TimeInterval] = [:]

    private init() {}

    /// Kanalın yürürlükteki gate'i (saniye).
    func current(_ channel: Channel, base: TimeInterval) -> TimeInterval {
        lock.lock()
        defer { lock.unlock() }
        return gates[channel] ?? base
    }

    /// Yanıt sonrası gate'i güncelle ve yeni değeri döndür.
    func onResponse(_ channel: Channel, base: TimeInterval, isEmpty: Bool) -> TimeInterval {
        lock.lock()
        defer { lock.unlock() }

        guard isEmpty else {
            // Dolu yanıt: geri çekilmeyi sıfırla.
            gates[channel] = base
            return base
        }

        let ceiling = max(base, Self.ceiling)
        let next = min((gates[channel] ?? base) * Self.backoffMultiplier, ceiling)
        gates[channel] = next
        return next
    }

    /// Uygulama ön plana geldi: geri çekilme sıfırlanır.
    func reset() {
        lock.lock()
        gates.removeAll()
        lock.unlock()
    }
}

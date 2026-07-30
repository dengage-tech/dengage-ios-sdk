import Foundation

/// Uyarlamalı fetch gate'i.
///
/// Sabit bir aralık, boş yanıt oranının %97 olduğu bir sistemde zamanın çoğunda gereksiz sık
/// demektir. Gate son yanıtlara bakarak kendini ayarlar: boş yanıtta kademeli geri çekilir, dolu
/// yanıtta tabana döner. Karar cihazda verilir; sunucuya sormaya gerek yok, çünkü boş/dolu bilgisi
/// zaten yanıtın kendisinde.
///
/// - Taban: hesabın kanal bazlı fetch aralığı ayarı (sunucudan gelir, hesap bazında
///   değiştirilebilir), en az `minBase`. Ayar 0 gelirse çarpım 0'da kilitlenir ve geri çekilme hiç
///   devreye girmez.
/// - Tavan: `max(taban, 15 dk)` — ayarını tavanın üstüne çekmiş bir hesapta geri çekilme, hesabın
///   istediğinden daha sık fetch etmeye **dönüşmemeli**
/// - Sıfırlama: uygulama ön plana geldiğinde. Oturum başı çapası kayan pencereyle birlikte
///   neredeyse hiç tetiklenmeyen bir olaya dönüştüğü için tercih edilmedi.
///
/// Ayrıca kanal başına bir **uçuş bayrağı** tutar: damga yanıt sonrasında atıldığı için, istek
/// uçuştayken gelen ikinci bir tetikleyici aralık kontrolünü geçip aynı çağrıyı tekrar gönderebilir.
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

    /// Gate tabanının alt sınırı (saniye). Hesap ayarı 0 ya da tanımsızsa bu değer kullanılır.
    private static let minBase: TimeInterval = 60

    /// Uçuş bayrağının kendiliğinden düşme süresi. Yanıt geri çağrısı hiç çalışmazsa kanalın
    /// kalıcı olarak kilitlenmemesi için; istek zaman aşımının rahatça üstünde.
    private static let inFlightTimeout: TimeInterval = 30

    private let lock = NSLock()
    private var gates: [Channel: TimeInterval] = [:]
    private var inFlightSince: [Channel: TimeInterval] = [:]

    private init() {}

    /// Kanalın yürürlükteki gate'i (saniye).
    func current(_ channel: Channel, base: TimeInterval) -> TimeInterval {
        lock.lock()
        defer { lock.unlock() }
        return gates[channel] ?? Self.effectiveBase(base)
    }

    /// Yanıt sonrası gate'i güncelle ve yeni değeri döndür.
    func onResponse(_ channel: Channel, base: TimeInterval, isEmpty: Bool) -> TimeInterval {
        lock.lock()
        defer { lock.unlock() }

        let base = Self.effectiveBase(base)

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

    /// İsteği uçuşa al. Aynı kanalda uçuşta istek varsa `false` döner — çağıran isteği
    /// göndermemelidir. Her `true` dönüşü bir `endRequest` ile eşlenmelidir.
    func beginRequest(_ channel: Channel) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let now = Date().timeIntervalSince1970
        if let startedAt = inFlightSince[channel], now - startedAt < Self.inFlightTimeout {
            return false
        }
        inFlightSince[channel] = now
        return true
    }

    /// İstek sonuçlandı (başarılı ya da hatalı): kanal yeniden uygun.
    func endRequest(_ channel: Channel) {
        lock.lock()
        inFlightSince.removeValue(forKey: channel)
        lock.unlock()
    }

    /// Uygulama ön plana geldi: geri çekilme sıfırlanır. Uçuş bayrakları korunur — o istekler hâlâ
    /// yolda ve yanıtları geldiğinde bayrak zaten düşecek.
    func reset() {
        lock.lock()
        gates.removeAll()
        lock.unlock()
    }

    private static func effectiveBase(_ base: TimeInterval) -> TimeInterval {
        max(base, minBase)
    }
}

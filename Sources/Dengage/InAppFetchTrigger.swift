import Foundation

/// In-app fetch'ini tetikleyen olay. Fetch aralığının uygulanıp uygulanmayacağını belirler.
enum InAppFetchTrigger {

    /// Uygulama kullanılabilir hale geldi: soğuk başlatma veya arka plandan ön plana dönüş.
    /// Baskın varış yolu budur, o yüzden fetch aralığına takılmaz; yalnızca kazara çalkantıyı
    /// eleyen küçük bir taban uygulanır.
    case appForeground

    /// Periyodik tur, SDK ayarları yenilemesi veya uygulamanın manuel çağrısı. Aralık uygulanır.
    case other
}

import Foundation
import UIKit

/// Uygulamanın ön planda mı arka planda mı olduğunu izler.
///
/// In-app tarafındaki hiçbir istek uygulama arka plandayken atılmamalıdır: in-app yalnızca kullanıcı
/// uygulamadayken gösterilebildiğine göre arka planda çekilen verinin faydası yok, yalnızca maliyeti
/// var — üstelik fetch interval'ını yaktığı için kullanıcı uygulamayı gerçekten açtığında mesajın
/// gelmemesine yol açıyor.
///
/// Uygulamayı arka planda ayağa kaldıran yollar: silent push (`content-available`), konum/geofence
/// uyanması, arka plan görevleri. Host uygulama SDK'yı `didFinishLaunching` içinde başlattığı için
/// bunların hepsi `Dengage.start` zincirini kullanıcı yokken çalıştırır.
///
/// **Soğuk başlatma:** `applicationState` okunmaz. Seed `launchOptions` se:
/// user (icon / notification tap) vs phone (silent push / location).
final class DengageAppStateTracker {

    static let shared = DengageAppStateTracker()

    private let lock = NSLock()
    private var cachedIsInBackground = false
    private var wokenInBackgroundByPush = false

    private init() {
        registerLifeCycleTrackers()
    }

    /// Uygulama şu an arka planda mı.
    ///
    /// Otoritesi **bildirimlerdir**, `applicationState`'in anlık okuması değil: UIKit
    /// `willEnterForeground` gönderdiğinde durum hâlâ `.background`'dır, uygulama ise ön plana
    /// geçmektedir. Canlı okuma o anda hem yanlış cevap veriyor hem de bildirim handler'ının
    /// yazdığı doğru değeri geri eziyordu.
    ///
    /// Önbellek `Dengage.start` pe `launchOptions` se tohumlanır; sonrasını lifecycle
    /// bildirimleri yürütür. Thread güvenli: `UIApplication` erişimi gerekmez.
    var isInBackground: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cachedIsInBackground
    }

    /// In-app tarafındaki istekler için kapı. Arka planda hiçbir istek atılmaz.
    var shouldSkipRequest: Bool {
        return isInBackground
    }

    /// Called from `Dengage.start`. Skip only when the phone woke the app and the user did not.
    func markLaunchIfNeeded(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let backgroundLaunch = Self.isBackgroundLaunch(launchOptions)
        setCachedState(backgroundLaunch)
        if backgroundLaunch {
            markPushWakeIfInBackground()
        }
    }

    /// Icon tap, notification tap, deep link → false (user is coming).
    /// Silent push, location, Bluetooth restore → true (nobody on screen).
    static func isBackgroundLaunch(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let launchOptions, !launchOptions.isEmpty else { return false }
        if launchOptions[.location] != nil { return true }
        if launchOptions[.bluetoothCentrals] != nil { return true }
        if launchOptions[.bluetoothPeripherals] != nil { return true }
        if let payload = launchOptions[.remoteNotification] as? [AnyHashable: Any] {
            return isSilentPush(payload)
        }
        return false
    }

    /// Visible notification (user can tap) has alert/sound. Silent is content-available only.
    private static func isSilentPush(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let aps = userInfo["aps"] as? [String: Any] else { return false }
        let contentAvailable = (aps["content-available"] as? Int) == 1
            || (aps["content-available"] as? String) == "1"
            || (aps["content-available"] as? Bool) == true
        let hasAlert = aps["alert"] != nil
        let hasSound = aps["sound"] != nil
        return contentAvailable && !hasAlert && !hasSound
    }

    /// Uygulama arka plandayken gelen push için çağrılır. Yalnızca teşhis amaçlıdır — kapı zaten
    /// uygulama durumuna bakar, uyanma sebebine değil.
    func markPushWakeIfInBackground() {
        guard isInBackground else { return }

        lock.lock()
        let alreadyMarked = wokenInBackgroundByPush
        wokenInBackgroundByPush = true
        lock.unlock()

        if !alreadyMarked {
            Logger.log(message: "Push woke the app in background, in app requests suppressed")
        }
    }

    private func setCachedState(_ isInBackground: Bool) {
        lock.lock()
        cachedIsInBackground = isInBackground
        lock.unlock()
    }

    private func registerLifeCycleTrackers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc private func appWillEnterForeground() {
        enteredForeground()
    }

    @objc private func appDidBecomeActive() {
        enteredForeground()
    }

    @objc private func appDidEnterBackground() {
        setCachedState(true)
    }

    private func enteredForeground() {
        lock.lock()
        cachedIsInBackground = false
        wokenInBackgroundByPush = false
        lock.unlock()
    }
}

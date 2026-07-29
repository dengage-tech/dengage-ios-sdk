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
/// **Soğuk başlatma engellenmez:** kullanıcı uygulamayı açtığında `didFinishLaunching` sırasında
/// durum `.inactive`'dir, `.background` değil. Kapı yalnızca `.background` durumunu keser.
final class DengageAppStateTracker {

    static let shared = DengageAppStateTracker()

    private let lock = NSLock()
    private var cachedIsInBackground = false
    private var wokenInBackgroundByPush = false

    private init() {
        registerLifeCycleTrackers()
        refreshCachedState()
    }

    /// Uygulama şu an arka planda mı. Main thread'de gerçek durum okunur ve önbellek tazelenir;
    /// diğer thread'lerde (ör. network callback'leri) lifecycle bildirimlerinden gelen son bilinen
    /// durum kullanılır.
    var isInBackground: Bool {
        guard Thread.isMainThread else {
            lock.lock()
            defer { lock.unlock() }
            return cachedIsInBackground
        }

        let isInBackground = UIApplication.shared.applicationState == .background
        setCachedState(isInBackground)
        return isInBackground
    }

    /// In-app tarafındaki istekler için kapı. Arka planda hiçbir istek atılmaz.
    var shouldSkipRequest: Bool {
        return isInBackground
    }

    /// `didFinishLaunching` akışında çağrılır. launchOptions bir remote notification içeriyor ve
    /// uygulama arka planda başlatıldıysa bu bir silent push uyanışıdır.
    func markLaunchIfNeeded(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard launchOptions?[.remoteNotification] != nil else { return }
        markPushWakeIfInBackground()
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

    private func refreshCachedState() {
        if Thread.isMainThread {
            setCachedState(UIApplication.shared.applicationState == .background)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.setCachedState(UIApplication.shared.applicationState == .background)
            }
        }
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

import Foundation
import UIKit

/// Uygulamanın silent push ile arka planda uyandırılıp uyandırılmadığını izler.
///
/// `content-available` içeren bir silent push (ör. `sourceType=geofence`) uygulamayı arka planda
/// başlatır; host uygulamanın `didFinishLaunching` akışı ve dolayısıyla `Dengage.start` çalışır,
/// bu da normal şartlarda in-app fetch tetikler. Kullanıcı ekranda olmadığı için bu fetch hem
/// gereksiz bir istektir hem de fetch interval'ını yaktığı için kullanıcı uygulamayı gerçekten
/// açtığında in-app gelmemesine yol açar.
///
/// Uygulama öne geldiğinde işaret temizlenir ve `willEnterForeground` akışındaki normal fetch
/// devam eder.
final class DengageSilentPushLaunchTracker {

    static let shared = DengageSilentPushLaunchTracker()

    private let lock = NSLock()
    private var wokenBySilentPush = false
    private var isInBackground = false

    private init() {
        registerLifeCycleTrackers()
    }

    /// Silent push ile uyanıldı ve uygulama hâlâ arka planda mı. true ise in-app mesajları
    /// çekilmemelidir.
    var shouldSkipInAppFetch: Bool {
        lock.lock()
        let woken = wokenBySilentPush
        let cachedBackground = isInBackground
        lock.unlock()

        guard woken else { return false }
        // Main thread'deysek gerçek durumu oku; değilsek lifecycle bildirimlerinden gelen son
        // bilinen duruma güven.
        guard Thread.isMainThread else { return cachedBackground }
        return UIApplication.shared.applicationState == .background
    }

    /// `didFinishLaunching` akışında çağrılır. launchOptions bir remote notification içeriyor ve
    /// uygulama arka planda başlatıldıysa bu bir silent push uyanışıdır. Kullanıcı bildirime
    /// dokunarak açtığında uygulama `.inactive` durumunda olur ve işaretlenmez.
    func markLaunchIfNeeded(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard launchOptions?[.remoteNotification] != nil else { return }
        markSilentPushWakeIfInBackground()
    }

    /// Uygulama arka plandayken gelen push için çağrılır.
    func markSilentPushWakeIfInBackground() {
        guard Thread.isMainThread else { return }
        guard UIApplication.shared.applicationState == .background else { return }

        lock.lock()
        let alreadyMarked = wokenBySilentPush
        wokenBySilentPush = true
        isInBackground = true
        lock.unlock()

        if !alreadyMarked {
            Logger.log(message: "Silent push background wake, in app fetch suppressed")
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
        clearSilentPushWake()
    }

    @objc private func appDidBecomeActive() {
        clearSilentPushWake()
    }

    @objc private func appDidEnterBackground() {
        lock.lock()
        isInBackground = true
        lock.unlock()
    }

    private func clearSilentPushWake() {
        lock.lock()
        wokenBySilentPush = false
        isInBackground = false
        lock.unlock()
    }
}

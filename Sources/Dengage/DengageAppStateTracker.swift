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
    /// Process-lifetime: resets when the app is killed. True only after getSDKParams actually ran.
    private var didFetchSDKParams = false

    private init() {
        registerLifeCycleTrackers()
        refreshCachedState()
    }

    /// Uygulama şu an arka planda mı.
    ///
    /// Otoritesi **bildirimlerdir**, `applicationState`'in anlık okuması değil: UIKit
    /// `willEnterForeground` gönderdiğinde durum hâlâ `.background`'dır, uygulama ise ön plana
    /// geçmektedir. Canlı okuma o anda hem yanlış cevap veriyor hem de bildirim handler'ının
    /// yazdığı doğru değeri geri eziyordu.
    ///
    /// Önbellek `init` içinde gerçek durumdan tohumlanır (bildirimlerin hiç gelmediği ilk an —
    /// arka plan uyanışında `.background`, kullanıcı açılışında `.inactive`), sonrasını lifecycle
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

    /// Call after getSDKParams passes the skip gate, so didBecomeActive will not fetch again.
    func markSDKParamsFetched() {
        lock.lock()
        didFetchSDKParams = true
        lock.unlock()
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
        retrySDKParamsIfNeeded()
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

    /// Scene-based launches skip getSDKParams at start because applicationState is still .background.
    /// didBecomeActive means the user is on screen; fetch then if start never did.
    private func retrySDKParamsIfNeeded() {
        lock.lock()
        let alreadyFetched = didFetchSDKParams
        lock.unlock()
        guard !alreadyFetched else { return }
        Logger.log(message: "getSDKParams retrying on didBecomeActive")
        Dengage.manager?.retryGetSDKParamsIfNeeded()
    }
}

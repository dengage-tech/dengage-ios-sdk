import Foundation
import CoreLocation
import Dengage
#if canImport(UIKit)
import UIKit
#endif

/// Geofence Engine orchestrator (doc 21 §6.5 `GeofenceEngine`).
/// Sync, reeval, OS region register, movement (SLC), trigger, wake-up cap ve event flush'ı koordine eder.
/// Tek bir `CLLocationManager` sahibi ve delegesidir.
final class GeofenceEngine: NSObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let workQueue = DispatchQueue(label: "com.dengage.geofence.engine.work", qos: .utility)

    private let storage = GeofenceStorage()
    private let remoteConfig = RemoteConfigClient()
    private let organicSyncTrigger = OrganicSyncTrigger()
    private let topNSelector = TopNSelector()

    private lazy var registrar = OsGeofenceRegistrar(manager: locationManager)
    private lazy var movementListener = MovementListener(manager: locationManager)
    private lazy var syncer = GeofenceSyncer(fenceRepository: storage.fenceRepository,
                                             syncMetadata: storage.syncMetadataRepository)
    private lazy var heartbeatSender = HeartbeatSender(syncMetadata: storage.syncMetadataRepository)
    private lazy var eventFlusher = EventQueueFlusher(eventQueue: storage.eventQueueRepository)
    private lazy var notificationFirer = LocalNotificationFirer()
    private lazy var triggerHandler = TriggerHandler(
        fenceRepository: storage.fenceRepository,
        deviceStateRepository: storage.deviceStateRepository,
        eventQueue: storage.eventQueueRepository,
        notificationFirer: notificationFirer,
        eventFlusher: eventFlusher,
        triggerHistory: storage.triggerHistoryRepository,
        offlineQueueMaxSize: { [weak self] in self?.remoteConfig.config().offlineQueueMaxSize ?? 100 }
    )
    private lazy var containmentReconciler = ContainmentReconciler(
        fenceRepository: storage.fenceRepository,
        deviceStateRepository: storage.deviceStateRepository
    )
    private lazy var adaptiveThreshold = AdaptiveThresholdCalculator(
        configProvider: { [weak self] in self?.remoteConfig.config().adaptiveThreshold ?? AdaptiveThresholdConfig() }
    )
    private lazy var wakeupCap = WakeupCapController(
        configProvider: { [weak self] in self?.remoteConfig.config().wakeupCap ?? WakeupCapConfig() },
        onPause: { [weak self] in self?.onWakeupPause() },
        onResume: { [weak self] in self?.onWakeupResume() },
        scheduleResume: { [weak self] minutes in self?.scheduleResume(afterMinutes: minutes) },
        syncMetadata: storage.syncMetadataRepository
    )
    private lazy var activeWindowScheduler = ActiveWindowScheduler(onFire: { [weak self] in
        self?.onActiveWindowBoundary()
    })

    private var lastReevalLocation: CLLocation?
    private var running = false
    private var startRequested = false
    /// Dwell timer'ı arm edilmiş fence'ler; fence başına tek timer. Yalnızca `workQueue` üzerinde erişilir.
    private var armedDwellFences = Set<Int>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Lifecycle

    func start() {
        startRequested = true
        // İzin zaten verilmişse authorization-change event'i gelmeyebilir; mevcut izni burada da persist et.
        persistLocationPermission(currentAuthorizationStatus())
        guard remoteConfig.geofenceEnabled() else {
            Logger.log(message: "GeofenceEngine -> disabled by server config")
            stop(); return
        }
        guard hasLocationPermission() else {
            // İzin sonradan verilirse locationManagerDidChangeAuthorization ile başlatılır.
            Logger.log(message: "GeofenceEngine -> location permission missing, waiting for authorization")
            return
        }
        running = true
        configureBackground()

        // Persist edilmiş pause durumunu değerlendir. Süre dolduysa `attemptResume` SLC'yi geri açıp
        // bubble'ı siler; dolmadıysa SLC kapalı kalır ve bubble tek uyandırma kaynağı olarak durur.
        wakeupCap.attemptResume()
        if wakeupCap.isPaused {
            Logger.log(message: "GeofenceEngine -> wake-up cap still paused, keeping bubble as wake source")
            registerWakeupBubbleIfNeeded()
        } else {
            movementListener.start()
        }

        reeval(location: currentLocation(), syncAllowed: true, force: true)
        // Başlangıçta cihaz konumu henüz yoksa bir kez taze fix iste → gelince register olur.
        // (SLC tek başına, özellikle simülatörde, ilk fix'i geç/hiç vermeyebilir.)
        if currentLocation() == nil {
            Logger.log(message: "GeofenceEngine -> no cached location, requesting a fix for registration")
            locationManager.requestLocation()
        }
    }

    func stop() {
        startRequested = false
        running = false
        movementListener.stop()
        registrar.removeAll()
        activeWindowScheduler.cancel()
        adaptiveThreshold.reset()
        wakeupCap.reset()
        workQueue.async { [weak self] in self?.armedDwellFences.removeAll() }
    }

    func requestLocationPermissions() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) { status = locationManager.authorizationStatus }
        else { status = CLLocationManager.authorizationStatus() }

        if #available(iOS 13.4, *) {
            if status == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else if status == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
            }
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func forceResync() {
        reeval(location: currentLocation(), syncAllowed: true, force: true)
    }

    // MARK: - Silent push

    func onSilentPush() {
        storage.syncMetadataRepository.lastSilentPushAt = Date().timeIntervalSince1970
        Logger.log(message: "GeofenceEngine -> silent push resync")
        forceResync()
    }

    func lastSilentPushAt() -> Date? {
        guard let ts = storage.syncMetadataRepository.lastSilentPushAt, ts > 0 else { return nil }
        return Date(timeIntervalSince1970: ts)
    }

    // MARK: - Organic sync / lifecycle

    func requestOrganicSync(reason: OrganicSyncTrigger.Reason) {
        guard remoteConfig.geofenceEnabled() else { return }
        wakeupCap.attemptResume()
        reeval(location: currentLocation(), syncAllowed: true, force: false)
        eventFlusher.flush(batchSize: remoteConfig.config().offlineQueueMaxSize)
        Logger.log(message: "GeofenceEngine -> organic sync requested (\(reason))")
    }

    func handlePushDelivered(_ userInfo: [AnyHashable: Any]?) -> Bool {
        let shouldSync = organicSyncTrigger.shouldSyncForPush(userInfo)
        if shouldSync { requestOrganicSync(reason: .pushDelivered) }
        return shouldSync
    }

    func onAppForeground() { requestOrganicSync(reason: .appForeground) }

    func attemptResume() { wakeupCap.attemptResume() }

    // MARK: - Diagnostics

    /// OS'ta hâlen izlenen fence'ler (teşhis). Kaynak `monitoredRegions`'tır — yani depodaki
    /// listenin tamamı değil, top-N seçimi sonrası gerçekten register edilmiş olanlar.
    func monitoredGeofences() -> [MonitoredGeofenceInfo] {
        let fencesById = Dictionary(
            fenceRepository_loadAll().map { ($0.geofenceId, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return registrar.monitoredFenceRequestIds.compactMap { requestId in
            guard let ids = EngineFence.parseRequestId(requestId) else { return nil }
            let fence = fencesById[ids.geofenceId]
            let state = storage.deviceStateRepository.getState(geofenceId: ids.geofenceId)?.state
            return MonitoredGeofenceInfo(
                geofenceId: ids.geofenceId,
                clusterId: ids.clusterId,
                title: fence?.title,
                latitude: fence?.latitude ?? 0,
                longitude: fence?.longitude ?? 0,
                radiusM: fence?.radiusM ?? 0,
                state: state?.rawValue ?? "unknown"
            )
        }
        .sorted { $0.geofenceId < $1.geofenceId }
    }

    /// Son tetiklenen geçişler (en yeniden eskiye).
    func recentTriggeredEvents(limit: Int) -> [TriggeredEventInfo] {
        storage.triggerHistoryRepository.recent(limit: limit).map {
            TriggeredEventInfo(
                geofenceId: $0.geofenceId,
                clusterId: $0.clusterId,
                title: $0.title,
                eventType: $0.eventType.rawValue,
                occurredAt: Date(timeIntervalSince1970: $0.occurredAtMillis / 1000.0),
                accuracyM: $0.accuracyM,
                campaignIds: $0.campaignIds,
                stateOnly: $0.stateOnly ?? false
            )
        }
    }

    private func fenceRepository_loadAll() -> [EngineFence] {
        storage.fenceRepository.loadAll()
    }

    // MARK: - Wake-up cap pause / bubble

    /// Cap aşıldı: SLC kapatılır. Bunun yerine bir bubble region'ı bırakılır — region monitoring
    /// SLC'den bağımsız çalıştığı ve process ölümünden sağ çıktığı için tek uyandırma kaynağımızdır.
    /// (Yoksa: SLC kapalı + etrafta fence yok + process öldü → uygulama hiç uyanamaz.)
    private func onWakeupPause() {
        movementListener.stop()
        registerWakeupBubble()
    }

    private func onWakeupResume() {
        registrar.removeBubble()
        movementListener.start()
    }

    private func registerWakeupBubbleIfNeeded() {
        guard !registrar.isBubbleRegistered else { return }
        registerWakeupBubble()
    }

    private func registerWakeupBubble() {
        guard let location = locationManager.location ?? lastReevalLocation else {
            Logger.log(message: "GeofenceEngine -> wake-up bubble skipped: no location yet")
            return
        }
        registrar.registerBubble(center: location.coordinate, radius: kWakeupBubbleRadiusMeters)
    }

    /// Bubble'dan çıkıldı → kullanıcı kayda değer biçimde yer değiştirdi.
    /// Pause süresi dolduysa normale dönülür; dolmadıysa bubble yeni konuma taşınır (ucuz uyanma).
    private func handleWakeupBubbleExit() {
        Logger.log(message: "GeofenceEngine -> wake-up bubble exited")
        wakeupCap.attemptResume()
        guard wakeupCap.isPaused else { return }
        registerWakeupBubble()
    }

    func onActiveWindowBoundary() {
        reeval(location: currentLocation(), syncAllowed: true, force: false)
    }

    // MARK: - Core reeval

    /// [fireCampaigns] yalnızca movement kaynaklı reeval'de `true`. Diğer (start / organic sync /
    /// silent push / active-window) reeval'lerde sentetik geçiş state-only işlenir, kampanya atmaz.
    private func reeval(location: CLLocation?, syncAllowed: Bool, force: Bool, fireCampaigns: Bool = false) {
        if let location = location { lastReevalLocation = location }

        if syncAllowed {
            syncer.sync(lat: location?.coordinate.latitude, lon: location?.coordinate.longitude) { [weak self] _ in
                guard let self = self else { return }
                self.registerTopN(location: location)
                if let loc = location {
                    self.reconcileContainment(location: loc, fireCampaigns: fireCampaigns)
                    self.heartbeatSender.maybeSend(location: loc, intervalMinutes: self.remoteConfig.config().heartbeatIntervalMinutes, force: force)
                }
            }
        } else {
            Logger.log(message: "GeofenceEngine -> transit mode: local top-N only, server sync skipped")
            registerTopN(location: location)
            if let loc = location {
                reconcileContainment(location: loc, fireCampaigns: fireCampaigns)
                heartbeatSender.maybeSend(location: loc, intervalMinutes: remoteConfig.config().heartbeatIntervalMinutes, force: force)
            }
        }
    }

    /// Synthetic transition check (doc 22 §2.1). Without waiting for the OS callback, closes the
    /// gaps between the location and the state table with our own events (missed exit, enter that
    /// never arrived).
    ///
    /// [fireCampaigns]: movement kaynaklı reeval'de `true` → kampanya tetiklenebilir. Silent push /
    /// sync-only reeval'de `false` → yalnızca state reconcile edilir; `occurredAt = now` bir pasif
    /// wake'te dürüst olmadığından bayat/sahte push üretmemek için kampanya bastırılır.
    private func reconcileContainment(location: CLLocation, fireCampaigns: Bool) {
        // Same serial queue as OS transitions, so the dedup's check-then-set stays atomic against them.
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let pending = self.containmentReconciler.reconcile(location: location)
            guard !pending.isEmpty else { return }

            // A synthetic event POSTs event-signal too — stay alive if we were woken in the background.
            let bgTask = BackgroundTaskAssertion(name: "com.dengage.geofence.reconcile")
            let group = DispatchGroup()
            for item in pending {
                group.enter()
                self.triggerHandler.handle(eventType: item.eventType,
                                           requestId: item.fence.requestId,
                                           location: location,
                                           fireCampaigns: fireCampaigns) {
                    group.leave()
                }
            }
            group.notify(queue: self.workQueue) { bgTask.end() }
        }
    }

    private func registerTopN(location: CLLocation?) {
        guard let location = location else {
            Logger.log(message: "GeofenceEngine -> registerTopN skipped: no location yet")
            return
        }
        let config = remoteConfig.config()
        let all = storage.fenceRepository.loadAll()
        let selected = topNSelector.select(fences: all,
                                           lat: location.coordinate.latitude,
                                           lon: location.coordinate.longitude,
                                           topN: config.topN)
        registrar.register(selected)
        activeWindowScheduler.schedule(fences: selected)
        Logger.log(message: "GeofenceEngine -> registered \(selected.count)/\(all.count) fences (topN=\(config.topN))")
    }

    // MARK: - CLLocationManagerDelegate

    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        persistLocationPermission(manager.authorizationStatus)
        handleAuthorizationChange()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // iOS 14 öncesi. iOS 14+ locationManagerDidChangeAuthorization kullanır.
        if #available(iOS 14.0, *) { return }
        persistLocationPermission(status)
        handleAuthorizationChange()
    }

    private func handleAuthorizationChange() {
        guard startRequested, !running, hasLocationPermission() else { return }
        Logger.log(message: "GeofenceEngine -> authorization granted, starting")
        start()
    }

    /// Konum izni string'ini (`none`/`always`/`appinuse`) subscription request'i için persist eder.
    /// v1 `DengageGeofenceManager` bu değeri yazıyordu; v2'ye geçince yazan kalmamıştı → subscription'da boş gidiyordu.
    private func persistLocationPermission(_ status: CLAuthorizationStatus) {
        Dengage.setLocationPermission(status: status.string)
    }

    // Not: Bubble da `dengage_v2` prefix'i taşır; kampanya fence'i olmadığı için trigger yolundan
    // önce ayrıştırılmalı (aksi halde `parseRequestId` başarısız olup sessizce düşerdi).

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier != kWakeupBubbleIdentifier else { return }
        handleTransition(.enter, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == kWakeupBubbleIdentifier {
            handleWakeupBubbleExit(); return
        }
        handleTransition(.exit, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard region.identifier != kWakeupBubbleIdentifier else { return }
        // K9: register sonrası cihaz fence içindeyse anında enter için state sorgula
        manager.requestState(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region.identifier != kWakeupBubbleIdentifier,
              region.identifier.hasPrefix(kEngineRequestIdPrefix), state == .inside else { return }
        handleTransition(.enter, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        handleMovement(location)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Logger.log(message: "GeofenceEngine -> monitoring failed: \(error.localizedDescription)")
        GeofenceDebugLog.error("Geofence region monitoring failed", context: [
            "error": error.localizedDescription,
            "region": region?.identifier ?? "nil"
        ])
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.log(message: "GeofenceEngine -> location failed: \(error.localizedDescription)")
        GeofenceDebugLog.error("Geofence location update failed", context: ["error": error.localizedDescription])
    }

    // MARK: - Transition / movement

    private func handleTransition(_ eventType: GeofenceEventType, region: CLRegion) {
        guard region.identifier.hasPrefix(kEngineRequestIdPrefix) else { return }
        // Region callback'i pause süresini etkilemez; ayrıca resume fırsatı verir (K13)
        wakeupCap.attemptResume()
        let location = locationManager.location
        let requestId = region.identifier
        // OS geçişi: occurredAt fix zamanından türetilir (OS beklettiyse geçmiş bir zaman).
        let occurredAt = TriggerHandler.occurredAtMillis(fixTime: location)
        // Arka planda uyandırıldıysak event-signal POST'u bitene kadar uygulamayı canlı tut
        // (Android goAsync() muadili); yoksa iOS suspend eder ve push saatlerce gecikir.
        let bgTask = BackgroundTaskAssertion(name: "com.dengage.geofence.trigger")
        workQueue.async { [weak self] in
            guard let self = self else { bgTask.end(); return }
            self.triggerHandler.handle(eventType: eventType, requestId: requestId, location: location,
                                       occurredAtMillis: occurredAt) {
                bgTask.end()
            }
            if eventType == .enter { self.scheduleDwellIfNeeded(requestId: requestId, location: location) }
        }
    }

    private func handleMovement(_ location: CLLocation) {
        guard remoteConfig.geofenceEnabled() else { stop(); return }
        switch wakeupCap.recordWakeup() {
        case .skipPaused, .pauseAndSkip: return
        case .proceed: break
        }
        workQueue.async { [weak self] in
            guard let self = self else { return }
            self.heartbeatSender.maybeSend(location: location, intervalMinutes: self.remoteConfig.config().heartbeatIntervalMinutes)
            switch self.adaptiveThreshold.shouldReeval(current: location, lastReevalLocation: self.lastReevalLocation) {
            case .reeval(let syncAllowed):
                // Movement kaynaklı → sentetik geçiş kampanya tetikleyebilir (occurredAt=now dürüst).
                self.reeval(location: location, syncAllowed: syncAllowed, force: false, fireCampaigns: true)
            case .skip(let reason):
                Logger.log(message: "GeofenceEngine -> reeval skipped (\(reason))")
            }
        }
    }

    /// iOS region monitoring native DWELL desteklemez; dwell kampanyası varsa enter sonrası
    /// gecikmeli kontrol planlanır (best-effort, process canlıyken).
    ///
    /// Her enter callback'inde çağrılır — ki bunların çoğu yinelenmedir (her `registerTopN`
    /// re-register'ı `didDetermineState(.inside)` üretir). Bu yüzden fence başına en fazla bir
    /// timer arm edilir ve yalnızca cihaz `.inside` iken (dwell henüz atılmamışken; `.dwellPending`
    /// durumunda `isInside` false döner) kurulur.
    private func scheduleDwellIfNeeded(requestId: String, location: CLLocation?) {
        guard let ids = EngineFence.parseRequestId(requestId),
              let dwellMinutes = triggerHandler.dwellMinutes(forFenceId: ids.geofenceId) else { return }
        guard triggerHandler.isInside(geofenceId: ids.geofenceId),
              !armedDwellFences.contains(ids.geofenceId) else { return }
        armedDwellFences.insert(ids.geofenceId)

        let delay = TimeInterval(dwellMinutes * 60)
        workQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.armedDwellFences.remove(ids.geofenceId)
            guard self.triggerHandler.isInside(geofenceId: ids.geofenceId) else { return }
            self.triggerHandler.handle(eventType: .dwell, requestId: requestId, location: self.locationManager.location ?? location)
        }
    }

    // MARK: - Helpers

    private func currentLocation() -> CLLocation? {
        lastReevalLocation ?? locationManager.location
    }

    private func currentAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) { return locationManager.authorizationStatus }
        return CLLocationManager.authorizationStatus()
    }

    private func hasLocationPermission() -> Bool {
        let status = currentAuthorizationStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }

    private func configureBackground() {
        let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String]
        let allowed = backgroundModes?.contains("location") ?? false
        let always: Bool
        if #available(iOS 14.0, *) { always = locationManager.authorizationStatus == .authorizedAlways }
        else { always = CLLocationManager.authorizationStatus() == .authorizedAlways }
        if allowed && always {
            locationManager.allowsBackgroundLocationUpdates = true
        }
    }

    private func scheduleResume(afterMinutes minutes: Int) {
        workQueue.asyncAfter(deadline: .now() + TimeInterval(minutes * 60)) { [weak self] in
            self?.attemptResume()
        }
    }
}

/// Geofence engine hata loglaması için ince köprü. Dengage modülündeki flag-gate'li
/// (`sdkErrorLoggingEnabled`) helper'a yönlendirir; `DebugLog`/`DebugLogRequest` Dengage'de
/// internal olduğundan engine bunları doğrudan kuramaz.
enum GeofenceDebugLog {
    static func error(_ message: String, context: [String: String] = [:]) {
        Dengage.dengage?.config.sendGeofenceErrorLog(message: message, context: context)
    }
}

/// Arka planda (region event ile uyanma) ağ işini tamamlayana kadar uygulamayı canlı tutan
/// UIApplication background task assertion sarmalayıcısı — Android'deki `BroadcastReceiver.goAsync()`
/// muadili. `end()` idempotent'tir ve expiration handler ile bir kez daha çağrılabilir.
final class BackgroundTaskAssertion {
    #if canImport(UIKit) && !os(watchOS)
    private let lock = NSLock()
    private var taskId: UIBackgroundTaskIdentifier = .invalid

    init(name: String) {
        taskId = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            // Süre dolarsa iOS assertion'ı geri ister; task'ı kapat.
            self?.end()
        }
    }

    func end() {
        lock.lock(); defer { lock.unlock() }
        guard taskId != .invalid else { return }
        let id = taskId
        taskId = .invalid
        UIApplication.shared.endBackgroundTask(id)
    }
    #else
    init(name: String) {}
    func end() {}
    #endif
}

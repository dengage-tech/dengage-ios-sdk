import Foundation
import CoreLocation
import Dengage

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
        offlineQueueMaxSize: { [weak self] in self?.remoteConfig.config().offlineQueueMaxSize ?? 100 }
    )
    private lazy var adaptiveThreshold = AdaptiveThresholdCalculator(
        configProvider: { [weak self] in self?.remoteConfig.config().adaptiveThreshold ?? AdaptiveThresholdConfig() }
    )
    private lazy var wakeupCap = WakeupCapController(
        configProvider: { [weak self] in self?.remoteConfig.config().wakeupCap ?? WakeupCapConfig() },
        onPause: { [weak self] in self?.movementListener.stop() },
        onResume: { [weak self] in self?.movementListener.start() },
        scheduleResume: { [weak self] minutes in self?.scheduleResume(afterMinutes: minutes) }
    )
    private lazy var activeWindowScheduler = ActiveWindowScheduler(onFire: { [weak self] in
        self?.onActiveWindowBoundary()
    })

    private var lastReevalLocation: CLLocation?
    private var running = false
    private var startRequested = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Lifecycle

    func start() {
        startRequested = true
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
        movementListener.start()
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

    func onActiveWindowBoundary() {
        reeval(location: currentLocation(), syncAllowed: true, force: false)
    }

    // MARK: - Core reeval

    private func reeval(location: CLLocation?, syncAllowed: Bool, force: Bool) {
        if let location = location { lastReevalLocation = location }

        if syncAllowed {
            syncer.sync(lat: location?.coordinate.latitude, lon: location?.coordinate.longitude) { [weak self] _ in
                guard let self = self else { return }
                self.registerTopN(location: location)
                if let loc = location {
                    self.heartbeatSender.maybeSend(location: loc, intervalMinutes: self.remoteConfig.config().heartbeatIntervalMinutes, force: force)
                }
            }
        } else {
            Logger.log(message: "GeofenceEngine -> transit mode: local top-N only, server sync skipped")
            registerTopN(location: location)
            if let loc = location {
                heartbeatSender.maybeSend(location: loc, intervalMinutes: remoteConfig.config().heartbeatIntervalMinutes, force: force)
            }
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
        handleAuthorizationChange()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // iOS 14 öncesi. iOS 14+ locationManagerDidChangeAuthorization kullanır.
        if #available(iOS 14.0, *) { return }
        handleAuthorizationChange()
    }

    private func handleAuthorizationChange() {
        guard startRequested, !running, hasLocationPermission() else { return }
        Logger.log(message: "GeofenceEngine -> authorization granted, starting")
        start()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleTransition(.enter, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleTransition(.exit, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // K9: register sonrası cihaz fence içindeyse anında enter için state sorgula
        manager.requestState(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region.identifier.hasPrefix(kEngineRequestIdPrefix), state == .inside else { return }
        handleTransition(.enter, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        handleMovement(location)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Logger.log(message: "GeofenceEngine -> monitoring failed: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.log(message: "GeofenceEngine -> location failed: \(error.localizedDescription)")
    }

    // MARK: - Transition / movement

    private func handleTransition(_ eventType: GeofenceEventType, region: CLRegion) {
        guard region.identifier.hasPrefix(kEngineRequestIdPrefix) else { return }
        // Region callback'i pause süresini etkilemez; ayrıca resume fırsatı verir (K13)
        wakeupCap.attemptResume()
        let location = locationManager.location
        let requestId = region.identifier
        workQueue.async { [weak self] in
            guard let self = self else { return }
            self.triggerHandler.handle(eventType: eventType, requestId: requestId, location: location)
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
                self.reeval(location: location, syncAllowed: syncAllowed, force: false)
            case .skip(let reason):
                Logger.log(message: "GeofenceEngine -> reeval skipped (\(reason))")
            }
        }
    }

    /// iOS region monitoring native DWELL desteklemez; dwell kampanyası varsa enter sonrası
    /// gecikmeli kontrol planlanır (best-effort, process canlıyken).
    private func scheduleDwellIfNeeded(requestId: String, location: CLLocation?) {
        guard let ids = EngineFence.parseRequestId(requestId),
              let dwellMinutes = triggerHandler.dwellMinutes(forFenceId: ids.geofenceId) else { return }
        let delay = TimeInterval(dwellMinutes * 60)
        workQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, self.triggerHandler.isInside(geofenceId: ids.geofenceId) else { return }
            self.triggerHandler.handle(eventType: .dwell, requestId: requestId, location: self.locationManager.location ?? location)
        }
    }

    // MARK: - Helpers

    private func currentLocation() -> CLLocation? {
        lastReevalLocation ?? locationManager.location
    }

    private func hasLocationPermission() -> Bool {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) { status = locationManager.authorizationStatus }
        else { status = CLLocationManager.authorizationStatus() }
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

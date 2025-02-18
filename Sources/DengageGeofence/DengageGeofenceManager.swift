import Foundation
import UIKit
import CoreLocation
import UserNotifications
import Dengage

let kIdentifierPrefix = "dengage_"
let kBubbleGeofenceIdentifierPrefix = "dengage_bubble_"
let kSyncGeofenceIdentifierPrefix = "dengage_geofence_"

final class DengageGeofenceManager: NSObject, DengageGeofenceManagerInterface {
    
    typealias CLLM = CLLocationManager
    let tOptions = DengageGeofenceTrackingOptions()
    
    var lManager: CLLM // locationManager
    var lPLManager: CLLM // lowPowerLocationManager
    
    var config: DengageConfiguration?
    var apiClient: DengageNetworking?
    var geofenceHistory: DengageGeofenceHistory
    
    private var started = false
    private var startedInterval = 0
    private var sending = false
    private var fetching = false
    private var timer: Timer?
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            do {
                let status = try getManagerAuthorizationStatus()
                return status
            } catch {
                return CLLM.authorizationStatus()
            }
        } else {
            return CLLM.authorizationStatus()
        }
    }
    
    private func getManagerAuthorizationStatus() throws -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return lManager.authorizationStatus
        } else {
            return CLLM.authorizationStatus()
        }
    }
    
    override init() {
        if !Dengage.startCalled {
            let integrationKey =  DengageLocalStorage.shared.value(for: .integrationKeySubscription) as? String ?? ""
            Dengage.start(apiKey: integrationKey, launchOptions: nil)
        }
        if let apiClient = Dengage.dengage?.apiClient, let config = Dengage.dengage?.config {
            self.apiClient = apiClient
            self.config = config
        }
        geofenceHistory = DengageGeofenceState.getGeofenceHistory()
        lManager = CLLM()
        lPLManager = CLLM()
        super.init()
        lManager.desiredAccuracy = tOptions.desiredCLLocationAccuracy
        lManager.distanceFilter = kCLDistanceFilterNone
        lManager.allowsBackgroundLocationUpdates = tOptions.locationBackgroundMode && getAuthorizationStatus() == .authorizedAlways
        lPLManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        lPLManager.distanceFilter = 3000
        lPLManager.allowsBackgroundLocationUpdates =     tOptions.locationBackgroundMode
        lManager.delegate = self
        lPLManager.delegate = self
        updateTracking(location: nil, fromInitialize: true)
        if DengageGeofenceState.getGeofenceEnabled() {
            startTracking(options: tOptions, fromInitialize: true)
        }
    }
    
    init(config: DengageConfiguration, service: DengageNetworking) {
        self.config = config
        self.apiClient = service
        geofenceHistory = DengageGeofenceState.getGeofenceHistory()
        lManager = CLLM()
        lPLManager = CLLM()
        super.init()
        lManager.desiredAccuracy = tOptions.desiredCLLocationAccuracy
        lManager.distanceFilter = kCLDistanceFilterNone
        lManager.allowsBackgroundLocationUpdates = tOptions.locationBackgroundMode && getAuthorizationStatus() == .authorizedAlways
        lPLManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        lPLManager.distanceFilter = 3000
        lPLManager.allowsBackgroundLocationUpdates = tOptions.locationBackgroundMode
        lManager.delegate = self
        lPLManager.delegate = self
        updateTracking(location: nil, fromInitialize: true)
        if DengageGeofenceState.getGeofenceEnabled() {
            startTracking(options: tOptions, fromInitialize: true)
        }
    }
    
    deinit {
        lManager.delegate = nil
        lPLManager.delegate = nil
    }
    
    func startTracking(options: DengageGeofenceTrackingOptions, fromInitialize: Bool) {
        let authorizationStatus = DengageGeofenceState.locationAuthorizationStatus()
        if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            return
        }
        DengageGeofenceState.setGeofenceEnabled(true)
        updateTracking(location: nil, fromInitialize: fromInitialize)
        if let clusters = geofenceHistory.fetchHistory.sorted(by: { $0.key > $1.key }).first?.value {
            replaceSyncedGeofences(clusters)
        }
        fetchGeofences()
    }
    
    func stopGeofence() {
        DengageGeofenceState.setGeofenceEnabled(false)
        updateTracking(location: nil, fromInitialize: false)
    }
    
    func startUpdates(_ interval: Int) {
        if !started || interval != startedInterval {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(shutDown), object: nil)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [self] _ in
                self.requestLocation()
            }
            lPLManager.startUpdatingLocation()
            started = true
            startedInterval = interval
        }
    }
    
    private func stopUpdates() {
        guard let timer = timer else {
            return
        }
        Logger.log(message: "Stopping geofence timer")
        timer.invalidate()
        started = false
        startedInterval = 0
        if !sending {
            let delay: TimeInterval = DengageGeofenceState.getGeofenceEnabled() ? 10 : 0
            Logger.log(message: "Scheduling geofence shutdown")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.shutDown()
            }
        }
    }
    
    @objc func shutDown() {
        Logger.log(message: "Shutting geofence down")
        lPLManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        Logger.log(message: "Requesting location")
        lManager.requestLocation()
    }
    
    func updateTracking(location: CLLocation?, fromInitialize: Bool) {
        
        DispatchQueue.main.async {
            
            if DengageGeofenceState.getGeofenceEnabled() {
                self.lManager.allowsBackgroundLocationUpdates = self.tOptions.locationBackgroundMode && self.getAuthorizationStatus() == .authorizedAlways
                self.lManager.pausesLocationUpdatesAutomatically = false
                
                self.lPLManager.allowsBackgroundLocationUpdates = self.tOptions.locationBackgroundMode
                self.lPLManager.pausesLocationUpdatesAutomatically = false
                
                self.lManager.desiredAccuracy = self.tOptions.desiredCLLocationAccuracy
                
                if #available(iOS 11, *) {
                    self.lPLManager.showsBackgroundLocationIndicator = self.tOptions.showBlueBar
                }
                
                let startUpdates = self.tOptions.showBlueBar || self.getAuthorizationStatus() == .authorizedAlways
                let stopped = DengageGeofenceState.getStopped()
                if stopped {
                    
                    if self.tOptions.desiredStoppedUpdateInterval == 0 {
                        self.stopUpdates()
                    } else if startUpdates {
                        self.startUpdates(self.tOptions.desiredStoppedUpdateInterval)
                    }
                    
                    if self.tOptions.useStoppedGeofence, let location = location {
                        self.replaceBubbleGeofence(location, radius: self.tOptions.stoppedGeofenceRadius)
                    } else {
                        self.removeBubbleGeofence()
                    }
                    
                } else {
                    
                    if self.tOptions.desiredMovingUpdateInterval == 0 {
                        self.stopUpdates()
                    } else if startUpdates {
                        self.startUpdates(self.tOptions.desiredMovingUpdateInterval)
                    }
                    if self.tOptions.useMovingGeofence, let location = location {
                        self.replaceBubbleGeofence(location, radius: self.tOptions.movingGeofenceRadius)
                    } else {
                        self.removeBubbleGeofence()
                    }
                }
                
                if !self.tOptions.syncGeofences {
                    self.removeSyncedGeofences()
                }
                if self.tOptions.useSignificantLocationChanges {
                    self.lManager.startMonitoringSignificantLocationChanges()
                }
                
            } else {
                self.stopUpdates()
                self.removeAllRegions()
                if !fromInitialize {
                    self.lManager.stopMonitoringSignificantLocationChanges()
                }
            }
            
            
        }
        
        
    }
    
    func replaceBubbleGeofence(_ location: CLLocation, radius: Int) {
        removeBubbleGeofence()
        if !DengageGeofenceState.getGeofenceEnabled() {
            return
        }
        lManager.startMonitoring(for: CLCircularRegion(center: location.coordinate, radius: CLLocationDistance(radius), identifier: "\(kBubbleGeofenceIdentifierPrefix)\(UUID().uuidString)"))
    }
    
    func removeBubbleGeofence() {
        for region in lManager.monitoredRegions {
            if region.identifier.hasPrefix(kBubbleGeofenceIdentifierPrefix) {
                lManager.stopMonitoring(for: region)
            }
        }
    }
    
    func replaceSyncedGeofences(_ geofenceClusters: [DengageGeofenceCluster]) {
        removeSyncedGeofences()
        if !DengageGeofenceState.getGeofenceEnabled() || !tOptions.syncGeofences {
            return
        }
        
        let lastKnownCoordinate = (DengageGeofenceState.getLastLocation() ?? CLLocation(latitude: 0.0, longitude: 0.0)).coordinate
        
        var geofencesWithDistance = [(item: DengageGeofenceItem, clusterId: Int, dist: Double)]()
        for geofenceCluster in geofenceClusters {
            if let geofences = geofenceCluster.geofences {
                for geofence in geofences {
                    let geoCoordinate = CLLocationCoordinate2D(latitude: geofence.lat,
                                                               longitude: geofence.lon)
                    geofencesWithDistance.append((item: geofence,
                                                  clusterId: geofenceCluster.id,
                                                  dist: lastKnownCoordinate.distanceSquared(geoCoordinate)))
                }
            }
        }
        
        geofencesWithDistance = geofencesWithDistance.sorted { (first, second) -> Bool in
            return first.dist < second.dist
        }
        
        var geofenceDic = [String: DengageGeofenceItem]()
        for geofenceWithDistance in geofencesWithDistance {
            let identifier = "\(kSyncGeofenceIdentifierPrefix)\(geofenceWithDistance.clusterId)_\(geofenceWithDistance.item.id)"
            geofenceDic[identifier] = geofenceWithDistance.item
            if geofenceDic.count >= GEOFENCE_MAX_MONITOR_COUNT {
                break
            }
        }
        
        for (identifier, geofenceItem) in geofenceDic {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: geofenceItem.lat, longitude: geofenceItem.lon),
                                          radius: CLLocationDistance(geofenceItem.radius),
                                          identifier: identifier)
            lManager.startMonitoring(for: region)
            //Logger.log(message: "Synced geofence | lat = \(geofenceItem.lat); lon = \(geofenceItem.lon); rad = \(geofenceItem.radius); id \(identifier)")
        }
    }
    
    func removeSyncedGeofences() {
        for region in lManager.monitoredRegions {
            if region.identifier.hasPrefix(kSyncGeofenceIdentifierPrefix) {
                lManager.stopMonitoring(for: region)
            }
        }
    }
    
    func removeAllRegions() {
        for region in lManager.monitoredRegions {
            if region.identifier.hasPrefix(kIdentifierPrefix) {
                lManager.stopMonitoring(for: region)
            }
        }
    }
    
}

// MARK: - Handlers

extension DengageGeofenceManager {
    
    func handleLocation(_ location: CLLocation, source: DengageLocationSource, region: CLRegion? = nil) {
        //Logger.log(message: "Handling location | source = \(source); location = \(String(describing: location))")
        
        if !DengageGeofenceState.validLocation(location) {
            Logger.log(message: "Invalid location | source = \(source); location = \(String(describing: location))")
            return
        }
        
        let options = self.tOptions
        let wasStopped = DengageGeofenceState.getStopped()
        var stopped = false
        
        let force = source == .foregroundLocation || source == .manualLocation
        
        if wasStopped && !force && location.horizontalAccuracy >= 1000 && options.desiredAccuracy != .low {
            Logger.log(message: "Skipping location: inaccurate | accuracy = \(location.horizontalAccuracy)")
            updateTracking(location: location, fromInitialize: false)
            return
        }
        
        if !force && !DengageGeofenceState.getGeofenceEnabled() {
            //Logger.log(message: "Skipping location: not tracking")
            return
        }
        
        var distance = CLLocationDistanceMax
        var duration: TimeInterval = 0
        if options.stopDistance > 0, options.stopDuration > 0 {
            
            var lastMovedLocation: CLLocation?
            var lastMovedAt: Date?
            
            if DengageGeofenceState.getLastMovedLocation() == nil {
                lastMovedLocation = location
                DengageGeofenceState.setLastMovedLocation(location)
            }
            
            if DengageGeofenceState.getLastMovedAt() == nil {
                lastMovedAt = location.timestamp
                DengageGeofenceState.setLastMovedAt(location.timestamp)
            }
            
            if !force, let lastMovedAt = lastMovedAt, lastMovedAt.timeIntervalSince(location.timestamp) > 0 {
                //Logger.log(message: "Skipping location: old | lastMovedAt = \(lastMovedAt); location.timestamp = \(location.timestamp)")
                return
            }
            
            if let lastMovedLocation = lastMovedLocation, let lastMovedAt = lastMovedAt {
                distance = location.distance(from: lastMovedLocation)
                duration = location.timestamp.timeIntervalSince(lastMovedAt)
                if duration == 0 {
                    duration = -location.timestamp.timeIntervalSinceNow
                }
                stopped = Int(distance) <= options.stopDistance && Int(duration) >= options.stopDuration
                
                if Int(distance) > options.stopDistance {
                    DengageGeofenceState.setLastMovedLocation(location)
                    if !stopped {
                        DengageGeofenceState.setLastMovedAt(location.timestamp)
                    }
                }
            }
        } else {
            stopped = force
        }
        
        let justStopped = stopped && !wasStopped
        DengageGeofenceState.setStopped(stopped)
        DengageGeofenceState.setLastLocation(location)
        
        if source != .manualLocation {
            updateTracking(location: location, fromInitialize: false)
        }
        
        var sendLocation = location
        
        let lastFailedStoppedLocation = DengageGeofenceState.getLastFailedStoppedLocation()
        var replayed = false
        if options.replay == .stops,
           let lastFailedStoppedLocation = lastFailedStoppedLocation,
           !justStopped {
            sendLocation = lastFailedStoppedLocation
            stopped = true
            replayed = true
            DengageGeofenceState.setLastFailedStoppedLocation(nil)
            //Logger.log(message: "Replaying location | location = \(sendLocation); stopped = \(stopped)")
        }
        let lastSentAt = DengageGeofenceState.getLastSentAt()
        let ignoreSync = lastSentAt == nil || justStopped || replayed
        let now = Date()
        var lastSyncInterval: TimeInterval?
        
        if let lastSentAt = lastSentAt {
            lastSyncInterval = now.timeIntervalSince(lastSentAt)
        }
        
        if !ignoreSync {
            if !force && stopped && wasStopped && Int(distance) <= options.stopDistance && (options.desiredStoppedUpdateInterval == 0 || options.syncLocations != .syncAll) {
                return
            }
            if !force && !justStopped && Int(lastSyncInterval ?? 0) < 1 {
                return
            }
            if options.syncLocations == .syncNone {
                return
            }
        }
        
        DengageGeofenceState.setLastSentAt()
        
        if source == .foregroundLocation {
            return
        }
        self.sendLocation(sendLocation, stopped: stopped, source: source, replayed: replayed, region: region)
    }
    
    func sendLocation(_ location: CLLocation, stopped: Bool, source: DengageLocationSource, replayed: Bool, region: CLRegion? = nil) {
        if sending {
            return
        }
        
        sending = true
        
        if [DengageLocationSource.geofenceEnter, DengageLocationSource.geofenceExit].contains(source) {
            
            guard let region = region, region.identifier.hasPrefix(kIdentifierPrefix), let config = config else {
                sending = false
                return
            }
            
            let identifier = region.identifier
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            let identifierArr = identifier.components(separatedBy: "_")
            guard identifierArr.count >= 3, let clusterId = Int(identifierArr[2]), let geofenceId = Int(identifierArr[3]) else {
                sending = false
                return
            }
            
            guard let lastClusters = geofenceHistory.fetchHistory.sorted(by: { $0.key > $1.key }).first?.value else {
                sending = false
                return
            }
            guard let cluster = lastClusters.first(where: { $0.id == clusterId}) else {
                sending = false
                return
            }
            guard let geofences = cluster.geofences, let _ = geofences.first(where: { $0.id == geofenceId}) else {
                sending = false
                return
            }
            
            if let events = geofenceHistory.eventHistory[identifier],
               let lastEvent = events.sorted(by: { $0.key > $1.key }).first?.value,
               GEOFENCE_MAX_EVENT_SIGNAL_INTERVAL > (Date().timeIntervalSince1970 - lastEvent.et.timeIntervalSince1970) {
                sending = false
                return
            }
            
            checkNotificationPermit { [weak self] pushPermit in
                let request = GeofenceEventSignalRequest(integrationKey: config.integrationKey,
                                                         clusterId: clusterId,
                                                         geofenceId: geofenceId,
                                                         deviceId: config.applicationIdentifier,
                                                         contactKey: config.contactKey.key,
                                                         latitude: location.coordinate.latitude,
                                                         longitude: location.coordinate.longitude,
                                                         type: source == .geofenceEnter ? "enter": "exit",
                                                         token: config.deviceToken ?? "",
                                                         permit: pushPermit)
                self?.apiClient?.send(request: request) { [weak self, identifier, clusterId, geofenceId, source, lat, lon, pushPermit] result in
                    switch result {
                    case .success:
                        let now = Date()
                        self?.geofenceHistory.lastLat = lat
                        self?.geofenceHistory.lastLon = lon
                        if self?.geofenceHistory.eventHistory[identifier] == nil {
                            self?.geofenceHistory.eventHistory[identifier] = [Date: DengageGeofenceEvent]()
                        }
                        let event = DengageGeofenceEvent(identifier: identifier,
                                                         cid: clusterId,
                                                         geoid: geofenceId,
                                                         type: source == .geofenceEnter ? "enter": "exit",
                                                         et: now,
                                                         pushPermit: pushPermit)
                        self?.geofenceHistory.eventHistory[identifier]?[now] = event
                        self?.updateGeofenceHistory()
                        
                        if let history = self?.geofenceHistory {
                            DengageGeofenceState.saveGeofenceHistory(history)
                        }
                        Logger.log(message: "GeofenceEventSignalRequest sent successfully.")
                    case .failure(let error):
                        Logger.log(message: "GeofenceEventSignalRequest_ERROR", argument: error.localizedDescription)
                    }
                    self?.sending = false
                    self?.updateTracking(location: location, fromInitialize: false)
                }
            }
            
            
        } else {
            sending = false
            fetchGeofences()
        }
    }
    
    func fetchGeofences() {
        if fetching {
            return
        }
        fetching = true
        if let config = config {
            
            if GEOFENCE_MAX_FETCH_INTERVAL > (Date().timeIntervalSince1970 - geofenceHistory.lastFetchTime.timeIntervalSince1970) {
                fetching = false
                return
            }
            
            let lat = lManager.location?.coordinate.latitude ?? geofenceHistory.lastLat
            let lon = lManager.location?.coordinate.longitude ?? geofenceHistory.lastLon
            
            let request = GetGeofencesRequest(integrationKey: config.integrationKey,
                                              latitude: lat,
                                              longitude: lon)
            
            apiClient?.send(request: request) { [weak self, lat, lon] result in
                switch result {
                case .success(let response):
                    
                    let now = Date()
                    self?.geofenceHistory.lastLat = lat
                    self?.geofenceHistory.lastLon = lon
                    self?.geofenceHistory.lastFetchTime = now
                    
                    if self?.geofenceHistory.fetchHistory[now] == nil {
                        self?.geofenceHistory.fetchHistory[now] = [DengageGeofenceCluster]()
                    }
                    self?.geofenceHistory.fetchHistory[now]?.append(contentsOf: response)
                    self?.replaceSyncedGeofences(response)
                    self?.updateGeofenceHistory()
                    
                    if let history = self?.geofenceHistory {
                        DengageGeofenceState.saveGeofenceHistory(history)
                    }
                case .failure(let error):
                    Logger.log(message: "GetGeofencesRequest_ERROR", argument: error.localizedDescription)
                }
                self?.fetching = false
                self?.updateTracking(location: self?.lManager.location, fromInitialize: false)
            }
        }
    }
    
    func requestLocationPermissions() {
        var status: CLAuthorizationStatus = .notDetermined
        if #available(iOS 14.0, *) {
            status = lManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        if #available(iOS 13.4, *) {
            if status == .notDetermined {
                lManager.requestWhenInUseAuthorization()
            } else if status == .authorizedWhenInUse {
                lManager.requestAlwaysAuthorization()
            }
        } else {
            lManager.requestAlwaysAuthorization()
        }
    }
    
    func updateGeofenceHistory() {
        if geofenceHistory.fetchHistory.count > GEOFENCE_FETCH_HISTORY_MAX_COUNT {
            let ascendingKeys = Array(geofenceHistory.fetchHistory.keys).sorted(by: { $0 < $1 })
            let keysToBeDeleted = ascendingKeys[0..<(ascendingKeys.count - GEOFENCE_FETCH_HISTORY_MAX_COUNT)]
            for key in keysToBeDeleted {
                geofenceHistory.fetchHistory[key] = nil
            }
        }
        
        var timeIdDic = [Date: String]()
        
        for (identifier, eventDic) in geofenceHistory.eventHistory {
            for (date, _) in eventDic {
                timeIdDic[date] = identifier
            }
        }
        
        if timeIdDic.count > GEOFENCE_EVENT_HISTORY_MAX_COUNT {
            let ascKeys = Array(timeIdDic.keys).sorted(by: { $0 < $1 })
            let keysToBeDeleted = ascKeys[0..<(ascKeys.count - GEOFENCE_EVENT_HISTORY_MAX_COUNT)]
            for key in keysToBeDeleted {
                if let id = timeIdDic[key] {
                    geofenceHistory.eventHistory[id] = nil
                }
            }
        }
        
    }
    
}

// MARK: - CLLocationManagerDelegate
extension DengageGeofenceManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            handleLocation(location, source: .backgroundLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //Logger.log(message: "locationManager_didEnterRegion: \(region.identifier)")
        guard let location = manager.location, region.identifier.hasPrefix(kIdentifierPrefix) else {
            return
        }
        handleLocation(location, source: .geofenceEnter, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        /*
        guard let location = manager.location, region.identifier.hasPrefix(kIdentifierPrefix) else {
            return
        }
        handleLocation(location, source: .geofenceExit, region: region)
         */
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.log(message: "locationManager_didFailWithError_ERROR", argument: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Logger.log(message: "didChangeAuthorization: \(status)")
        startTracking(options: tOptions, fromInitialize: true)
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Logger.log(message: "locationManagerDidChangeAuthorization: \(manager.authorizationStatus)")
        startTracking(options: tOptions, fromInitialize: true)
    }
    
}

// MARK: - Push Permission

extension DengageGeofenceManager {
    
    func checkNotificationPermit(completion: @escaping (Bool) -> Void)  {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            switch permission.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
            case .notDetermined, .denied, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        })
    }
}

protocol DengageGeofenceManagerInterface: AnyObject {
    func requestLocationPermissions()
    func stopGeofence()
}

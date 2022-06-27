import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func distanceSquared(_ cor2: CLLocationCoordinate2D) -> Double {
        let cor1 = self
        let radius = 0.0174532925199433
        let nauticalMilesPerLatitude = 60.00721
        let metersPerNauticalMile = 1852.00 // metersPerNauticalMile bu kaldırılabilir
        let nauticalMilesPerLongitudeDividedByTwo = 30.053965
        let yDistance = (cor2.latitude - cor1.latitude) * nauticalMilesPerLatitude
        let xDistance = (cos(cor1.latitude * radius) + cos(cor2.latitude * radius))
        * (cor2.longitude - cor1.longitude) * nauticalMilesPerLongitudeDividedByTwo
        let res = ((yDistance * yDistance) + (xDistance * xDistance))
        * (metersPerNauticalMile * metersPerNauticalMile)
        return res
    }
}

class DengageGeofenceState {
    
    static func setGeofenceEnabled(_ geofenceEnabled: Bool){
        DengageLocalStorage.shared.set(value: geofenceEnabled, for: .geofenceEnabled)
    }
    
    static func getGeofenceEnabled() -> Bool{
        return DengageLocalStorage.shared.value(for: .geofenceEnabled) as? Bool ?? true
    }
    
    static func validLocation(_ location: CLLocation) -> Bool {
        let latitudeValid = location.coordinate.latitude > -90 && location.coordinate.latitude < 90
        let longitudeValid = location.coordinate.longitude > -180 && location.coordinate.latitude < 180
        let horizontalAccuracyValid = location.horizontalAccuracy > 0
        return latitudeValid && longitudeValid && horizontalAccuracyValid
    }
    
    private static func saveLocation(_ location: CLLocation, key: DengageLocalStorage.Key) {
        let encoder = JSONEncoder()
        let dLoc = DengageCLLocation(location: location, mocked: false)
        if let dLocData = try? encoder.encode(dLoc) {
            DengageLocalStorage.shared.set(value: dLocData, for: key)
        }
    }
    
    private static func getLocation(key: DengageLocalStorage.Key) -> CLLocation? {
        if let data = DengageLocalStorage.shared.value(for: key) as? Data {
            let decoder = JSONDecoder()
            if let dLoc = try? decoder.decode(DengageCLLocation.self, from: data) {
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(dLoc.latitude), CLLocationDegrees(dLoc.longitude))
                return CLLocation(
                    coordinate: coordinate,
                    altitude: CLLocationDistance(dLoc.altitude),
                    horizontalAccuracy: CLLocationAccuracy(dLoc.horizontalAccuracy),
                    verticalAccuracy: CLLocationAccuracy(dLoc.verticalAccuracy),
                    timestamp: dLoc.timestamp)
            }
        }
        return nil
    }
    
    static func getLastLocation() -> CLLocation? {
        guard let loc = getLocation(key: .geofenceLastLocation), validLocation(loc) else {
            return nil
        }
        return loc
    }
    
    static func setLastLocation(_ loc: CLLocation) {
        if validLocation(loc) {
            saveLocation(loc, key: .geofenceLastLocation)
        }
    }
    
    static func getLastMovedLocation() -> CLLocation? {
        guard let loc = getLocation(key: .geofenceLastMovedLocation), validLocation(loc) else {
            return nil
        }
        return loc
    }
    
    static func setLastMovedLocation(_ loc: CLLocation) {
        if validLocation(loc) {
            saveLocation(loc, key: .geofenceLastMovedLocation)
        }
    }
    
    static func getLastMovedAt() -> Date? {
        return DengageLocalStorage.shared.value(for: .geofenceLastMovedAt) as? Date
    }
    
    static func setLastMovedAt(_ lastMovedAt: Date) {
        DengageLocalStorage.shared.set(value: lastMovedAt, for: .geofenceLastMovedAt)
    }
    
    static func getStopped() -> Bool {
        return DengageLocalStorage.shared.value(for: .geofenceStopped) as? Bool ?? false
    }
    
    static func setStopped(_ stopped: Bool) {
        DengageLocalStorage.shared.set(value: stopped, for: .geofenceStopped)
    }
    
    static func getLastSentAt() -> Date? {
        return DengageLocalStorage.shared.value(for: .geofenceLastSentAt) as? Date
    }
    
    static func setLastSentAt() {
        DengageLocalStorage.shared.set(value: Date(), for: .geofenceLastSentAt)
    }
    
    static func getLastFailedStoppedLocation() -> CLLocation? {
        guard let loc = getLocation(key: .geofenceLastFailedStoppedLocation), validLocation(loc) else {
            return nil
        }
        return loc
    }
    
    static func setLastFailedStoppedLocation(_ loc: CLLocation?) {
        if let loc = loc, validLocation(loc) {
            saveLocation(loc, key: .geofenceLastFailedStoppedLocation)
        }
    }
    
    static func saveGeofenceHistory(_ history: DengageGeofenceHistory) {
        if let historyData = try? JSONEncoder().encode(history) {
            DengageLocalStorage.shared.set(value: historyData, for: .geofenceHistory)
        }
    }
    
    static func getGeofenceHistory() -> DengageGeofenceHistory {
        if let geofenceHistoryData = DengageLocalStorage.shared.value(for: .geofenceHistory) as? Data {
            if let geofenceHistory = try? JSONDecoder().decode(DengageGeofenceHistory.self,from: geofenceHistoryData) {
                return geofenceHistory
            }
        }
        return DengageGeofenceHistory()
    }
    
    
    static func locationAuthorizationStatus() -> CLAuthorizationStatus {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        case .authorizedAlways:
            return .authorizedAlways
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        default:
            return .notDetermined
        }
    }
    
}

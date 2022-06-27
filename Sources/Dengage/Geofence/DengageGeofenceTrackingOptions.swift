import Foundation
import CoreLocation

@objc public class DengageGeofenceTrackingOptions: NSObject {
    var desiredStoppedUpdateInterval = 0
    var desiredMovingUpdateInterval = 150
    var desiredSyncInterval = 20
    var desiredAccuracy = DengageGeofenceOptionsDesiredAccuracy.medium
    var stopDuration = 140
    var stopDistance = 70
    var startTrackingAfter: Date?
    var stopTrackingAfter: Date?
    var replay = DengageGeofenceTrackingOptionsReplay.none
    var syncLocations = DengageGeofenceTrackingOptionsSyncLocations.syncAll
    var showBlueBar = false
    var useStoppedGeofence = true
    var stoppedGeofenceRadius = 100
    var useMovingGeofence = false
    var movingGeofenceRadius = 0
    var syncGeofences = true
    var useSignificantLocationChanges = true
    
    var desiredCLLocationAccuracy: CLLocationAccuracy {
        if desiredAccuracy == .medium {
            return kCLLocationAccuracyHundredMeters
        } else if desiredAccuracy == .high {
            return kCLLocationAccuracyBest
        } else {
            return kCLLocationAccuracyKilometer
        }
    }
    
    var locationBackgroundMode: Bool {
        let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String]
        return backgroundModes != nil && backgroundModes?.contains("location") ?? false
    }
    
}

enum DengageGeofenceOptionsDesiredAccuracy: Int {
    case high
    case medium
    case low
}

enum DengageGeofenceTrackingOptionsReplay: Int {
    case stops
    case none
}

enum DengageGeofenceTrackingOptionsSyncLocations: Int {
    case syncAll
    case syncStopsAndExits
    case syncNone
}

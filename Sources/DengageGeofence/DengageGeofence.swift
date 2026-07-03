//
//  DengageGeofence.swift
//  DengageGeofence
//
//  Created by Egemen Gülkılık on 17.09.2024.
//

import CoreLocation
import UIKit
import Dengage

@objc(DengageGeofence)
public class DengageGeofence: NSObject {

    /// Enter olayında tetiklenen host hook'u (v2 engine tarafından çağrılır).
    @objc public static var geofenceInterceptor: DengageGeofenceInterceptor?

    /// Geofence takibini başlatır. Artık yeni Geofence Engine (v2) kullanılır;
    /// eski `DengageGeofenceManager` (v1) devre dışıdır. `geofenceEnabled` + izin kontrolü engine içinde yapılır.
    @objc public static func startGeofence() {
        DengageGeofenceEngine.shared.start()
    }

    @objc public static func stopGeofence() {
        DengageGeofenceEngine.shared.stop()
    }

    @objc public static func requestLocationPermissions() {
        DengageGeofenceEngine.shared.requestLocationPermissions()
    }
}

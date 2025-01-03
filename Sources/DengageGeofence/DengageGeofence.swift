//
//  DengageGeofence.swift
//  DengageGeofence
//
//  Created by Egemen Gülkılık on 17.09.2024.
//

import CoreLocation
import UIKit

public class DengageGeofence {

    private static let geofenceManager = DengageGeofenceManager()


    public static func startGeofence() {
        geofenceManager.startTracking(options: DengageGeofenceTrackingOptions(), fromInitialize: true)
    }

    public static func stopGeofence() {
        geofenceManager.stopGeofence()
    }

    public static func requestLocationPermissions() {
        geofenceManager.requestLocationPermissions()
    }
}

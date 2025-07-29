//
//  DengageGeofence.swift
//  DengageGeofence
//
//  Created by Egemen Gülkılık on 17.09.2024.
//

import CoreLocation
import UIKit

@objc(DengageGeofence)
public class DengageGeofence: NSObject {

    private static let geofenceManager = DengageGeofenceManager()


    @objc public static func startGeofence() {
        geofenceManager.startTracking(options: DengageGeofenceTrackingOptions(), fromInitialize: true)
    }

    @objc public static func stopGeofence() {
        geofenceManager.stopGeofence()
    }

    @objc public static func requestLocationPermissions() {
        geofenceManager.requestLocationPermissions()
    }
}

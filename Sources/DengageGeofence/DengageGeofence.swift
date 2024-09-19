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


    static func startGeofence() {
        //geofenceManager.startTracking()
    }

    public static func stopGeofence() {
        geofenceManager.stopGeofence()
    }

    public static func requestLocationPermissions() {
        geofenceManager.requestLocationPermissions()
    }
}

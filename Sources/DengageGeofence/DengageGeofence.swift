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

    private static let geofenceManager = DengageGeofenceManager()


    @objc public static func startGeofence() {
        if let sdkParams = Dengage.getSdkParameters(), sdkParams.geofenceEnabled {
            geofenceManager.startTracking(options: DengageGeofenceTrackingOptions(), fromInitialize: true)
        } else {
            stopGeofence()
        }
    }

    @objc public static func stopGeofence() {
        geofenceManager.stopGeofence()
    }

    @objc public static func requestLocationPermissions() {
        geofenceManager.requestLocationPermissions()
    }
}

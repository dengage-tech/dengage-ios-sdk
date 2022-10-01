import Foundation

public enum DengageLocationSource: Int {
    case foregroundLocation
    case backgroundLocation
    case manualLocation
    case geofenceEnter
    case geofenceExit
    case mockLocation
    case unknown
}

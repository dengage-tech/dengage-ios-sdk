import Foundation

@objc public protocol DengageGeofenceInterceptor: AnyObject {
    func onGeofenceEnter(latitude: Double,
                         longitude: Double,
                         radius: Double,
                         clusterId: Int,
                         clusterName: String?,
                         geofenceItemId: Int,
                         geofenceItemName: String?)
}

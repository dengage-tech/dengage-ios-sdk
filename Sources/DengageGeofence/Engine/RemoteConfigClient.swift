import Foundation
import Dengage

/// Geofence tuning config'ini merkezi `SdkParameters.geofence` bloğundan okur ve clamp eder
/// (contract §4). Sync response'ta tuning yer almaz; config buradan gelir.
final class RemoteConfigClient {

    func config() -> GeofenceConfiguration {
        (Dengage.getSdkParameters()?.geofence ?? GeofenceConfiguration()).clamped()
    }

    func geofenceEnabled() -> Bool {
        Dengage.getSdkParameters()?.geofenceEnabled ?? true
    }
}

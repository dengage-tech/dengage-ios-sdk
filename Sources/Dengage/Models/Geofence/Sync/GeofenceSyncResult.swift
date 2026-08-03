import Foundation

/// `DengageNetworking.sendGeofenceSync` sonucu (contract §1).
public enum GeofenceSyncResult {
    /// 200 — yeni payload + (varsa) ETag.
    case updated(GeofenceSyncResponse, etag: String?)
    /// 304 — ETag eşleşti, cihaz mevcut cache'ini kullanır.
    case notModified
}

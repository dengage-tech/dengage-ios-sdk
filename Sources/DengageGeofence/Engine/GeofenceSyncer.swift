import Foundation
import Dengage

/// `GET /geofences/sync` çağrısı + ETag yönetimi + storage persist (contract §1, doc 21 §6.5).
/// 304 alınırsa mevcut cache korunur.
final class GeofenceSyncer {

    enum SyncResult {
        case updated([EngineFence])
        case notModified
        case error(Error?)
        case noSubscription
    }

    private let fenceRepository: FenceRepository
    private let syncMetadata: SyncMetadataRepository

    init(fenceRepository: FenceRepository, syncMetadata: SyncMetadataRepository) {
        self.fenceRepository = fenceRepository
        self.syncMetadata = syncMetadata
    }

    func sync(lat: Double?, lon: Double?, completion: @escaping (SyncResult) -> Void) {
        guard let subscription = EngineSubscription.current(), let apiClient = Dengage.dengage?.apiClient else {
            completion(.noSubscription); return
        }

        let request = GeofenceSyncRequest(
            integrationKey: subscription.integrationKey,
            deviceId: subscription.deviceId,
            contactKey: subscription.contactKey,
            latitude: lat,
            longitude: lon,
            ifNoneMatch: syncMetadata.lastETag
        )

        apiClient.sendGeofenceSync(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(.notModified):
                Logger.log(message: "GeofenceSyncer -> 304 Not Modified, keeping cache")
                self.syncMetadata.lastSyncedAt = Date().timeIntervalSince1970
                completion(.notModified)
            case .success(.updated(let response, let etag)):
                let fences = response.geofences.map { EngineFence.from($0) }
                self.fenceRepository.save(fences)
                self.syncMetadata.lastETag = etag ?? response.etag
                self.syncMetadata.lastSyncedAt = Date().timeIntervalSince1970
                Logger.log(message: "GeofenceSyncer -> synced \(fences.count) fences")
                completion(.updated(fences))
            case .failure(let error):
                Logger.log(message: "GeofenceSyncer_ERROR", argument: error.localizedDescription)
                GeofenceDebugLog.error("Geofence sync failed", context: ["error": error.localizedDescription])
                completion(.error(error))
            }
        }
    }
}

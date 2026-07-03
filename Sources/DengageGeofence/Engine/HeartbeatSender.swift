import Foundation
import CoreLocation
import Dengage

/// `POST /devices/heartbeat` — cihaz konumu raporlama (contract §2).
/// `heartbeatIntervalMinutes`'e göre throttle edilir.
final class HeartbeatSender {

    private let syncMetadata: SyncMetadataRepository

    init(syncMetadata: SyncMetadataRepository) {
        self.syncMetadata = syncMetadata
    }

    func maybeSend(location: CLLocation, intervalMinutes: Int, force: Bool = false) {
        let now = Date().timeIntervalSince1970
        let last = syncMetadata.lastHeartbeatAt ?? 0
        if !force, (now - last) < Double(intervalMinutes * 60) { return }

        guard let subscription = EngineSubscription.current(), let apiClient = Dengage.dengage?.apiClient else { return }

        let request = DeviceHeartbeatRequest(
            integrationKey: subscription.integrationKey,
            deviceId: subscription.deviceId,
            contactKey: subscription.contactKey,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracyM: location.horizontalAccuracy > 0 ? location.horizontalAccuracy : nil,
            capturedAt: location.timestamp
        )

        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success:
                self?.syncMetadata.lastHeartbeatAt = now
                Logger.log(message: "HeartbeatSender -> sent heartbeat")
            case .failure(let error):
                Logger.log(message: "HeartbeatSender_ERROR", argument: error.localizedDescription)
            }
        }
    }
}

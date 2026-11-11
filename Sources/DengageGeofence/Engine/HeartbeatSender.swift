import Foundation
import CoreLocation
import Dengage

/// `POST /devices/heartbeat` — cihaz konumu raporlama (contract §2).
/// `heartbeatIntervalMinutes`'e göre throttle edilir.
final class HeartbeatSender {

    /// İsteği gönderir ve sonucu bildirir. Testler sahte bir transport verebilsin diye soyutlanmış.
    typealias Transport = (DeviceHeartbeatRequest, @escaping (Result<Void, Error>) -> Void) -> Void

    /// force=true heartbeat'leri arası asgari süre — contract §4'teki en kısa interval (15 dk).
    private static let minForceGap: TimeInterval = 15 * 60

    private let syncMetadata: SyncMetadataRepository
    private let subscriptionProvider: () -> EngineSubscription?
    private let transportProvider: () -> Transport?
    /// Interval kontrolü + slot rezervasyonunu eşzamanlı `maybeSend` çağrılarına karşı korur.
    private let lock = NSLock()

    init(syncMetadata: SyncMetadataRepository,
         subscriptionProvider: @escaping () -> EngineSubscription? = EngineSubscription.current,
         transportProvider: @escaping () -> Transport? = HeartbeatSender.dengageTransport) {
        self.syncMetadata = syncMetadata
        self.subscriptionProvider = subscriptionProvider
        self.transportProvider = transportProvider
    }

    /// Dengage API client üzerinden gönderim; SDK henüz init olmadıysa nil.
    private static func dengageTransport() -> Transport? {
        guard let apiClient = Dengage.dengage?.apiClient else { return nil }
        return { request, completion in
            apiClient.send(request: request) { result in completion(result.map { _ in () }) }
        }
    }

    /// Interval dolduysa heartbeat gönderir. `force` true ise interval yerine `minForceGap` tabanı
    /// uygulanır: force kanalları (start / forceResync / silent push) kümelenince ya da periyodik
    /// tetiklenince heartbeat hacmini çoğaltmasın.
    func maybeSend(location: CLLocation, intervalMinutes: Int, force: Bool = false) {
        guard let subscription = subscriptionProvider(), let transport = transportProvider() else { return }

        let now = Date().timeIntervalSince1970
        // Kontrol + rezervasyon atomik: movement (workQueue) ve sync completion aynı anda buraya
        // düşebilir. lastHeartbeatAt yalnızca response'ta yazıldığında ikisi de eski değeri okuyup
        // gönderiyordu (aynı saniyede çift heartbeat).
        let minGap = force ? Self.minForceGap : Double(intervalMinutes * 60)
        lock.lock()
        let previous = syncMetadata.lastHeartbeatAt
        guard now - (previous ?? 0) >= minGap else { lock.unlock(); return }
        syncMetadata.lastHeartbeatAt = now
        lock.unlock()

        let request = DeviceHeartbeatRequest(
            integrationKey: subscription.integrationKey,
            deviceId: subscription.deviceId,
            contactKey: subscription.contactKey,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracyM: location.horizontalAccuracy > 0 ? location.horizontalAccuracy : nil,
            capturedAt: location.timestamp
        )

        transport(request) { [weak self] result in
            switch result {
            case .success:
                Logger.log(message: "HeartbeatSender -> sent heartbeat")
            case .failure(let error):
                Logger.log(message: "HeartbeatSender_ERROR", argument: error.localizedDescription)
                GeofenceDebugLog.error("Geofence heartbeat failed", context: ["error": error.localizedDescription])
                self?.releaseReservation(reservedAt: now, previous: previous)
            }
        }
    }

    /// Başarısız gönderimde rezervasyonu geri alır ki sonraki tetikleyici tam interval beklemeden yeniden denesin.
    private func releaseReservation(reservedAt: TimeInterval, previous: TimeInterval?) {
        lock.lock(); defer { lock.unlock() }
        if syncMetadata.lastHeartbeatAt == reservedAt { syncMetadata.lastHeartbeatAt = previous }
    }
}

import Foundation
import Dengage

/// Offline kuyruktaki event'leri online olunca server'a flush eder (contract §3, doc 21 §6.5).
/// Başarılı gönderim sonrası kuyruktan ack'lenir; `source = replay` ile gönderilir.
final class EventQueueFlusher {

    private let eventQueue: EventQueueRepository

    init(eventQueue: EventQueueRepository) {
        self.eventQueue = eventQueue
    }

    /// Kuyruğu sırayla flush eder; bir gönderim başarısız olursa kalanı sonraki flush'a bırakır.
    /// [completion] tüm gönderimler bittiğinde çağrılır (background task assertion'ı için).
    func flush(batchSize: Int, completion: @escaping () -> Void = {}) {
        guard EngineSubscription.current() != nil else { completion(); return }
        let batch = eventQueue.dequeueBatch(maxSize: batchSize)
        guard !batch.isEmpty else { completion(); return }

        // Geçersiz (geofenceId <= 0) event'leri gönderme; kuyruktan temizle.
        // (Eski geofenceId alan uyumsuzluğundan kalan bayat replay event'leri buraya düşer.)
        let invalid = batch.filter { !$0.isValid }
        let valid = batch.filter { $0.isValid }
        if !invalid.isEmpty {
            eventQueue.ack(idempotencyKeys: invalid.map { $0.idempotencyKey })
            Logger.log(message: "EventQueueFlusher -> purged \(invalid.count) invalid (geofenceId<=0) events")
        }
        guard !valid.isEmpty else { completion(); return }
        sendSequentially(valid, index: 0, acked: [], completion: completion)
    }

    private func sendSequentially(_ batch: [QueuedEvent], index: Int, acked: [String], completion: @escaping () -> Void) {
        guard index < batch.count else {
            if !acked.isEmpty {
                eventQueue.ack(idempotencyKeys: acked)
                Logger.log(message: "EventQueueFlusher -> flushed \(acked.count) events")
            }
            completion()
            return
        }
        send(batch[index], source: .replay) { [weak self] success in
            guard let self = self else { completion(); return }
            if success {
                self.sendSequentially(batch, index: index + 1, acked: acked + [batch[index].idempotencyKey], completion: completion)
            } else {
                // network düştü: şimdiye dek başarılı olanları ack'le, kalanı bırak
                if !acked.isEmpty { self.eventQueue.ack(idempotencyKeys: acked) }
                completion()
            }
        }
    }

    /// Online tek event gönderimi; başarısızsa kuyruğa bırakmak çağırana aittir.
    func sendOnline(_ event: QueuedEvent, completion: @escaping (Bool) -> Void) {
        guard event.isValid else {
            Logger.log(message: "EventQueueFlusher -> dropping invalid event (geofenceId<=0)")
            completion(true) // geçersiz event kuyruğa bırakılmasın
            return
        }
        send(event, source: .online, completion: completion)
    }

    private func send(_ event: QueuedEvent, source: GeofenceEventSource, completion: @escaping (Bool) -> Void) {
        guard let subscription = EngineSubscription.current(), let apiClient = Dengage.dengage?.apiClient else {
            completion(false); return
        }
        let request = GeofenceEventSignalRequestV2(
            integrationKey: subscription.integrationKey,
            deviceId: subscription.deviceId,
            contactKey: subscription.contactKey,
            geofenceId: event.geofenceId,
            clusterId: event.clusterId,
            campaignId: event.campaignId,
            eventType: event.eventType,
            latitude: event.latitude,
            longitude: event.longitude,
            occurredAt: Date(timeIntervalSince1970: event.occurredAtMillis / 1000.0),
            ingestedAt: Date(),
            idempotencyKey: event.idempotencyKey,
            source: source
        )
        apiClient.send(request: request) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                // 409 (idempotent no-op) başarılı sayılır (contract §6)
                if case ServiceError.fail(let code) = error, code == 409 {
                    completion(true)
                } else {
                    Logger.log(message: "EventQueueFlusher_ERROR", argument: error.localizedDescription)
                    GeofenceDebugLog.error("Geofence event-signal send failed", context: [
                        "error": error.localizedDescription,
                        "geofenceId": String(event.geofenceId),
                        "eventType": event.eventType.rawValue,
                        "source": source.rawValue
                    ])
                    completion(false)
                }
            }
        }
    }
}

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
    func flush(batchSize: Int) {
        guard EngineSubscription.current() != nil else { return }
        let batch = eventQueue.dequeueBatch(maxSize: batchSize)
        guard !batch.isEmpty else { return }
        sendSequentially(batch, index: 0, acked: [])
    }

    private func sendSequentially(_ batch: [QueuedEvent], index: Int, acked: [String]) {
        guard index < batch.count else {
            if !acked.isEmpty {
                eventQueue.ack(idempotencyKeys: acked)
                Logger.log(message: "EventQueueFlusher -> flushed \(acked.count) events")
            }
            return
        }
        send(batch[index], source: .replay) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.sendSequentially(batch, index: index + 1, acked: acked + [batch[index].idempotencyKey])
            } else {
                // network düştü: şimdiye dek başarılı olanları ack'le, kalanı bırak
                if !acked.isEmpty { self.eventQueue.ack(idempotencyKeys: acked) }
            }
        }
    }

    /// Online tek event gönderimi; başarısızsa kuyruğa bırakmak çağırana aittir.
    func sendOnline(_ event: QueuedEvent, completion: @escaping (Bool) -> Void) {
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
                    completion(false)
                }
            }
        }
    }
}

import Foundation
import CoreLocation
import Dengage

/// OS region transition handler (doc 21 §6.5).
/// - Trigger type matcher: enter/exit/dwell → eşleşen kampanyalar gate'lenir.
/// - Online: event-signal v2 server'a gönderilir (server push'u orkestre eder).
/// - Offline: cache'lenen `offlinePushContent` ile local notification anında fire (K10) + event kuyruğa.
final class TriggerHandler {

    /// Teşhis geçmişinde tutulan azami kayıt sayısı.
    private let triggerHistoryMaxSize = 50

    private let fenceRepository: FenceRepository
    private let deviceStateRepository: DeviceStateRepository
    private let eventQueue: EventQueueRepository
    private let notificationFirer: LocalNotificationFirer
    private let eventFlusher: EventQueueFlusher
    private let triggerHistory: TriggerHistoryRepository
    private let offlineQueueMaxSize: () -> Int

    init(fenceRepository: FenceRepository,
         deviceStateRepository: DeviceStateRepository,
         eventQueue: EventQueueRepository,
         notificationFirer: LocalNotificationFirer,
         eventFlusher: EventQueueFlusher,
         triggerHistory: TriggerHistoryRepository,
         offlineQueueMaxSize: @escaping () -> Int) {
        self.fenceRepository = fenceRepository
        self.deviceStateRepository = deviceStateRepository
        self.eventQueue = eventQueue
        self.notificationFirer = notificationFirer
        self.eventFlusher = eventFlusher
        self.triggerHistory = triggerHistory
        self.offlineQueueMaxSize = offlineQueueMaxSize
    }

    /// [completion] async event-signal gönderimleri (+ flush) bittiğinde çağrılır; orchestrator
    /// bunu background task assertion'ının `end()`'ine bağlar ki iOS uygulamayı POST bitmeden
    /// suspend edip push'u geciktirmesin.
    /// [occurredAtMillis] verilmezse (`nil`) işlenme anı kullanılır. OS-kaynaklı geçişlerde çağıran
    /// fix zamanını geçer (OS beklettiyse geçmiş bir zaman); sentetik/dwell yollarında `nil` → şimdi.
    /// [fireCampaigns] `false` ise state güncellenir + geçmişe yazılır ama interceptor ve event-signal
    /// atlanır (state-only). Sentetik geçiş yalnızca movement/OS-wake'ten çıktığında kampanya tetikler;
    /// silent push / sync-only reeval "sessiz" kalır.
    /// [syntheticTransition] `true` → geçişi OS bildirmedi, SDK çıkarsadı (`ContainmentReconciler`);
    /// event-signal'de aynı adla raporlanır. OS callback'lerinde `false`.
    func handle(eventType: GeofenceEventType, requestId: String, location: CLLocation?, occurredAtMillis: Double? = nil, fireCampaigns: Bool = true, syntheticTransition: Bool = false, completion: @escaping () -> Void = {}) {
        guard let ids = EngineFence.parseRequestId(requestId),
              let fence = fenceRepository.findById(ids.geofenceId) else { completion(); return }
        guard fence.geofenceId > 0 else {
            Logger.log(message: "TriggerHandler -> skipping invalid fence (geofenceId<=0)")
            completion(); return
        }

        let now = Date().timeIntervalSince1970
        // occurredAt: geçişin gerçekleştiği an (fix zamanı). createdAt/state/dedup ise işlenme anı (`now`).
        let occurredMillis = occurredAtMillis ?? now * 1000.0

        // Edge-detection / dedup: OS aynı fiziksel geçiş için birden fazla callback verebilir
        // (didEnterRegion + register sonrası requestState→didDetermineState(.inside), vb.).
        // Sadece gerçek durum değişikliğinde tetikle; aksi halde çift event-signal gider.
        let previous = deviceStateRepository.getState(geofenceId: fence.geofenceId)
        if isDuplicateTransition(eventType: eventType, previous: previous) {
            Logger.log(message: "TriggerHandler -> duplicate \(eventType.rawValue) for fence \(fence.geofenceId), skipping")
            completion(); return
        }

        updateDeviceState(fence: fence, eventType: eventType, now: now)

        // Davranış paritesi: enter'da host interceptor'ı tetikle (v1 ile aynı hook).
        // state-only (fireCampaigns=false) modda interceptor da atlanır.
        if eventType == .enter, fireCampaigns {
            DispatchQueue.main.async {
                DengageGeofence.geofenceInterceptor?.onGeofenceEnter(
                    latitude: fence.latitude,
                    longitude: fence.longitude,
                    radius: fence.radiusM,
                    clusterId: fence.clusterId,
                    clusterName: nil,
                    geofenceItemId: fence.geofenceId,
                    geofenceItemName: fence.title
                )
            }
        }

        let matchingTrigger = trigger(for: eventType)
        let matchingCampaigns = fence.campaigns.filter { $0.triggerType == matchingTrigger }
        // Yatay doğruluk (metre); negatif = geçersiz → nil (heartbeat ile aynı kural).
        let accuracyM = location.flatMap { $0.horizontalAccuracy > 0 ? $0.horizontalAccuracy : nil }

        // Teşhis geçmişi: dedup'tan geçmiş, yani gerçekten olmuş geçiş. Kampanya eşleşmese de
        // kaydedilir — "geçiş oldu ama kampanya yoktu" ile "geçiş hiç olmadı" ayırt edilebilsin.
        triggerHistory.record(
            TriggerHistoryEntry(
                geofenceId: fence.geofenceId,
                clusterId: fence.clusterId,
                title: fence.title,
                eventType: eventType,
                occurredAtMillis: occurredMillis,
                accuracyM: accuracyM,
                campaignIds: matchingCampaigns.map { $0.campaignId },
                stateOnly: !fireCampaigns,
                syntheticTransition: syntheticTransition
            ),
            maxSize: triggerHistoryMaxSize
        )

        guard !matchingCampaigns.isEmpty else {
            Logger.log(message: "TriggerHandler -> no \(matchingTrigger.rawValue) campaign for fence \(fence.geofenceId)")
            completion(); return
        }

        // state-only: state güncellendi + geçmişe yazıldı; kampanya (interceptor + event-signal) atlanır.
        guard fireCampaigns else {
            Logger.log(message: "TriggerHandler -> state-only reconcile for fence \(fence.geofenceId), campaigns suppressed")
            completion(); return
        }

        let online = Reachability.isOnline()
        let lat = location?.coordinate.latitude ?? fence.latitude
        let lon = location?.coordinate.longitude ?? fence.longitude

        // Async gönderimleri grupla; hepsi (+ flush) bitince completion → background task end.
        let group = DispatchGroup()
        for campaign in matchingCampaigns {
            group.enter()
            dispatch(fence: fence, campaign: campaign, eventType: eventType, lat: lat, lon: lon,
                     accuracyM: accuracyM, occurredAtMillis: occurredMillis, createdAtMillis: now * 1000.0,
                     syntheticTransition: syntheticTransition, online: online) {
                group.leave()
            }
        }

        if online {
            group.enter()
            eventFlusher.flush(batchSize: offlineQueueMaxSize()) { group.leave() }
        }

        group.notify(queue: DispatchQueue.global(qos: .utility)) { completion() }
    }

    private func dispatch(fence: EngineFence,
                          campaign: SyncCampaign,
                          eventType: GeofenceEventType,
                          lat: Double, lon: Double,
                          accuracyM: Double?,
                          occurredAtMillis: Double,
                          createdAtMillis: Double,
                          syntheticTransition: Bool,
                          online: Bool,
                          completion: @escaping () -> Void) {
        let event = QueuedEvent(
            idempotencyKey: UUID().uuidString,
            geofenceId: fence.geofenceId,
            clusterId: fence.clusterId,
            campaignId: campaign.campaignId,
            eventType: eventType,
            latitude: lat,
            longitude: lon,
            accuracyM: accuracyM,
            occurredAtMillis: occurredAtMillis,
            createdAtMillis: createdAtMillis,
            syntheticTransition: syntheticTransition
        )

        if online {
            eventFlusher.sendOnline(event) { [weak self] success in
                defer { completion() }
                guard let self = self, !success else { return }
                Logger.log(message: "TriggerHandler -> online send failed, queueing \(event.idempotencyKey)")
                self.eventQueue.enqueue(event, maxSize: self.offlineQueueMaxSize())
            }
        } else {
            // Offline: local notification anında (K10) + event kuyruğa
            if let content = campaign.offlinePushContent {
                notificationFirer.fire(content: content, geofenceId: fence.geofenceId, campaignId: campaign.campaignId)
            }
            eventQueue.enqueue(event, maxSize: offlineQueueMaxSize())
            Logger.log(message: "TriggerHandler -> offline trigger queued \(event.idempotencyKey)")
            completion()
        }
    }

    private func updateDeviceState(fence: EngineFence, eventType: GeofenceEventType, now: TimeInterval) {
        switch eventType {
        case .enter:
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .inside,
                enteredAt: now, lastSeenAt: now, exitedAt: nil))
        case .dwell:
            // Dwell atıldı → `.dwellPending` = "inside ve bu ziyarette dwell zaten fire edildi".
            // Sonraki dwell callback'leri (biriken timer / OS tekrarı) böylece dedup edilir.
            let existing = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .dwellPending,
                enteredAt: existing?.enteredAt ?? now, lastSeenAt: now, exitedAt: nil))
        case .exit:
            let existing = deviceStateRepository.getState(geofenceId: fence.geofenceId)
            deviceStateRepository.setState(DeviceFenceState(
                geofenceId: fence.geofenceId, clusterId: fence.clusterId, state: .outside,
                enteredAt: existing?.enteredAt, lastSeenAt: now, exitedAt: now))
        }
    }

    /// Aynı geçiş için tekrarlanan OS callback'lerini ele; her tetik tipi ziyaret başına en fazla bir kez fire eder.
    /// State makinesi: enter→inside, dwell→dwellPending (dwell atıldı), exit→outside.
    /// - enter: cihaz zaten fence içindeyse (inside veya dwellPending) yinelenmedir.
    /// - dwell: yalnızca taze `inside` iken bir kez; `dwellPending` (zaten atıldı) veya outside/nil (bayat timer) → yinelenmedir.
    /// - exit: cihaz zaten dışarıdaysa (outside/nil) yinelenmedir.
    private func isDuplicateTransition(eventType: GeofenceEventType, previous: DeviceFenceState?) -> Bool {
        let state = previous?.state
        switch eventType {
        case .enter: return state == .inside || state == .dwellPending
        case .exit:  return previous == nil || state == .outside
        case .dwell: return state != .inside
        }
    }

    private func trigger(for eventType: GeofenceEventType) -> GeofenceTriggerType {
        switch eventType {
        case .enter: return .enter
        case .exit: return .exit
        case .dwell: return .dwell
        }
    }

    /// OS geçişinin fix zamanından `occurredAt` (epoch millis) türetir. OS event'i beklettiyse fix
    /// zamanı işlenme anından eskidir → sunucu bunun bayat olduğunu anlayıp push basmayabilir (doc 22 §3.1).
    /// `CLLocation.timestamp` "son bilinen fix"tir, region geçişinin tam anı değildir; yine de işlenme
    /// anından iyidir. Makul değilse (yok / gelecek / aşırı eski = bozuk saat) işlenme anına düşer.
    static func occurredAtMillis(fixTime: CLLocation?, now: TimeInterval = Date().timeIntervalSince1970) -> Double {
        let nowMillis = now * 1000.0
        guard let fixTime = fixTime else { return nowMillis }
        let fixMillis = fixTime.timestamp.timeIntervalSince1970 * 1000.0
        guard fixMillis > 0,
              fixMillis <= nowMillis + maxFutureSkewMillis,
              fixMillis >= nowMillis - maxFixAgeMillis else { return nowMillis }
        return fixMillis
    }

    /// Saat kayması toleransı: fix zamanı bu kadar gelecekteyse yok say.
    private static let maxFutureSkewMillis: Double = 60_000
    /// Fix zamanı bu kadar eskiyse bozuk kabul edip işlenme anına düş (Doze ~4 saat bekletmesini kapsar).
    private static let maxFixAgeMillis: Double = 48 * 60 * 60 * 1000

    /// Bir fence'in `dwell` kampanyası var mı (orchestrator dwell zamanlaması için)?
    func dwellMinutes(forFenceId geofenceId: Int) -> Int? {
        guard let fence = fenceRepository.findById(geofenceId) else { return nil }
        return fence.campaigns
            .filter { $0.triggerType == .dwell }
            .compactMap { $0.dwellMinutes }
            .max()
    }

    func isInside(geofenceId: Int) -> Bool {
        deviceStateRepository.getState(geofenceId: geofenceId)?.state == .inside
    }
}

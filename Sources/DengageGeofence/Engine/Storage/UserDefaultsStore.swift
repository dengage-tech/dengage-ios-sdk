import Foundation
import CoreLocation

/// Engine'in kendi UserDefaults suite'i. (Android engine'in ayrı SharedPreferences dosyası ile eşdeğer.)
final class EngineDefaults {
    static let suiteName = "com.dengage.geofence.engine"
    let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: EngineDefaults.suiteName) ?? .standard
    }

    func data(_ key: String) -> Data? { defaults.data(forKey: key) }
    func setData(_ key: String, _ value: Data?) { defaults.set(value, forKey: key) }
    func double(_ key: String) -> Double? {
        let v = defaults.double(forKey: key); return v > 0 ? v : nil
    }
    func setDouble(_ key: String, _ value: Double?) { defaults.set(value ?? 0, forKey: key) }
    func string(_ key: String) -> String? { defaults.string(forKey: key) }
    func setString(_ key: String, _ value: String?) { defaults.set(value, forKey: key) }
}

// MARK: - Fence repository

final class DefaultFenceRepository: FenceRepository {
    private let store: EngineDefaults
    private let key = "fences"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dengage.geofence.engine.fences")

    init(store: EngineDefaults) { self.store = store }

    func save(_ fences: [EngineFence]) {
        queue.sync {
            if let data = try? encoder.encode(fences) { store.setData(key, data) }
        }
    }

    func loadAll() -> [EngineFence] {
        queue.sync {
            guard let data = store.data(key),
                  let fences = try? decoder.decode([EngineFence].self, from: data) else { return [] }
            return fences
        }
    }

    func nearest(lat: Double, lon: Double, limit: Int, activeOnly: Bool) -> [EngineFence] {
        let origin = CLLocation(latitude: lat, longitude: lon)
        return loadAll()
            .filter { activeOnly ? $0.activeNow : true }
            .sorted {
                origin.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude)) <
                origin.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
            }
            .prefix(limit)
            .map { $0 }
    }

    func findById(_ geofenceId: Int) -> EngineFence? {
        loadAll().first { $0.geofenceId == geofenceId }
    }

    func clear() { queue.sync { store.setData(key, nil) } }
}

// MARK: - Device state repository

final class DefaultDeviceStateRepository: DeviceStateRepository {
    private let store: EngineDefaults
    private let key = "device_states"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dengage.geofence.engine.states")

    init(store: EngineDefaults) { self.store = store }

    private func load() -> [Int: DeviceFenceState] {
        guard let data = store.data(key),
              let states = try? decoder.decode([Int: DeviceFenceState].self, from: data) else { return [:] }
        return states
    }

    private func persist(_ states: [Int: DeviceFenceState]) {
        if let data = try? encoder.encode(states) { store.setData(key, data) }
    }

    func setState(_ state: DeviceFenceState) {
        queue.sync {
            var states = load()
            states[state.geofenceId] = state
            persist(states)
        }
    }

    func getState(geofenceId: Int) -> DeviceFenceState? {
        queue.sync { load()[geofenceId] }
    }

    func clear() { queue.sync { store.setData(key, nil) } }
}

// MARK: - Event queue repository

final class DefaultEventQueueRepository: EventQueueRepository {
    private let store: EngineDefaults
    private let key = "event_queue"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dengage.geofence.engine.events")

    init(store: EngineDefaults) { self.store = store }

    private func load() -> [QueuedEvent] {
        guard let data = store.data(key),
              let events = try? decoder.decode([QueuedEvent].self, from: data) else { return [] }
        return events
    }

    private func persist(_ events: [QueuedEvent]) {
        if let data = try? encoder.encode(events) { store.setData(key, data) }
    }

    func enqueue(_ event: QueuedEvent, maxSize: Int) {
        queue.sync {
            var events = load()
            // idempotencyKey dedup
            guard !events.contains(where: { $0.idempotencyKey == event.idempotencyKey }) else { return }
            events.append(event)
            // cap: en eski kayıtları düşür
            if events.count > maxSize {
                events.sort { $0.createdAtMillis < $1.createdAtMillis }
                events = Array(events.suffix(maxSize))
            }
            persist(events)
        }
    }

    func dequeueBatch(maxSize: Int) -> [QueuedEvent] {
        queue.sync {
            load().sorted { $0.createdAtMillis < $1.createdAtMillis }.prefix(maxSize).map { $0 }
        }
    }

    func ack(idempotencyKeys: [String]) {
        guard !idempotencyKeys.isEmpty else { return }
        queue.sync {
            let set = Set(idempotencyKeys)
            persist(load().filter { !set.contains($0.idempotencyKey) })
        }
    }

    func size() -> Int { queue.sync { load().count } }

    func clear() { queue.sync { store.setData(key, nil) } }
}

// MARK: - Trigger history repository

final class DefaultTriggerHistoryRepository: TriggerHistoryRepository {
    private let store: EngineDefaults
    private let key = "trigger_history"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dengage.geofence.engine.history")

    init(store: EngineDefaults) { self.store = store }

    private func load() -> [TriggerHistoryEntry] {
        guard let data = store.data(key),
              let entries = try? decoder.decode([TriggerHistoryEntry].self, from: data) else { return [] }
        return entries
    }

    func record(_ entry: TriggerHistoryEntry, maxSize: Int) {
        queue.sync {
            // En yeni başta; cap aşılınca en eskiler düşer.
            var entries = load()
            entries.insert(entry, at: 0)
            if entries.count > maxSize { entries = Array(entries.prefix(maxSize)) }
            if let data = try? encoder.encode(entries) { store.setData(key, data) }
        }
    }

    func recent(limit: Int) -> [TriggerHistoryEntry] {
        queue.sync { Array(load().prefix(limit)) }
    }

    func clear() { queue.sync { store.setData(key, nil) } }
}

// MARK: - Sync metadata repository

final class DefaultSyncMetadataRepository: SyncMetadataRepository {
    private let store: EngineDefaults
    init(store: EngineDefaults) { self.store = store }

    var lastETag: String? {
        get { store.string("etag") }
        set { store.setString("etag", newValue) }
    }
    var lastSyncedAt: Double? {
        get { store.double("synced_at") }
        set { store.setDouble("synced_at", newValue) }
    }
    var lastHeartbeatAt: Double? {
        get { store.double("heartbeat_at") }
        set { store.setDouble("heartbeat_at", newValue) }
    }
    var lastSilentPushAt: Double? {
        get { store.double("silent_push_at") }
        set { store.setDouble("silent_push_at", newValue) }
    }
    var wakeupPausedAt: Double? {
        get { store.double("wakeup_paused_at") }
        set { store.setDouble("wakeup_paused_at", newValue) }
    }
}

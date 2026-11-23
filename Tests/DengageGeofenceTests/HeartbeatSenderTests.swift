import XCTest
import CoreLocation
@testable import DengageGeofence
@testable import Dengage

final class HeartbeatSenderTests: XCTestCase {

    private var metadata: InMemorySyncMetadata!
    private var transport: FakeTransport!
    private var subscription: EngineSubscription?
    private var sender: HeartbeatSender!
    private let location = CLLocation(latitude: 41.0, longitude: 29.0)

    override func setUp() {
        super.setUp()
        metadata = InMemorySyncMetadata()
        transport = FakeTransport()
        subscription = EngineSubscription(integrationKey: "key", deviceId: "device", contactKey: nil, token: nil)
        sender = HeartbeatSender(
            syncMetadata: metadata,
            subscriptionProvider: { [unowned self] in self.subscription },
            transportProvider: { [unowned self] in self.transport.send }
        )
    }

    func testConcurrentCallsSendSingleHeartbeat() {
        // Completion'lar bekletiliyor (ağ çağrısı sürüyor): eski kodda hepsi eski lastHeartbeatAt'i okuyup gönderiyordu.
        DispatchQueue.concurrentPerform(iterations: 20) { _ in
            sender.maybeSend(location: location, intervalMinutes: 60)
        }

        XCTAssertEqual(transport.sentCount, 1)
    }

    func testSuccessfulSendBlocksNextCallWithinInterval() {
        sender.maybeSend(location: location, intervalMinutes: 60)
        transport.completeAll(with: .success(()))
        sender.maybeSend(location: location, intervalMinutes: 60)

        XCTAssertEqual(transport.sentCount, 1)
    }

    func testFailureRestoresPreviousTimestampSoNextCallRetries() {
        let previous = Date().timeIntervalSince1970 - 2 * 3600
        metadata.lastHeartbeatAt = previous

        sender.maybeSend(location: location, intervalMinutes: 60)
        transport.completeAll(with: .failure(URLError(.notConnectedToInternet)))
        XCTAssertEqual(metadata.lastHeartbeatAt, previous)

        sender.maybeSend(location: location, intervalMinutes: 60)
        XCTAssertEqual(transport.sentCount, 2)
    }

    func testForceWithinFloorIsSkipped() {
        metadata.lastHeartbeatAt = Date().timeIntervalSince1970 - 5 * 60

        sender.maybeSend(location: location, intervalMinutes: 60, force: true)

        XCTAssertEqual(transport.sentCount, 0)
    }

    func testForceAfterFloorSendsEvenWithinInterval() {
        metadata.lastHeartbeatAt = Date().timeIntervalSince1970 - 16 * 60

        sender.maybeSend(location: location, intervalMinutes: 60)
        XCTAssertEqual(transport.sentCount, 0)

        sender.maybeSend(location: location, intervalMinutes: 60, force: true)
        XCTAssertEqual(transport.sentCount, 1)
    }

    func testNoSubscriptionNeitherSendsNorReserves() {
        subscription = nil

        sender.maybeSend(location: location, intervalMinutes: 60)

        XCTAssertEqual(transport.sentCount, 0)
        XCTAssertNil(metadata.lastHeartbeatAt)
    }
}

private final class InMemorySyncMetadata: SyncMetadataRepository {
    var lastETag: String?
    var lastSyncedAt: Double?
    var lastHeartbeatAt: Double?
    var lastSilentPushAt: Double?
    var wakeupPausedAt: Double?
    var stoppedAt: Double?
}

/// Gönderimleri kaydeder; completion'ları test açıkça tetikleyene kadar bekletir.
private final class FakeTransport {
    private let lock = NSLock()
    private var pending: [(Result<Void, Error>) -> Void] = []
    private var count = 0

    var sentCount: Int {
        lock.lock(); defer { lock.unlock() }
        return count
    }

    func send(_ request: DeviceHeartbeatRequest, _ completion: @escaping (Result<Void, Error>) -> Void) {
        lock.lock(); defer { lock.unlock() }
        count += 1
        pending.append(completion)
    }

    func completeAll(with result: Result<Void, Error>) {
        lock.lock()
        let completions = pending
        pending = []
        lock.unlock()
        completions.forEach { $0(result) }
    }
}

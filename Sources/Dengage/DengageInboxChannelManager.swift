import Foundation

final class DengageInboxChannelManager {

    private let config: DengageConfiguration
    private let apiClient: DengageNetworking

    init(config: DengageConfiguration, service: DengageNetworking) {
        self.config = config
        self.apiClient = service
    }

    private func validatedRemoteConfig() -> (remoteConfig: GetSDKParamsResponse, accountName: String)? {
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              remoteConfig.inboxEnabled else {
            return nil
        }
        return (remoteConfig, accountName)
    }

    /// Fetches Inbox Channel messages from /api/inbox/getMessages.
    func getInboxChannelMessages(limit: Int = 20,
                                 completion: @escaping (Result<[DengageInboxChannelMessage], Error>) -> Void) {

        guard let (remoteConfig, accountName) = validatedRemoteConfig() else {
            completion(.success([]))
            return
        }

        let request = GetInboxChannelMessagesRequest(
            accountName: accountName,
            contactKey: contactKeyIfContact(),
            deviceId: config.applicationIdentifier,
            appId: remoteConfig.appId,
            limit: limit
        )

        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(let messages):
                let visible = self?.applyCachedState(to: messages) ?? messages
                completion(.success(visible))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Sends one or more Inbox Channel events (IM/OP/CL/DT) in a single bulk
    /// request to /api/inbox/events.
    func sendInboxChannelEvents(_ events: [DengageInboxChannelEvent],
                                completion: @escaping (Result<Void, Error>) -> Void) {

        guard let (remoteConfig, accountName) = validatedRemoteConfig() else {
            completion(.success(()))
            return
        }

        guard !events.isEmpty else {
            completion(.success(()))
            return
        }

        // Reflect the interaction locally before the request so the cache stays
        // in sync even though server processing is asynchronous.
        updateCache(for: events)

        let request = SendInboxChannelEventsRequest(
            accountName: accountName,
            contactKey: contactKeyIfContact(),
            deviceId: config.applicationIdentifier,
            appId: remoteConfig.appId,
            events: events
        )

        apiClient.send(request: request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// The contact key is only sent when the user is identified (type "c");
    /// anonymous users are resolved by device id only.
    private func contactKeyIfContact() -> String? {
        return config.contactKey.type == "c" ? config.contactKey.key : nil
    }

    /// Merges locally cached read/deleted state onto freshly fetched messages,
    /// refreshes the cache with the latest receiveDate and drops deleted ones.
    private func applyCachedState(to remoteMessages: [DengageInboxChannelMessage]) -> [DengageInboxChannelMessage] {
        guard !remoteMessages.isEmpty else { return remoteMessages }

        var caches = prunedCaches().reduce(into: [String: InboxChannelMessageCache]()) { $0[$1.id] = $1 }
        var result = [DengageInboxChannelMessage]()

        for var message in remoteMessages {
            if let cache = caches[message.id] {
                message.isRead = message.isRead || cache.isRead
                message.isDeleted = cache.isDeleted
            }
            caches[message.id] = InboxChannelMessageCache(
                id: message.id,
                isRead: message.isRead,
                isDeleted: message.isDeleted,
                receiveDate: message.data.receiveDate
            )
            if !message.isDeleted {
                result.append(message)
            }
        }

        DengageLocalStorage.shared.save(Array(caches.values))
        return result
    }

    /// Updates the persisted cache for the given events: open/click mark a message
    /// as read, delete marks it as deleted. Impression carries no state change.
    private func updateCache(for events: [DengageInboxChannelEvent]) {
        var caches = prunedCaches().reduce(into: [String: InboxChannelMessageCache]()) { $0[$1.id] = $1 }

        for event in events {
            let markRead = event.eventType == .open || event.eventType == .click
            let markDeleted = event.eventType == .delete
            if !markRead && !markDeleted { continue }

            if var existing = caches[event.messageId] {
                if markRead { existing.isRead = true }
                if markDeleted { existing.isDeleted = true }
                caches[event.messageId] = existing
            } else {
                caches[event.messageId] = InboxChannelMessageCache(
                    id: event.messageId,
                    isRead: markRead,
                    isDeleted: markDeleted,
                    receiveDate: nil
                )
            }
        }

        DengageLocalStorage.shared.save(Array(caches.values))
    }

    private func prunedCaches() -> [InboxChannelMessageCache] {
        let caches = DengageLocalStorage.shared.getInboxChannelMessages()
        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return caches
        }
        return caches.filter { cache in
            guard let receiveDateString = cache.receiveDate,
                  let receiveDate = Utilities.convertDate(to: receiveDateString) else {
                return true
            }
            return receiveDate >= oneWeekAgo
        }
    }
}

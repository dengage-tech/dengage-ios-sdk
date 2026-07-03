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

        apiClient.send(request: request) { result in
            switch result {
            case .success(let messages):
                completion(.success(messages))
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
}

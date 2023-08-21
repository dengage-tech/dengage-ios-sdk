import Foundation
final class DengageInboxManager: DengageInboxManagerInterface {
    
    var inboxMessages = [DengageMessage]()
    private let config: DengageConfiguration
    private let apiClient: DengageNetworking
    
    init(config: DengageConfiguration, service: DengageNetworking){
        self.config = config
        self.apiClient = service
    }
    
    func getInboxMessages(offset: Int,
                          limit: Int = 20,
                          completion: @escaping (Result<[DengageMessage], Error>) -> Void) {
        
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              remoteConfig.inboxEnabled else {
            completion(.success([]))
            return
        }
        
        let request = GetMessagesRequest(accountName: accountName,
                                         contactKey: config.contactKey.key,
                                         type: config.contactKey.type,
                                         offset: offset,
                                         limit: limit,
                                         deviceId: config.applicationIdentifier,
                                         appid: remoteConfig.appId ?? "")
        
        if offset == 0 && !inboxMessages.isEmpty && !config.shouldFetchFromAPI{
            completion(.success(inboxMessages))
        }else{
            apiClient.send(request: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.saveInitalInboxMessagesIfNeeded(request: request, messages: response)
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteInboxMessage(with id: String,
                            completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              remoteConfig.inboxEnabled else {
            completion(.success(()))
            return
        }
        
        let request = DeleteMessagesRequest(type: config.contactKey.type,
                                            deviceID: config.applicationIdentifier,
                                            accountName: accountName,
                                            contactKey: config.contactKey.key,
                                            id: id)
        let messages = inboxMessages.filter {$0.id != request.id}
        inboxMessages = messages
        apiClient.send(request: request) { result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setInboxMessageAsClicked(with id: String,
                                  completion: @escaping (Result<Void, Error>) -> Void) {
        guard let remoteConfig = config.remoteConfiguration,
              let accountName = remoteConfig.accountName,
              remoteConfig.inboxEnabled else {
            completion(.success(()))
            return
        }
        
        let request = MarkAsReadRequest(type: config.contactKey.type,
                                        deviceID: config.applicationIdentifier,
                                        accountName: accountName,
                                        contactKey: config.contactKey.key,
                                        id: id)
        markLocalMessageIfNeeded(with: request.id)
        apiClient.send(request: request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func saveInitalInboxMessagesIfNeeded(request:GetMessagesRequest, messages:[DengageMessage]) {
        guard request.offset == "0" else {return}
        inboxMessages = messages
        config.inboxLastFetchedDate = Date()
    }

    private func markLocalMessageIfNeeded(with id: String?) {
            
        guard let messageId = id else { return }
        
        for i in 0...inboxMessages.count - 1
        {
            var readedMessage = inboxMessages[i]

            if readedMessage.id == messageId
            {
                readedMessage.isClicked = true
                inboxMessages[i] = readedMessage
                break
            }
        }
    
//        let message = inboxMessages.first(where: {$0.id == messageId})
//        message?.isClicked = true
//        inboxMessages = inboxMessages.filter {$0.id != messageId}
//        guard let readedMessage = message else { return }
//        inboxMessages.append(readedMessage)
    }
}


protocol DengageInboxManagerInterface {
    func getInboxMessages(offset: Int,
                          limit: Int,
                          completion: @escaping (Result<[DengageMessage], Error>) -> Void)
    func deleteInboxMessage(with id: String,
                            completion: @escaping (Result<Void, Error>) -> Void)
    func setInboxMessageAsClicked(with id: String,
                                  completion: @escaping (Result<Void, Error>) -> Void)
    func saveInitalInboxMessagesIfNeeded(request:GetMessagesRequest, messages:[DengageMessage])
}

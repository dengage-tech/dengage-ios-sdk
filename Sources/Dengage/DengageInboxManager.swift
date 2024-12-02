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
                    config.inboxLastFetchedDate = Date()
                    if request.offset == "0" {
                        inboxMessages = response
                        updateInboxMessages(remoteInboxMessages: response)
                        
                    }
                    completion(.success(inboxMessages))
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
        
        if let message = inboxMessages.first(where: {$0.id == id}) {
            message.isDeleted = true
            updateInboxMessagesPrefs(inboxMessage: message)
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
        
        if let message = inboxMessages.first(where: {$0.id == id}) {
            message.isClicked = true
            updateInboxMessagesPrefs(inboxMessage: message)
        }
        
        let request = MarkAsReadRequest(type: config.contactKey.type,
                                        deviceID: config.applicationIdentifier,
                                        accountName: accountName,
                                        contactKey: config.contactKey.key,
                                        id: id)
        apiClient.send(request: request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

 
    
    private func updateInboxMessages(remoteInboxMessages: [DengageMessage]) {
        if remoteInboxMessages.isEmpty { return }
        let prefsInboxMessages = DengageLocalStorage.shared.getInboxMessages()
        if prefsInboxMessages.isEmpty { return }
        
        for i in 0..<remoteInboxMessages.count {
            let remoteInboxMessage = remoteInboxMessages[i]
            if let matchingPrefsMessage = prefsInboxMessages.first(where: { $0.id == remoteInboxMessage.id }) {
                remoteInboxMessages[i].isClicked = matchingPrefsMessage.isClicked
                remoteInboxMessages[i].isDeleted = matchingPrefsMessage.isDeleted
            }
        }

        inboxMessages = remoteInboxMessages.filter {
            return !$0.isDeleted
        }
    }
    
    private func updateInboxMessagesPrefs(inboxMessage: DengageMessage) {
        let prefsInboxMessages = DengageLocalStorage.shared.getInboxMessages()
        
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())

        var filteredPrefsInboxMessages = prefsInboxMessages.filter { message in
            guard let receiveDate = message.receiveDate else {
                return true
            }
            return receiveDate >= (oneWeekAgo!)
        }

        if let existingMessageIndex = filteredPrefsInboxMessages.firstIndex(where: { $0.id == inboxMessage.id }) {
            filteredPrefsInboxMessages[existingMessageIndex].isClicked = inboxMessage.isClicked
            filteredPrefsInboxMessages[existingMessageIndex].isDeleted = inboxMessage.isDeleted
        } else {
            let prefsInboxMessage = InboxMessageCache(id: inboxMessage.id, isClicked: inboxMessage.isClicked, isDeleted: inboxMessage.isDeleted, receiveDate: inboxMessage.receiveDate)
            
            filteredPrefsInboxMessages.append(prefsInboxMessage)
        }

        DengageLocalStorage.shared.save(filteredPrefsInboxMessages)
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
}

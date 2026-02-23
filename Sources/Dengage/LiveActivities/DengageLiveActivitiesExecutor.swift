import Foundation

fileprivate let OS_LIVE_ACTIVITIES_EXECUTOR_UPDATE_TOKENS_KEY = "liveActivitiesUpdateTokens"
fileprivate let OS_LIVE_ACTIVITIES_EXECUTOR_START_TOKENS_KEY = "liveActivitiesStartTokens"

/**
 A request cache keeps track of all the current update token or start token requests.  There can only be one request
 per DengageLiveActivityRequest.key, and each request has either been successfully sent to Dengage or hasn't.  Requests
 that have been sent to Dengage remain in the cache to avoid sending redundant requests, as the update/start
 token updates are called frequently with the same information.
 
 The cache is persisted to disk via the `cacheKey`, and items will remain in the cache until explicitly removed or
 it has existed past the `ttl` provided.
 
 WARNING: This cache is **not** thread safe, synchronization required!
 */
class RequestCache {
    var items: [String: DengageLiveActivityRequest]
    var cachedRequests: [String: CachedRequest] = [:]
    private var cacheKey: String
    private var ttl: TimeInterval
    weak var config: DengageConfiguration?
    
    func recreateRequests(with config: DengageConfiguration) {
        self.config = config
        var requests: [String: DengageLiveActivityRequest] = [:]
        
        for (key, cachedRequest) in cachedRequests {
            let request: DengageLiveActivityRequest?
            
            switch cachedRequest.requestType {
            case "SetUpdateToken":
                guard let token = cachedRequest.token else { continue }
                let req = DengageRequestSetUpdateToken(key: cachedRequest.key, token: token, activityType: cachedRequest.activityType ?? "", config: config)
                req.requestSuccessful = cachedRequest.requestSuccessful
                req.timestamp = cachedRequest.timestamp
                request = req
                
            case "SetStartToken":
                guard let token = cachedRequest.token else { continue }
                let req = DengageRequestSetStartToken(key: cachedRequest.key, token: token, config: config)
                req.requestSuccessful = cachedRequest.requestSuccessful
                req.timestamp = cachedRequest.timestamp
                request = req
                
            case "RemoveUpdateToken":
                let req = DengageRequestRemoveUpdateToken(key: cachedRequest.key, config: config)
                req.requestSuccessful = cachedRequest.requestSuccessful
                req.timestamp = cachedRequest.timestamp
                request = req
                
            case "RemoveStartToken":
                let req = DengageRequestRemoveStartToken(key: cachedRequest.key, config: config)
                req.requestSuccessful = cachedRequest.requestSuccessful
                req.timestamp = cachedRequest.timestamp
                request = req
                
            default:
                continue
            }
            
            if let request = request {
                requests[key] = request
            }
        }
        
        self.items = requests
    }

    init(cacheKey: String, ttl: TimeInterval) {
        self.cacheKey = cacheKey
        self.ttl = ttl
        
        // Get the storage key from cacheKey string
        guard let storageKey = DengageLocalStorage.Key(rawValue: cacheKey) else {
            self.items = [String: DengageLiveActivityRequest]()
            Logger.log(message: "Dengage.LiveActivities initialized token cache with invalid key: \(cacheKey)")
            return
        }
        
        let cached = DengageLocalStorage.shared.value(for: storageKey) as? Data
        if let cached = cached {
            do {
                let decoder = JSONDecoder()
                let cachedRequests = try decoder.decode([String: CachedRequest].self, from: cached)
                
                // Store cached requests - they will be recreated when config is available
                self.cachedRequests = cachedRequests
                // Items will be populated when recreateRequests is called
                self.items = [String: DengageLiveActivityRequest]()
            } catch {
                Logger.log(message: "Dengage.LiveActivities failed to decode cache: \(error.localizedDescription)")
                self.items = [String: DengageLiveActivityRequest]()
                self.cachedRequests = [:]
            }
        } else {
            self.items = [String: DengageLiveActivityRequest]()
            self.cachedRequests = [:]
        }
        Logger.log(message: "Dengage.LiveActivities initialized token cache \(self): \(items.count) items")
    }

    func add(_ request: DengageLiveActivityRequest) {
        self.items.updateValue(request, forKey: request.key)
        // Update cachedRequests as well
        let requestType: String
        let token: String?
        
        if let setUpdate = request as? DengageRequestSetUpdateToken {
            requestType = "SetUpdateToken"
            token = setUpdate.token
        } else if let setStart = request as? DengageRequestSetStartToken {
            requestType = "SetStartToken"
            token = setStart.token
        } else if request is DengageRequestRemoveUpdateToken {
            requestType = "RemoveUpdateToken"
            token = nil
        } else if request is DengageRequestRemoveStartToken {
            requestType = "RemoveStartToken"
            token = nil
        } else {
            self.save()
            return
        }
        
        let activityTypeValue: String?
        if let setUpdate = request as? DengageRequestSetUpdateToken {
            activityTypeValue = setUpdate.activityType
        } else {
            activityTypeValue = nil
        }

        self.cachedRequests[request.key] = CachedRequest(
            key: request.key,
            token: token,
            requestSuccessful: request.requestSuccessful,
            timestamp: request.timestamp,
            requestType: requestType,
            activityType: activityTypeValue
        )
        self.save()
    }

    func remove(_ request: DengageLiveActivityRequest) {
        if self.items.contains(where: { $0.key == request.key }) {
            self.items.removeValue(forKey: request.key)
            self.cachedRequests.removeValue(forKey: request.key)
            self.save()
        }
    }

    func markAllUnsuccessful() {
        for (key, request) in self.items {
            request.requestSuccessful = false
            // Update cached request
            if let cachedRequest = self.cachedRequests[key] {
                let updated = CachedRequest(
                    key: cachedRequest.key,
                    token: cachedRequest.token,
                    requestSuccessful: false,
                    timestamp: cachedRequest.timestamp,
                    requestType: cachedRequest.requestType,
                    activityType: cachedRequest.activityType
                )
                self.cachedRequests[key] = updated
            }
        }
        self.save()
    }

    func markSuccessful(_ request: DengageLiveActivityRequest) {
        if self.items.contains(where: { $0.key == request.key }) {
            // Save the appropriate cache with the updated request for this request key.
            if request.shouldForgetWhenSuccessful {
                self.items.removeValue(forKey: request.key)
                self.cachedRequests.removeValue(forKey: request.key)
            } else {
                request.requestSuccessful = true
                // Update cached request
                if let cachedRequest = self.cachedRequests[request.key] {
                    // Create new CachedRequest with updated requestSuccessful
                    let updated = CachedRequest(
                        key: cachedRequest.key,
                        token: cachedRequest.token,
                        requestSuccessful: true,
                        timestamp: cachedRequest.timestamp,
                        requestType: cachedRequest.requestType,
                        activityType: cachedRequest.activityType
                    )
                    self.cachedRequests[request.key] = updated
                }
            }
            self.save()
        }
    }

    private func save() {
        // before saving, remove any stale requests from the cache.
        let now = Date()
        var keysToRemove: [String] = []
        
        for (key, cachedRequest) in self.cachedRequests {
            if -cachedRequest.timestamp.timeIntervalSince(now) > ttl {
                Logger.log(message: "Dengage.LiveActivities remove stale request from token cache \(self): \(key)")
                keysToRemove.append(key)
            }
        }
        
        for key in keysToRemove {
            self.items.removeValue(forKey: key)
            self.cachedRequests.removeValue(forKey: key)
        }
        
        Logger.log(message: "Dengage.LiveActivities saving token cache \(self): \(cachedRequests.count) items")
        
        // Get the storage key from cacheKey string
        guard let storageKey = DengageLocalStorage.Key(rawValue: cacheKey) else {
            Logger.log(message: "Dengage.LiveActivities failed to save: invalid cache key: \(cacheKey)")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(cachedRequests)
            DengageLocalStorage.shared.set(value: encoded, for: storageKey)
        } catch {
            Logger.log(message: "Dengage.LiveActivities failed to encode cache: \(error.localizedDescription)")
            // If encoding fails, clear the cache to prevent future issues
            self.items.removeAll()
            self.cachedRequests.removeAll()
        }
    }
}

class UpdateRequestCache: RequestCache {
    // An update token should not last longer than 8 hours, we keep for 24 hours to be safe.
    static let OneDayInSeconds = TimeInterval(60 * 60 * 24)

    init() {
        super.init(cacheKey: OS_LIVE_ACTIVITIES_EXECUTOR_UPDATE_TOKENS_KEY, ttl: UpdateRequestCache.OneDayInSeconds)
    }
}

class StartRequestCache: RequestCache {
    // A start token will exist for a year in the cache.
    static let OneYearInSeconds = TimeInterval(60 * 60 * 24 * 365)

    init() {
        super.init(cacheKey: OS_LIVE_ACTIVITIES_EXECUTOR_START_TOKENS_KEY, ttl: StartRequestCache.OneYearInSeconds)
    }
}

class DengageLiveActivitiesExecutor {
    // The currently tracked update and start tokens (key) and their associated request (value). THESE ARE NOT THREAD SAFE
    let updateTokens: UpdateRequestCache = UpdateRequestCache()
    let startTokens: StartRequestCache = StartRequestCache()

    // The live activities request dispatch queue, serial.  This synchronizes access to `updateTokens` and `startTokens`.
    private var requestDispatch: DispatchQueue
    private var pollIntervalSeconds = 30.0
    
    private weak var apiClient: DengageNetworking?
    private weak var config: DengageConfiguration?

    init(requestDispatch: DispatchQueue, apiClient: DengageNetworking, config: DengageConfiguration) {
        self.requestDispatch = requestDispatch
        self.apiClient = apiClient
        self.config = config
    }

    func start() {
        Logger.log(message: "Dengage.LiveActivities starting executor")
        
        // Recreate requests from cache with config
        if let config = self.config {
            self.updateTokens.recreateRequests(with: config)
            self.startTokens.recreateRequests(with: config)
        }
        
        // drive a poll in case there are any outstanding requests in the cache.
        self.pollPendingRequests()
    }

    func append(_ request: DengageLiveActivityRequest) {
        self.requestDispatch.async { [weak self] in
            guard let self = self else { return }
            let cache = self.getCache(request)
            let existingRequest = cache.items[request.key]

            if existingRequest == nil || request.supersedes(existingRequest!) {
                cache.add(request)
                self.executeRequest(cache, request: request)
            } else {
                Logger.log(message: "Dengage.LiveActivities superseded request not saved/executed: \(request.key)")
            }
        }
    }

    private func pollPendingRequests() {
        Logger.log(message: "Dengage.LiveActivities pollPendingRequests")

        self.requestDispatch.asyncAfter(deadline: .now() + pollIntervalSeconds) { [weak self] in
            guard let self = self else { return }
            Logger.log(message: "Dengage.LiveActivities executing outstanding requests")

            // execute any request that hasn't been successfully executed.
            self.caches { cache in
                for request in cache.items.values.filter({ !$0.requestSuccessful }) {
                    self.executeRequest(cache, request: request)
                }
            }
            
            // Schedule next poll
            self.pollPendingRequests()
        }
    }

    private func caches(_ block: (RequestCache) -> Void) {
        block(self.startTokens)
        block(self.updateTokens)
    }

    private func getCache(_ request: DengageLiveActivityRequest) -> RequestCache {
        if request is DengageLiveActivityUpdateTokenRequest {
            return self.updateTokens
        } else if request is DengageLiveActivityStartTokenRequest {
            return self.startTokens
        }
        return self.updateTokens
    }

    private func executeRequest(_ cache: RequestCache, request: DengageLiveActivityRequest) {
        guard let apiClient = self.apiClient,
              let config = self.config else {
            Logger.log(message: "Dengage.LiveActivities cannot execute request: apiClient or config is nil")
            self.pollPendingRequests()
            return
        }
        
        // Re-inject config into request if needed
        if let setUpdateRequest = request as? DengageRequestSetUpdateToken,
           setUpdateRequest.config == nil {
            let newRequest = DengageRequestSetUpdateToken(key: setUpdateRequest.key, token: setUpdateRequest.token, activityType: setUpdateRequest.activityType, config: config)
            newRequest.requestSuccessful = setUpdateRequest.requestSuccessful
            newRequest.timestamp = setUpdateRequest.timestamp
            executeAPIRequest(cache, request: newRequest, apiRequest: newRequest)
            return
        }
        
        if let setStartRequest = request as? DengageRequestSetStartToken,
           setStartRequest.config == nil {
            let newRequest = DengageRequestSetStartToken(key: setStartRequest.key, token: setStartRequest.token, config: config)
            newRequest.requestSuccessful = setStartRequest.requestSuccessful
            newRequest.timestamp = setStartRequest.timestamp
            executeAPIRequest(cache, request: newRequest, apiRequest: newRequest)
            return
        }
        
        if let removeUpdateRequest = request as? DengageRequestRemoveUpdateToken,
           removeUpdateRequest.config == nil {
            let newRequest = DengageRequestRemoveUpdateToken(key: removeUpdateRequest.key, config: config)
            newRequest.requestSuccessful = removeUpdateRequest.requestSuccessful
            newRequest.timestamp = removeUpdateRequest.timestamp
            executeAPIRequest(cache, request: newRequest, apiRequest: newRequest)
            return
        }
        
        if let removeStartRequest = request as? DengageRequestRemoveStartToken,
           removeStartRequest.config == nil {
            let newRequest = DengageRequestRemoveStartToken(key: removeStartRequest.key, config: config)
            newRequest.requestSuccessful = removeStartRequest.requestSuccessful
            newRequest.timestamp = removeStartRequest.timestamp
            executeAPIRequest(cache, request: newRequest, apiRequest: newRequest)
            return
        }

        if !request.prepareForExecution() {
            return
        }

        if let apiRequest = request as? APIRequest {
            executeAPIRequest(cache, request: request, apiRequest: apiRequest)
        }
    }
    
    private func executeAPIRequest(_ cache: RequestCache, request: DengageLiveActivityRequest, apiRequest: APIRequest) {
        guard let apiClient = self.apiClient else { return }
        
        Logger.log(message: "Dengage.LiveActivities executing request: \(request.key)")
        
        // Use type erasure to call send
        if let setUpdateRequest = apiRequest as? DengageRequestSetUpdateToken {
            apiClient.send(request: setUpdateRequest) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    Logger.log(message: "Dengage.LiveActivities request succeeded: \(request.key)")
                    self.requestDispatch.async {
                        cache.markSuccessful(request)
                    }
                case .failure(let error):
                    Logger.log(message: "Dengage.LiveActivities request failed with error \(error.localizedDescription)")
                    // For non-retryable errors, remove from cache
                    if let serviceError = error as? ServiceError,
                       case .fail(let code) = serviceError,
                       code >= 400 && code < 500 {
                        self.requestDispatch.async {
                            cache.remove(request)
                        }
                        return
                    }
                    // retryable failures will stay in the cache, and will retry the next time the app starts
                }
            }
        } else if let setStartRequest = apiRequest as? DengageRequestSetStartToken {
            apiClient.send(request: setStartRequest) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    Logger.log(message: "Dengage.LiveActivities request succeeded: \(request.key)")
                    self.requestDispatch.async {
                        cache.markSuccessful(request)
                    }
                case .failure(let error):
                    Logger.log(message: "Dengage.LiveActivities request failed with error \(error.localizedDescription)")
                    if let serviceError = error as? ServiceError,
                       case .fail(let code) = serviceError,
                       code >= 400 && code < 500 {
                        self.requestDispatch.async {
                            cache.remove(request)
                        }
                        return
                    }
                }
            }
        } else if let removeUpdateRequest = apiRequest as? DengageRequestRemoveUpdateToken {
            apiClient.send(request: removeUpdateRequest) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    Logger.log(message: "Dengage.LiveActivities request succeeded: \(request.key)")
                    self.requestDispatch.async {
                        cache.markSuccessful(request)
                    }
                case .failure(let error):
                    Logger.log(message: "Dengage.LiveActivities request failed with error \(error.localizedDescription)")
                    if let serviceError = error as? ServiceError,
                       case .fail(let code) = serviceError,
                       code >= 400 && code < 500 {
                        self.requestDispatch.async {
                            cache.remove(request)
                        }
                        return
                    }
                }
            }
        } else if let removeStartRequest = apiRequest as? DengageRequestRemoveStartToken {
            apiClient.send(request: removeStartRequest) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    Logger.log(message: "Dengage.LiveActivities request succeeded: \(request.key)")
                    self.requestDispatch.async {
                        cache.markSuccessful(request)
                    }
                case .failure(let error):
                    Logger.log(message: "Dengage.LiveActivities request failed with error \(error.localizedDescription)")
                    if let serviceError = error as? ServiceError,
                       case .fail(let code) = serviceError,
                       code >= 400 && code < 500 {
                        self.requestDispatch.async {
                            cache.remove(request)
                        }
                        return
                    }
                }
            }
        }
    }
}


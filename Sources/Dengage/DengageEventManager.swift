import Foundation

final class DengageEventManager: DengageEventProtocolInterface {
    
    private let config: DengageConfiguration
    private let service: DengageNetworking
    private let sessionManager: DengageSessionManagerInterface
    private var eventQueue: DispatchQueue!

    init(config: DengageConfiguration,
         service: DengageNetworking,
         sessionManager: DengageSessionManagerInterface){
        self.config = config
        self.service = service
        self.sessionManager = sessionManager
        eventQueue = DispatchQueue(label: "com.dengage.event", qos: .utility)
    }
    
    func eventSessionStart(){
        let deviceId = config.applicationIdentifier
        let session = sessionManager.createSession(force: false)
        sendEvent(table: .sessionInfo, key: deviceId, params: ["session_id": session.sessionId])
    }
    
    func sessionStart(referrer: String?) {
        let session = sessionManager.createSession(force: false)
        let deviceId = config.applicationIdentifier
        var params: [String: Any] = [:]

        params = ["session_id": session.sessionId]
        
        if let referrerURL = referrer {
            let utmItems = getUTMItems(from: referrerURL)
            params.merge(utmItems) { (_, new) in new }
        }
        
        let channel = queryStringValue(for: "dn_channel", from: referrer)
        
        if let sendId = queryStringValue(for: "dn_send_id", from: referrer) {
            params["send_id"] = sendId
            params["channel"] = channel?.lowercased() ?? "push"
        }
        
        sendEvent(table: .sessionInfo, key: deviceId, params: params)
    }
    
    func sendOpenEvet(request: OpenEventRequest) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }
            self.service.send(request: request) { result in
                switch result {
                case .success(_):
                    Logger.log(message: "Push Open Event success")
                case .failure(let error):
                    Logger.log(message: "Push Open Event fail", argument: error.localizedDescription)
                }
            }
        }
    }
    
    func sendTransactionalOpenEvet(request: TransactionalOpenEventRequest) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }
            self.service.send(request: request) { result in
                switch result {
                case .success(_):
                    Logger.log(message: "Push Transactional Open Event success")
                case .failure(let error):
                    Logger.log(message: "Push Open Transactional Event fail", argument: error.localizedDescription)
                }
            }
        }
    }
}
extension DengageEventManager {
    
    func pageView(parameters: [String: Any]) {
        var params = parameters
        params["session_id"] = sessionManager.currentSessionId
        sendEvent(table: .pageView, key: config.applicationIdentifier, params: params)
    }
    
    func search(parameters: [String: Any]) {
        var params = parameters
        params["session_id"] = sessionManager.currentSessionId
        sendEvent(table: .searchEvents, key: config.applicationIdentifier, params: params)
    }
    
    func order(parameters: [String: Any]) {
        var params = parameters
        let sessionId = sessionManager.currentSessionId
        let deviceId = config.applicationIdentifier
        
        params["session_id"] = sessionManager.currentSessionId
        params["event_type"] = "order"
        
        let cartItems = params["cartItems"] as? [[String: Any]] ?? []
        params.removeValue(forKey: "cartItems")
        
        sendEvent(table: .orderEvents, key: deviceId, params: params)
                
        let eventId = Utilities.generateUUID()
        let cartEventParams = ["session_id": sessionId,
                               "event_type": "order",
                               "event_id": eventId]
        
        sendEvent(table: .shoppingCartEvents, key: deviceId, params: cartEventParams)
        
        sendCart(items: cartItems, orderId: params["order_id"] as? String)
    }
    
    func cancelOrder(parameters: [String: Any]) {
        var params = parameters
        let sessionId = sessionManager.currentSessionId
        let deviceId = config.applicationIdentifier
        
        params["session_id"] = sessionId
        params["event_type"] = "cancel"
        params["total_amount"] = -(params["total_amount"] as? Double ?? 0.0)
        
        let cartItems = params["cartItems"] as? [[String: Any]] ?? []
        params.removeValue(forKey: "cartItems")
        
        sendEvent(table: .orderEvents, key: deviceId, params: params)
        
        sendCart(items: cartItems, orderId: params["order_id"] as? String)
    }
    
   func addToWithList(parameters: [String: Any]) {
       sendEvent(table: .wishlistEvents,
                 withDetailTable: .wishlistEventsDetail,
                 eventType: .add,
                 parameters: parameters)
    }
    
    func removeFromWithList(parameters: [String: Any]) {
        sendEvent(table: .wishlistEvents,
                  withDetailTable: .wishlistEventsDetail,
                  eventType: .remove,
                  parameters: parameters)
    }
    
    func addToCart(parameters: [String: Any]) {
        sendEvent(table: .shoppingCartEvents,
                  withDetailTable: .shoppingCartEventsDetail,
                  eventType: .addToCart,
                  parameters: parameters)
    }
    
    func removeFromCart(parameters: [String: Any]) {
        sendEvent(table: .shoppingCartEvents,
                  withDetailTable: .shoppingCartEventsDetail,
                  eventType: .removeFromCart,
                  parameters: parameters)
    }
    
    func viewCart(parameters: [String: Any]) {
        sendEvent(table: .shoppingCartEvents,
                  withDetailTable: .shoppingCartEventsDetail,
                  eventType: .viewCart,
                  parameters: parameters)
    }
    
    func beginCheckout(parameters: [String: Any]) {
        sendEvent(table: .shoppingCartEvents,
                  withDetailTable: .shoppingCartEventsDetail,
                  eventType: .beginCheckout,
                  parameters: parameters)
    }
    
    func sendCustomEvent(eventTable: String, parameters: [String: Any]) {
        var params = parameters
        params["session_id"] = sessionManager.currentSessionId
        sendEventRequest(table: eventTable, key: config.applicationIdentifier, params: params)
    }
}

// MARK: - Event
extension DengageEventManager {
    private func sendEvent(table: DengageInternalTableName,
                           withDetailTable detailTable: DengageInternalTableName,
                           eventType: DengageInternalEventType,
                           parameters: [String: Any]) {
        var params = parameters

        let sessionId = sessionManager.currentSessionId
        let deviceId = config.applicationIdentifier
        let eventId = Utilities.generateUUID()
        
        params["session_id"] = sessionId
        params["event_type"] = eventType.rawValue
        params["event_id"] = eventId
      
        let cartItems = params["cartItems"] as? [[String: Any]] ?? []
        params.removeValue(forKey: "cartItems")
        
        sendEvent(table: table, key: deviceId, params: params)

        sendCart(items: cartItems, eventId: eventId, detailTable: detailTable)
    }
    
    private func sendCart(items: [[String: Any]], eventId: String, detailTable: DengageInternalTableName) {
        for cartItem in items {
            var itemParam = cartItem
            itemParam["event_id"] = eventId
            sendEvent(table: detailTable, key: config.applicationIdentifier, params: itemParam)
        }
    }
    
    private func sendCart(items: [[String: Any]], orderId: String?) {
        for cartItem in items {
            var itemParam = cartItem
            itemParam["order_id"] = orderId
            sendEvent(table: .orderEventsDetails, key: config.applicationIdentifier, params: itemParam)
        }
    }
}
// MARK: - Workers
extension DengageEventManager {
    
    private func getUTMItems(from referrerURL: String?) -> [String: Any]{
        guard let urlString = referrerURL,
              let url = URL(string: urlString) else { return [:] }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return [:] }
        var parameters = [String: Any]()
        for queryItem in items {
            parameters[queryItem.name] = queryItem.value
        }
        var result = [String: Any]()
        ["utm_source", "utm_medium", "utm_campaign", "utm_content", "utm_term"].forEach{itemName in
            if let value = parameters[itemName] {
                result[itemName] = value
            }
        }
        return result
    }
    
    private func queryStringValue(for name:String, from referrerURL: String?) -> String? {
        guard let urlString = referrerURL,
              let url = URL(string: urlString) else { return nil }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return nil }
        return items.first(where: {$0.name == name})?.value
    }
    
    private func sendEvent(table: DengageInternalTableName, key: String, params: [String : Any]) {
        sendEventRequest(table: table.rawValue, key: key, params: params)
    }
    
    private func sendEventRequest(table: String, key: String, params: [String : Any]) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }
            let request = EventRequest(integrationKey: self.config.integrationKey,
                                       key: key,
                                       eventTable: table,
                                       eventDetails: params)

            self.service.send(request: request) { result in
                switch result {
                case .success(_):
                    Logger.log(message: "Event success", argument: table)
                case .failure(_):
                    //Logger.log(message: "Event fail \(table)", argument: error.localizedDescription)
                    break
                }
            }
        }
    }
}

protocol DengageEventProtocolInterface: AnyObject {
    func sessionStart(referrer: String?)
    func eventSessionStart()
    func sendOpenEvet(request: OpenEventRequest)
    func sendTransactionalOpenEvet(request: TransactionalOpenEventRequest)
    // public
    func pageView(parameters: [String: Any])
    func addToCart(parameters: [String: Any])
    func removeFromCart(parameters: [String: Any])
    func viewCart(parameters: [String: Any])
    func beginCheckout(parameters: [String: Any])
    func order(parameters: [String: Any])
    func cancelOrder(parameters: [String: Any])
    func search(parameters: [String: Any])
    func addToWithList(parameters: [String: Any])
    func removeFromWithList(parameters: [String: Any])
    func sendCustomEvent(eventTable: String, parameters: [String: Any])
}

enum DengageInternalTableName: String{
    case pageView = "page_view_events"
    case sessionInfo = "session_info"
    case shoppingCartEvents = "shopping_cart_events"
    case searchEvents = "search_events"
    case wishlistEvents = "wishlist_events"
    case orderEvents = "order_events"
    case wishlistEventsDetail = "wishlist_events_detail"
    case orderEventsDetails = "order_events_detail"
    case shoppingCartEventsDetail = "shopping_cart_events_detail"
}

enum DengageInternalEventType: String {
    case addToCart = "add_to_cart"
    case cancel = "cancel"
    case add = "add"
    case remove = "remove"
    case removeFromCart = "remove_from_cart"
    case viewCart = "view_cart"
    case beginCheckout = "begin_checkout"
}

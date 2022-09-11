import Foundation
final class DengageSessionManager: DengageSessionManagerInterface {

    private(set) var currentSession: Session? {
        get {
            DengageLocalStorage.shared.getSession()
        }
        set {
            DengageLocalStorage.shared.save(newValue)
        }
    }
    
    var currentSessionId: String{
        return currentSession?.sessionId ?? ""
    }
    
    let config: DengageConfiguration
    
    init(config: DengageConfiguration) {
        self.config = config
    }
    
    @discardableResult func createSession(force: Bool) -> Session {
        guard
            let currentSession = currentSession, force == false
        else {
            let newSession = generateNewSession()
            currentSession = newSession
            return newSession
        }
        
        if currentSession.expireIn > Date() {
            currentSession.expireIn.addTimeInterval(
                Double(config.remoteConfiguration?.realTimeInAppSessionTimeoutMinutes ?? 30)
            )
            return currentSession
        } else {
            let newSession = generateNewSession()
            self.currentSession = newSession
            return newSession
        }
    }
    
    private func generateNewSession() -> Session{
        let newSessionId = NSUUID().uuidString.lowercased()
        
        let newSessionExpireDate = Date().addingTimeInterval(Double(config.remoteConfiguration?.realTimeInAppSessionTimeoutMinutes ?? 1800))
        DengageVisitCountManager.updateVisitCount()
        config.resetPageViewCount()
        return Session(sessionId: newSessionId,
                       expireIn: newSessionExpireDate)
        
    }
}

protocol DengageSessionManagerInterface: AnyObject{
    func createSession(force: Bool) -> Session
    var currentSessionId: String { get }
    var currentSession: Session? { get }
}

final class Session: Codable {
    let sessionId: String
    var expireIn: Date
    
    internal init(sessionId: String, expireIn: Date) {
        self.sessionId = sessionId
        self.expireIn = expireIn
    }
}

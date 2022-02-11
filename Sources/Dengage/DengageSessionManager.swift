import Foundation
final class DengageSessionManager: DengageSessionManagerInterface {
    private(set) var currentSession: Session?
    
    var currentSessionId: String{
        return currentSession?.sessionId ?? ""
    }
    
    static let sessionInterval: Double = 1800

    func createSession(restart: Bool) -> Session {
        if let currentSession = currentSession {
            if restart{
                let newSession = generateNewSession()
                self.currentSession = newSession
                return newSession
            }else {
                if currentSession.expireIn > Date(){
                    currentSession.expireIn.addTimeInterval(DengageSessionManager.sessionInterval)
                    return currentSession
                }else {
                    let newSession = generateNewSession()
                    self.currentSession = newSession
                    return newSession
                }
            }
        }else {
            let newSession = generateNewSession()
            currentSession = newSession
            return newSession
        }
    }
    
    private func generateNewSession() -> Session{
        let newSessionId = NSUUID().uuidString.lowercased()
        let newSessionExpireDate = Date().addingTimeInterval(DengageSessionManager.sessionInterval)
        return Session(sessionId: newSessionId,
                                       expireIn: newSessionExpireDate)
    }
}

protocol DengageSessionManagerInterface: AnyObject{
    func createSession(restart: Bool) -> Session
    var currentSessionId: String { get }
    var currentSession: Session? { get }
}

final class Session {
    let sessionId: String
    var expireIn: Date
    
    internal init(sessionId: String, expireIn: Date) {
        self.sessionId = sessionId
        self.expireIn = expireIn
    }
}

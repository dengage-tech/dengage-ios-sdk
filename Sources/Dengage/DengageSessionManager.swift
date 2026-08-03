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
            // Kayan pencere: her dokunuşta son kullanma "şimdi + timeout" olur. `currentSession`
            // getter'ı her erişimde depodan yeni bir nesne decode ettiği için, geri yazılmadan
            // yapılan güncelleme kalıcı olmaz.
            currentSession.expireIn = Date().addingTimeInterval(sessionTimeout)
            self.currentSession = currentSession
            return currentSession
        } else {
            let newSession = generateNewSession()
            self.currentSession = newSession
            return newSession
        }
    }

    private func generateNewSession() -> Session{
        let newSessionId = NSUUID().uuidString.lowercased()

        let newSessionExpireDate = Date().addingTimeInterval(sessionTimeout)
        DengageVisitCountManager.updateVisitCount()
        config.resetPageViewCount()
        return Session(sessionId: newSessionId,
                       expireIn: newSessionExpireDate)

    }

    /// Oturum ömrü. Panel değeri **dakika** cinsinden gelir (Android tarafı da `Calendar.MINUTE`
    /// ile ekler); `addingTimeInterval` ise saniye aldığı için 60 ile çarpılır.
    private var sessionTimeout: TimeInterval {
        let minutes = config.remoteConfiguration?.realTimeInAppSessionTimeoutMinutes
            ?? Self.defaultSessionTimeoutMinutes
        return TimeInterval(minutes * 60)
    }

    /// Remote config yokken kullanılan varsayılan oturum ömrü (dakika) — Android ile aynı.
    private static let defaultSessionTimeoutMinutes = 30
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

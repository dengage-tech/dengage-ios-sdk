import Foundation
import OSLog

public let Logger = DengageLog()

public final class DengageLog{
    
    var isEnabled: Bool = false
    var logs = Array(repeating: "", count: 200)
    var logCount = 0
    public func log(message: String, argument: String = "") {
        
        if isEnabled
        {
            os_log("[DENGAGE] %@ %@", log: .default, type: .debug, message, argument)
            
        }
        
    }
    
  
}

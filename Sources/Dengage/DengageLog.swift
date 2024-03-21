import Foundation
import OSLog

let Logger = DengageLog()

final class DengageLog{
    
    var isEnabled: Bool = false
    var logs = Array(repeating: "", count: 200)
    var logCount = 0
    func log(message: String, argument: String = "") {
        
        if isEnabled
        {
            os_log("[DENGAGE] %@ %@", log: .default, type: .debug, message, argument)
            
        }
        
    }
    
}

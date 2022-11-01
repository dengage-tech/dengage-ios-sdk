import Foundation
import OSLog

let Logger = DengageLog()

final class DengageLog{
    
    var isEnabled: Bool = true
    var logs = Array(repeating: "", count: 200)
    var logCount = 0
    func log(message: String, argument: String = "") {
        os_log("[DENGAGE] %@ %@", log: .default, type: .debug, message, argument)
        saveLog(message: String(format: "[DENGAGE] %@ %@", message, argument))
    }
    
    private func saveLog(message: String){
        if logCount == 200 {
            logs.remove(at: 0)
            logs.append(message)
        }else{
            logs[logCount] = message
            logCount += 1
        }
    }
}

import Foundation

/// Kampanya tetikleme türü. Wire değeri küçük harf string (contract §0).
public enum GeofenceTriggerType: String, Codable {
    case enter
    case exit
    case dwell

    public static func from(_ value: String?) -> GeofenceTriggerType {
        switch value?.lowercased() {
        case "exit": return .exit
        case "dwell": return .dwell
        default: return .enter
        }
    }
}

/// event-signal v2 eventType alanı (contract §3).
public enum GeofenceEventType: String, Codable {
    case enter
    case exit
    case dwell
}

/// event-signal v2 source alanı. `online` = anlık tetik, `replay` = offline kuyruktan flush (contract §3).
public enum GeofenceEventSource: String, Codable {
    case online
    case replay
}

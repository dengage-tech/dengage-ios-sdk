import Foundation
import UIKit

final class DengageEventHistoryUtils {
    
    class func operateEventHistoryFilter(criterion: Criterion) -> Bool {
        guard let eventType = criterion.eventType else { return false }
        
        let clientEvents = DengageLocalStorage.shared.getClientEvents()
        guard let eventTypeEvents = clientEvents[eventType] else { return false }
        
        // Filter events by time window
        let eventsInWindow: [ClientEvent]
        if criterion.timeWindow?.type.uppercased() == "SESSION" {
            // For SESSION type, filter events that belong to current session
            guard let currentSession = DengageLocalStorage.shared.getSession() else { return false }
            let currentSessionId = currentSession.sessionId
            eventsInWindow = eventTypeEvents.filter { event in
                let eventSessionId = event.eventDetails["session_id"] as? String
                return eventSessionId == currentSessionId
            }
        } else {
            // For other time window types, filter by time
            let windowMillis = parseTimeWindow(criterion.timeWindow)
            let cutoffTime = Date().timeIntervalSince1970 * 1000 - windowMillis
            eventsInWindow = eventTypeEvents.filter { $0.timestamp >= cutoffTime }
        }
        
        // Apply additional filters if any
        let filteredEvents: [ClientEvent]
        if let filters = criterion.filters, !filters.isEmpty {
            filteredEvents = applyEventFilters(events: eventsInWindow,
                                             filters: filters,
                                             logicalOp: criterion.filtersLogicalOp)
        } else {
            filteredEvents = eventsInWindow
        }
        
        // Calculate aggregate value
        let aggregateValue: Double
        switch criterion.aggregateType?.uppercased() {
        case "COUNT":
            aggregateValue = Double(filteredEvents.count)
        case "SUM":
            guard let field = criterion.aggregateField else { return false }
            aggregateValue = filteredEvents.reduce(0.0) { sum, event in
                let value = event.eventDetails[field] as? String
                return sum + (Double(value ?? "0") ?? 0.0)
            }
        case "MIN":
            guard let field = criterion.aggregateField else { return false }
            let values = filteredEvents.compactMap { event in
                let stringValue = event.eventDetails[field] as? String
                return Double(stringValue ?? "")
            }
            guard let minValue = values.min() else { return false }
            aggregateValue = minValue
        case "MAX":
            guard let field = criterion.aggregateField else { return false }
            let values = filteredEvents.compactMap { event in
                let stringValue = event.eventDetails[field] as? String
                return Double(stringValue ?? "")
            }
            guard let maxValue = values.max() else { return false }
            aggregateValue = maxValue
        case "AVG":
            guard let field = criterion.aggregateField else { return false }
            let values = filteredEvents.compactMap { event in
                let stringValue = event.eventDetails[field] as? String
                return Double(stringValue ?? "")
            }
            guard !values.isEmpty else { return false }
            aggregateValue = values.reduce(0, +) / Double(values.count)
        case "DISTINCT_COUNT":
            guard let field = criterion.aggregateField else { return false }
            let distinctValues = Set(filteredEvents.compactMap { event in
                event.eventDetails[field] as? String
            })
            aggregateValue = Double(distinctValues.count)
        default:
            return false
        }
        
        // Compare with criterion values
        guard let targetValueString = criterion.values.first,
              let targetValue = Double(targetValueString) else { return false }
        
        switch criterion.comparison {
        case .EQUALS:
            return aggregateValue == targetValue
        case .NOT_EQUALS:
            return aggregateValue != targetValue
        case .GREATER_THAN:
            return aggregateValue > targetValue
        case .GREATER_EQUAL:
            return aggregateValue >= targetValue
        case .LESS_THAN:
            return aggregateValue < targetValue
        case .LESS_EQUAL:
            return aggregateValue <= targetValue
        default:
            return false
        }
    }
    
    private class func parseTimeWindow(_ timeWindow: TimeWindow?) -> Double {
        guard let timeWindow = timeWindow else { return 30 * 60 * 1000 } // Default to 30 minutes
        
        switch timeWindow.unit.uppercased() {
        case "MINUTE":
            return (Double(timeWindow.value) ?? 30) * 60 * 1000
        case "HOUR":
            return (Double(timeWindow.value) ?? 1) * 60 * 60 * 1000
        case "DAY":
            return (Double(timeWindow.value) ?? 1) * 24 * 60 * 60 * 1000
        case "WEEK":
            return (Double(timeWindow.value) ?? 1) * 7 * 24 * 60 * 60 * 1000
        case "MONTH":
            return (Double(timeWindow.value) ?? 1) * 30 * 24 * 60 * 60 * 1000
        case "SESSION":
            return 0 // Return 0 for SESSION type as it's handled separately
        default:
            return 30 * 60 * 1000 // Default to 30 minutes
        }
    }
    
    private class func applyEventFilters(events: [ClientEvent],
                                         filters: [EventFilter],
                                         logicalOp: String?) -> [ClientEvent] {
        if filters.isEmpty { return events }
        
        return events.filter { event in
            let filterResults = filters.map { filter in
                applyEventFilter(event: event, filter: filter)
            }
            
            switch logicalOp?.uppercased() {
            case "AND":
                return filterResults.allSatisfy { $0 }
            case "OR":
                return filterResults.contains(true)
            default:
                return filterResults.allSatisfy { $0 } // default to AND
            }
        }
    }
    
    private class func applyEventFilter(event: ClientEvent, filter: EventFilter) -> Bool {
        guard let fieldValue = event.eventDetails[filter.field] as? String else { return false }
        
        switch filter.op.uppercased() {
        case "EQUALS", "EQ":
            return filter.values.contains { $0.lowercased() == fieldValue.lowercased() }
        case "NOT_EQUALS", "NE":
            return !filter.values.contains { $0.lowercased() == fieldValue.lowercased() }
        case "IN":
            return filter.values.contains { $0.lowercased() == fieldValue.lowercased() }
        case "NOT_IN":
            return !filter.values.contains { $0.lowercased() == fieldValue.lowercased() }
        case "LIKE":
            return filter.values.contains { fieldValue.lowercased().contains($0.lowercased()) }
        case "NOT_LIKE":
            return !filter.values.contains { fieldValue.lowercased().contains($0.lowercased()) }
        case "STARTS_WITH":
            return filter.values.contains { fieldValue.lowercased().hasPrefix($0.lowercased()) }
        case "NOT_STARTS_WITH":
            return !filter.values.contains { fieldValue.lowercased().hasPrefix($0.lowercased()) }
        case "ENDS_WITH":
            return filter.values.contains { fieldValue.lowercased().hasSuffix($0.lowercased()) }
        case "NOT_ENDS_WITH":
            return !filter.values.contains { fieldValue.lowercased().hasSuffix($0.lowercased()) }
        case "CONTAINS":
            return filter.values.contains { fieldValue.lowercased().contains($0.lowercased()) }
        case "NOT_CONTAINS":
            return !filter.values.contains { fieldValue.lowercased().contains($0.lowercased()) }
        case "CONTAINS_ALL":
            return filter.values.allSatisfy { value in
                fieldValue.lowercased().contains(value.lowercased())
            }
        case "CONTAINS_ANY":
            return filter.values.contains { value in
                fieldValue.lowercased().contains(value.lowercased())
            }
        case "GREATER_THAN", "GT":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue > numFilterValue
        case "GREATER_EQUAL", "GTE":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue >= numFilterValue
        case "LESS_THAN", "LT":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue < numFilterValue
        case "LESS_EQUAL", "LTE":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue <= numFilterValue
        case "EXISTS":
            return !fieldValue.isEmpty
        case "NOT_EXISTS":
            return fieldValue.isEmpty
        default:
            return false
        }
    }
    
}

import Foundation
import UIKit

final class DengageEventHistoryUtils {
    
    class func operateEventHistoryFilter(criterion: Criterion) -> Bool {
        
        guard let eventType = criterion.eventType else { return false }
        
        let clientEvents = DengageLocalStorage.shared.getClientEvents()
        guard let tableEvents = clientEvents[eventType] else { return false }
        
        let windowMillis = parseTimeWindow(criterion.timeWindow)
        let cutoffTime = Date().timeIntervalSince1970 * 1000 - windowMillis
        
        let eventsInWindow = tableEvents.filter { $0.timestamp >= cutoffTime }
        
        let filteredEvents: [ClientEvent]
        if let filters = criterion.filters, !filters.isEmpty {
            filteredEvents = applyEventFilters(events: eventsInWindow,
                                               filters: filters,
                                               logicalOp: criterion.filtersLogicalOp)
        } else {
            filteredEvents = eventsInWindow
        }
        
        let aggregateValue: Int
        switch criterion.aggregateType {
        case "count":
            aggregateValue = filteredEvents.count
        case "distinct_count":
            guard let field = criterion.aggregateField else { return false }
            let distinctValues = Set(filteredEvents.compactMap { event in
                event.eventDetails[field] as? String
            })
            aggregateValue = distinctValues.count
        default:
            return false
        }
        
        guard let targetValueString = criterion.values.first,
              let targetValue = Int(targetValueString) else { return false }
        
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
            
            switch logicalOp {
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
        
        switch filter.op {
        case "EQUALS", "EQ":
            return filter.values.contains(fieldValue)
        case "NOT_EQUALS", "NE":
            return !filter.values.contains(fieldValue)
        case "IN":
            return filter.values.contains(fieldValue)
        case "NOT_IN":
            return !filter.values.contains(fieldValue)
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
        default:
            return false
        }
    }
    
}

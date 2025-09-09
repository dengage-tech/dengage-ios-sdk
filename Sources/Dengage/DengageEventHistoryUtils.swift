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
        guard let timeWindow = timeWindow else { return Double.greatestFiniteMagnitude }
        
        do {
            // Parse ISO 8601 duration format (e.g., P7D, PT24H, P30M)
            let pattern = "P(?:(\\d+)D)?(?:T(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+)S)?)?"
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = timeWindow.value as NSString
            let results = regex.matches(in: timeWindow.value, range: NSRange(location: 0, length: nsString.length))
            
            guard let match = results.first else { return Double.greatestFiniteMagnitude }
            
            var days: Double = 0
            var hours: Double = 0
            var minutes: Double = 0
            var seconds: Double = 0
            
            if match.range(at: 1).location != NSNotFound {
                days = Double(nsString.substring(with: match.range(at: 1))) ?? 0
            }
            if match.range(at: 2).location != NSNotFound {
                hours = Double(nsString.substring(with: match.range(at: 2))) ?? 0
            }
            if match.range(at: 3).location != NSNotFound {
                minutes = Double(nsString.substring(with: match.range(at: 3))) ?? 0
            }
            if match.range(at: 4).location != NSNotFound {
                seconds = Double(nsString.substring(with: match.range(at: 4))) ?? 0
            }
            
            return (days * 24 * 60 * 60 * 1000) +
            (hours * 60 * 60 * 1000) +
            (minutes * 60 * 1000) +
            (seconds * 1000)
        } catch {
            DengageLog().log(message: "Error parsing time window: \(error.localizedDescription)")
            return Double.greatestFiniteMagnitude
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

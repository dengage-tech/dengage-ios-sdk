import Foundation
import UIKit

final class DengageCartUtils {
    
    class func operateCartFilter(criterion: Criterion) -> Bool {
        
        guard let cart = DengageLocalStorage.shared.getClientCart() else { return false }
        
        let filteredItems: [CartItem]
        if let filters = criterion.filters, !filters.isEmpty {
            filteredItems = applyCartFilters(items: cart.items,
                                             filters: filters,
                                             logicalOp: criterion.filtersLogicalOp)
        } else {
            filteredItems = cart.items
        }
        
        let aggregateValue: Double
        switch criterion.aggregateType?.uppercased() {
        case "COUNT":
            aggregateValue = Double(filteredItems.count)
        case "DISTINCT_COUNT":
            guard let field = criterion.aggregateField else { return false }
            aggregateValue = getDistinctCount(items: filteredItems, field: field)
        case "SUM":
            guard let field = criterion.aggregateField else { return false }
            aggregateValue = getSumValue(items: filteredItems, field: field)
        case "MIN":
            guard let field = criterion.aggregateField else { return false }
            aggregateValue = getMinValue(items: filteredItems, field: field)
        case "MAX":
            guard let field = criterion.aggregateField else { return false }
            aggregateValue = getMaxValue(items: filteredItems, field: field)
        case "AVG":
            guard let field = criterion.aggregateField else { return false }
            aggregateValue = getAvgValue(items: filteredItems, field: field)
        default:
            return false
        }
        
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
    
    private class func applyCartFilters(items: [CartItem],
                                        filters: [EventFilter],
                                        logicalOp: String?) -> [CartItem] {
        if filters.isEmpty { return items }
        
        return items.filter { item in
            let filterResults = filters.map { filter in
                applyCartFilter(item: item, filter: filter)
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
    
    private class func applyCartFilter(item: CartItem, filter: EventFilter) -> Bool {
        guard let fieldValue = getFieldValue(item: item, field: filter.parameter) else { return false }
        
        switch filter.comparison.uppercased() {
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
    
    private class func getFieldValue(item: CartItem, field: String) -> String? {
        switch field {
        case "product_id":
            return item.productId
        case "product_variant_id":
            return item.productVariantId
        case "category_path":
            return item.categoryPath
        case "price":
            return item.price.description
        case "discounted_price":
            return item.discountedPrice.description
        case "has_discount":
            return item.hasDiscount.description
        case "has_promotion":
            return item.hasPromotion.description
        case "quantity":
            return item.quantity.description
        case "effective_price":
            return item.effectivePrice.description
        case "line_total":
            return item.lineTotal.description
        case "discounted_line_total":
            return item.discountedLineTotal.description
        case "effective_line_total":
            return item.effectiveLineTotal.description
        case "category_root":
            return item.categoryRoot
        default:
            // Handle attributes with dot notation (e.g., "attributes.brand")
            if field.hasPrefix("attributes.") {
                let attributeKey = String(field.dropFirst("attributes.".count))
                return item.attributes[attributeKey]
            } else {
                return item.attributes[field]
            }
        }
    }
    
    private class func getDistinctCount(items: [CartItem], field: String) -> Double {
        let distinctValues = Set(items.compactMap { item in
            getFieldValue(item: item, field: field)
        })
        return Double(distinctValues.count)
    }
    
    private class func getSumValue(items: [CartItem], field: String) -> Double {
        return items.reduce(0.0) { sum, item in
            switch field {
            case "price":
                return sum + Double(item.price)
            case "discounted_price":
                return sum + Double(item.discountedPrice)
            case "quantity":
                return sum + Double(item.quantity)
            case "effective_price":
                return sum + Double(item.effectivePrice)
            case "line_total":
                return sum + Double(item.lineTotal)
            case "discounted_line_total":
                return sum + Double(item.discountedLineTotal)
            case "effective_line_total":
                return sum + Double(item.effectiveLineTotal)
            default:
                let value = getFieldValue(item: item, field: field)
                return sum + (Double(value ?? "0") ?? 0.0)
            }
        }
    }
    
    private class func getMinValue(items: [CartItem], field: String) -> Double {
        let values = items.compactMap { item -> Double? in
            switch field {
            case "price":
                return Double(item.price)
            case "discounted_price":
                return  Double(item.discountedPrice)
            case "quantity":
                return Double(item.quantity)
            case "effective_price":
                return Double(item.effectivePrice)
            case "line_total":
                return Double(item.lineTotal)
            case "discounted_line_total":
                return Double(item.discountedLineTotal)
            case "effective_line_total":
                return Double(item.effectiveLineTotal)
            default:
                let value = getFieldValue(item: item, field: field)
                return Double(value ?? "")
            }
        }
        return values.min() ?? 0.0
    }
    
    private class func getMaxValue(items: [CartItem], field: String) -> Double {
        let values = items.compactMap { item -> Double? in
            switch field {
            case "price":
                return Double(item.price)
            case "discounted_price":
                return Double(item.discountedPrice)
            case "quantity":
                return Double(item.quantity)
            case "effective_price":
                return Double(item.effectivePrice)
            case "line_total":
                return Double(item.lineTotal)
            case "discounted_line_total":
                return Double(item.discountedLineTotal)
            case "effective_line_total":
                return Double(item.effectiveLineTotal)
            default:
                let value = getFieldValue(item: item, field: field)
                return Double(value ?? "")
            }
        }
        return values.max() ?? 0.0
    }
    
    private class func getAvgValue(items: [CartItem], field: String) -> Double {
        if items.isEmpty { return 0.0 }
        let sum = getSumValue(items: items, field: field)
        return sum / Double(items.count)
    }
}

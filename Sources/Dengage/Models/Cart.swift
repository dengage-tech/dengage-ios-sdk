import Foundation

@objc public class Cart: NSObject, Codable {
    let items: [CartItem]
    let summary: CartSummary
    
    init(items: [CartItem]) {
        self.items = items
        self.summary = CartSummary.calculate(items: items)
    }
    
    enum CodingKeys: String, CodingKey {
        case items
        case summary
    }
}

@objc public class CartItem: NSObject, Codable {
    let productId: String?
    let productVariantId: String?
    let categoryPath: String?
    let price: Int?
    let discountedPrice: Int?
    let hasDiscount: Bool?
    let hasPromotion: Bool?
    let quantity: Int?
    let attributes: [String: String]?
    
    // Calculated fields - these will be computed by the SDK
    let effectivePrice: Int
    let lineTotal: Int
    let discountedLineTotal: Int
    let effectiveLineTotal: Int
    
    // Normalized fields
    let categorySegments: [String]
    let categoryRoot: String
    
    init(productId: String?,
         productVariantId: String?,
         categoryPath: String?,
         price: Int?,
         discountedPrice: Int?,
         hasDiscount: Bool?,
         hasPromotion: Bool?,
         quantity: Int?,
         attributes: [String: String]?) {
        self.productId = productId
        self.productVariantId = productVariantId
        self.categoryPath = categoryPath
        self.price = price
        self.discountedPrice = discountedPrice
        self.hasDiscount = hasDiscount
        self.hasPromotion = hasPromotion
        self.quantity = quantity
        self.attributes = attributes
        
        self.effectivePrice = CartItem.calculateEffectivePrice(price: price, discountedPrice: discountedPrice, hasDiscount: hasDiscount, hasPromotion: hasPromotion)
        self.lineTotal = CartItem.calculateLineTotal(price: price, quantity: quantity)
        self.discountedLineTotal = CartItem.calculateDiscountedLineTotal(discountedPrice: discountedPrice, quantity: quantity)
        self.effectiveLineTotal = CartItem.calculateEffectiveLineTotal(price: price, discountedPrice: discountedPrice, hasDiscount: hasDiscount, hasPromotion: hasPromotion, quantity: quantity)
        
        self.categorySegments = CartItem.parseCategorySegments(categoryPath: categoryPath)
        self.categoryRoot = CartItem.getCategoryRootFromPath(categoryPath: categoryPath)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        productVariantId = try container.decodeIfPresent(String.self, forKey: .productVariantId)
        categoryPath = try container.decodeIfPresent(String.self, forKey: .categoryPath)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        discountedPrice = try container.decodeIfPresent(Int.self, forKey: .discountedPrice)
        hasDiscount = try container.decodeIfPresent(Bool.self, forKey: .hasDiscount)
        hasPromotion = try container.decodeIfPresent(Bool.self, forKey: .hasPromotion)
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
        attributes = try container.decodeIfPresent([String: String].self, forKey: .attributes)
        
        effectivePrice = try container.decodeIfPresent(Int.self, forKey: .effectivePrice) ?? CartItem.calculateEffectivePrice(price: price, discountedPrice: discountedPrice, hasDiscount: hasDiscount, hasPromotion: hasPromotion)
        lineTotal = try container.decodeIfPresent(Int.self, forKey: .lineTotal) ?? CartItem.calculateLineTotal(price: price, quantity: quantity)
        discountedLineTotal = try container.decodeIfPresent(Int.self, forKey: .discountedLineTotal) ?? CartItem.calculateDiscountedLineTotal(discountedPrice: discountedPrice, quantity: quantity)
        effectiveLineTotal = try container.decodeIfPresent(Int.self, forKey: .effectiveLineTotal) ?? CartItem.calculateEffectiveLineTotal(price: price, discountedPrice: discountedPrice, hasDiscount: hasDiscount, hasPromotion: hasPromotion, quantity: quantity)
        
        categorySegments = try container.decodeIfPresent([String].self, forKey: .categorySegments) ?? CartItem.parseCategorySegments(categoryPath: categoryPath)
        categoryRoot = try container.decodeIfPresent(String.self, forKey: .categoryRoot) ?? CartItem.getCategoryRootFromPath(categoryPath: categoryPath)
    }
    
    private static func calculateEffectivePrice(price: Int?, discountedPrice: Int?, hasDiscount: Bool?, hasPromotion: Bool?) -> Int {
        if (hasDiscount == true || hasPromotion == true), let discountedPrice = discountedPrice {
            return discountedPrice
        } else {
            return price ?? 0
        }
    }
    
    private static func calculateLineTotal(price: Int?, quantity: Int?) -> Int {
        return (price ?? 0) * (quantity ?? 0)
    }
    
    private static func calculateDiscountedLineTotal(discountedPrice: Int?, quantity: Int?) -> Int {
        return (discountedPrice ?? 0) * (quantity ?? 0)
    }
    
    private static func calculateEffectiveLineTotal(price: Int?, discountedPrice: Int?, hasDiscount: Bool?, hasPromotion: Bool?, quantity: Int?) -> Int {
        let effectivePrice = calculateEffectivePrice(price: price, discountedPrice: discountedPrice, hasDiscount: hasDiscount, hasPromotion: hasPromotion)
        return effectivePrice * (quantity ?? 0)
    }
    
    private static func parseCategorySegments(categoryPath: String?) -> [String] {
        return categoryPath?.split(separator: "/").compactMap { segment in
            let trimmed = segment.trimmingCharacters(in: .whitespaces)
            return trimmed.isEmpty ? nil : String(trimmed)
        } ?? []
    }
    
    private static func getCategoryRootFromPath(categoryPath: String?) -> String {
        return parseCategorySegments(categoryPath: categoryPath).first ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case productVariantId = "product_variant_id"
        case categoryPath = "category_path"
        case price
        case discountedPrice = "discounted_price"
        case hasDiscount = "has_discount"
        case hasPromotion = "has_promotion"
        case quantity
        case attributes
        case effectivePrice = "effective_price"
        case lineTotal = "line_total"
        case discountedLineTotal = "discounted_line_total"
        case effectiveLineTotal = "effective_line_total"
        case categorySegments = "category_segments"
        case categoryRoot = "category_root"
    }
}

@objc public class CartSummary: NSObject, Codable {
    let currency: String
    let updatedAt: TimeInterval
    
    // Count fields
    let linesCount: Int
    let itemsCount: Int
    
    // Total fields
    let subtotal: Int
    let discountedSubtotal: Int
    let effectiveSubtotal: Int
    
    // Discount flags
    let anyDiscounted: Bool
    let allDiscounted: Bool
    
    // Price ranges
    let minPrice: Int
    let maxPrice: Int
    let minEffectivePrice: Int
    let maxEffectivePrice: Int
    
    // Category breakdown
    let categories: [String: Int]
    
    init(currency: String = "TRY",
         updatedAt: TimeInterval = Date().timeIntervalSince1970,
         linesCount: Int,
         itemsCount: Int,
         subtotal: Int,
         discountedSubtotal: Int,
         effectiveSubtotal: Int,
         anyDiscounted: Bool,
         allDiscounted: Bool,
         minPrice: Int,
         maxPrice: Int,
         minEffectivePrice: Int,
         maxEffectivePrice: Int,
         categories: [String: Int]) {
        self.currency = currency
        self.updatedAt = updatedAt
        self.linesCount = linesCount
        self.itemsCount = itemsCount
        self.subtotal = subtotal
        self.discountedSubtotal = discountedSubtotal
        self.effectiveSubtotal = effectiveSubtotal
        self.anyDiscounted = anyDiscounted
        self.allDiscounted = allDiscounted
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.minEffectivePrice = minEffectivePrice
        self.maxEffectivePrice = maxEffectivePrice
        self.categories = categories
    }
    
    static func calculate(items: [CartItem]) -> CartSummary {
        if items.isEmpty {
            return CartSummary(
                linesCount: 0,
                itemsCount: 0,
                subtotal: 0,
                discountedSubtotal: 0,
                effectiveSubtotal: 0,
                anyDiscounted: false,
                allDiscounted: false,
                minPrice: 0,
                maxPrice: 0,
                minEffectivePrice: 0,
                maxEffectivePrice: 0,
                categories: [:]
            )
        }
        
        // Count calculations
        let linesCount = items.count
        let itemsCount = items.reduce(0) { $0 + ($1.quantity ?? 0) }
        
        // Total calculations
        let subtotal = items.reduce(0) { $0 + $1.lineTotal }
        let discountedSubtotal = items.reduce(0) { $0 + $1.discountedLineTotal }
        let effectiveSubtotal = items.reduce(0) { $0 + $1.effectiveLineTotal }
        
        // Discount flags
        let anyDiscounted = items.contains { $0.hasDiscount == true || $0.hasPromotion == true }
        let allDiscounted = !items.isEmpty && items.allSatisfy { $0.hasDiscount == true || $0.hasPromotion == true }
        
        // Price ranges
        let prices = items.compactMap { $0.price }
        let effectivePrices = items.map { $0.effectivePrice }
        
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0
        let minEffectivePrice = effectivePrices.min() ?? 0
        let maxEffectivePrice = effectivePrices.max() ?? 0
        
        // Category breakdown
        var categories: [String: Int] = [:]
        items.forEach { item in
            let categoryRoot = item.categoryRoot
            if !categoryRoot.isEmpty {
                categories[categoryRoot] = (categories[categoryRoot] ?? 0) + (item.quantity ?? 0)
            }
        }
        
        return CartSummary(
            linesCount: linesCount,
            itemsCount: itemsCount,
            subtotal: subtotal,
            discountedSubtotal: discountedSubtotal,
            effectiveSubtotal: effectiveSubtotal,
            anyDiscounted: anyDiscounted,
            allDiscounted: allDiscounted,
            minPrice: minPrice,
            maxPrice: maxPrice,
            minEffectivePrice: minEffectivePrice,
            maxEffectivePrice: maxEffectivePrice,
            categories: categories
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case currency
        case updatedAt
        case linesCount = "lines_count"
        case itemsCount = "items_count"
        case subtotal
        case discountedSubtotal = "discounted_subtotal"
        case effectiveSubtotal = "effective_subtotal"
        case anyDiscounted = "any_discounted"
        case allDiscounted = "all_discounted"
        case minPrice = "min_price"
        case maxPrice = "max_price"
        case minEffectivePrice = "min_effective_price"
        case maxEffectivePrice = "max_effective_price"
        case categories
    }
}

import Foundation

struct ClientPageInfo: Codable {
    let lastProductId: String?
    let lastProductPrice: String?
    let lastCategoryPath: String?
    let currentPageTitle: String?
    let currentPageType: String?
    let lastViewedProducts: [String]
    let lastViewedCategories: [String]

    init(lastProductId: String? = nil,
         lastProductPrice: String? = nil,
         lastCategoryPath: String? = nil,
         currentPageTitle: String? = nil,
         currentPageType: String? = nil,
         lastViewedProducts: [String] = [],
         lastViewedCategories: [String] = []) {
        self.lastProductId = lastProductId
        self.lastProductPrice = lastProductPrice
        self.lastCategoryPath = lastCategoryPath
        self.currentPageTitle = currentPageTitle
        self.currentPageType = currentPageType
        self.lastViewedProducts = lastViewedProducts
        self.lastViewedCategories = lastViewedCategories
    }

    enum CodingKeys: String, CodingKey {
        case lastProductId, lastProductPrice, lastCategoryPath,
             currentPageTitle, currentPageType,
             lastViewedProducts, lastViewedCategories
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.lastProductId = try c.decodeIfPresent(String.self, forKey: .lastProductId)
        self.lastProductPrice = try c.decodeIfPresent(String.self, forKey: .lastProductPrice)
        self.lastCategoryPath = try c.decodeIfPresent(String.self, forKey: .lastCategoryPath)
        self.currentPageTitle = try c.decodeIfPresent(String.self, forKey: .currentPageTitle)
        self.currentPageType = try c.decodeIfPresent(String.self, forKey: .currentPageType)
        self.lastViewedProducts = (try c.decodeIfPresent([String].self, forKey: .lastViewedProducts)) ?? []
        self.lastViewedCategories = (try c.decodeIfPresent([String].self, forKey: .lastViewedCategories)) ?? []
    }
}

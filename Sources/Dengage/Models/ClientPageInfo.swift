import Foundation

struct ClientPageInfo: Codable {
    let lastProductId: String?
    let lastProductPrice: String?
    let lastCategoryPath: String?
    let currentPageTitle: String?
    let currentPageType: String?
    
    init(lastProductId: String? = nil,
         lastProductPrice: String? = nil,
         lastCategoryPath: String? = nil,
         currentPageTitle: String? = nil,
         currentPageType: String? = nil) {
        self.lastProductId = lastProductId
        self.lastProductPrice = lastProductPrice
        self.lastCategoryPath = lastCategoryPath
        self.currentPageTitle = currentPageTitle
        self.currentPageType = currentPageType
    }
}

import Foundation

/**
 A simple Codable struct to store request information for caching
 */
struct CachedRequest: Codable {
    let key: String
    let token: String?
    let requestSuccessful: Bool
    let timestamp: Date
    let requestType: String // "SetUpdateToken", "SetStartToken", "RemoveUpdateToken", "RemoveStartToken"
}


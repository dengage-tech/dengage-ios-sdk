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
    let activityType: String?
    // The live activity permission captured when a SetStartToken request was created. Optional so that
    // caches persisted before this field existed still decode successfully.
    let liveActivityPermission: Bool?
}


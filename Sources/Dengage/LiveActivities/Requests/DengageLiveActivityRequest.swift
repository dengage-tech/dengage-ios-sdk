import Foundation

/**
 Represents any live activity request, expected to be extended by
 `DengageRequestSetUpdateToken` (update token requests) and
 `DengageRequestSetStartToken` (start token requests).
 */
protocol DengageLiveActivityRequest: NSCoding {
    /**
     The unique key for this request.
     */
    var key: String { get }
    
    /**
     Whether the request has been successfully executed.
     */
    var requestSuccessful: Bool { get set }
    
    /**
     The timestamp when this request was created.
     */
    var timestamp: Date { get set }
    
    /**
     Whether this request should be forgotten about when successful.
     */
    var shouldForgetWhenSuccessful: Bool { get }
    
    /**
     Call this prior to executing the request. In addition to preparing the request for execution, it also
     returns whether the request *can* be executed.
     */
    func prepareForExecution() -> Bool
    
    /**
     Only one request "per" (i.e. activityId or activityType) can exist. This method determines
     whether  this request supersedes the provided (existing) request.
     */
    func supersedes(_ existing: DengageLiveActivityRequest) -> Bool
}

/**
 A live activity request that is related to the update token of a specific `activityId` key.
 */
protocol DengageLiveActivityUpdateTokenRequest: DengageLiveActivityRequest {
}

/**
 A live activity request that is related to the start token of a specific `activityType` key.
 */
protocol DengageLiveActivityStartTokenRequest: DengageLiveActivityRequest {
}


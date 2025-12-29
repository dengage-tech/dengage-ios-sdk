// Effectively blanks out this file for Mac Catalyst
#if targetEnvironment(macCatalyst)
#else
import ActivityKit

/**
 The protocol your ActivityAttributes should conform to in order to allow the Dengage SDK to manage
 the pushToStart and update token synchronization process on your behalf.
 */
@available(iOS 16.1, *)
public protocol DengageLiveActivityAttributes: ActivityAttributes where ContentState: DengageLiveActivityContentState {
    /**
     A reserved attribute name used by the Dengage SDK.  If starting the live activity via
     pushToStart, this will be a populated attribute by the push to start notification. If starting
     the live activity programmatically, use `DengageLiveActivityAttributeData.create`
     to create this data.
     */
    var dengage: DengageLiveActivityAttributeData { get set }
}

/**
 Dengage-specific metadata used internally. If using pushToStart, this will be passed into
 the started live activity.  If starting the live activity programmatically, use
 `DengageLiveActivityAttributeData.create` to create this data.
 */
public struct DengageLiveActivityAttributeData: Decodable, Encodable {

    /**
     Create a new instance of `DengageLiveActivityAttributeData`
     - Parameters
        - activityId: The activity identifier Dengage will use to push updates for.
     */
    public static func create(activityId: String) -> DengageLiveActivityAttributeData {
        DengageLiveActivityAttributeData(activityId: activityId)
    }

    public var activityId: String
}

/**
 The protocol your ActivityAttributes.ContentState should conform to in order to allow the Dengage SDK
 to manage the pushToStart and update token synchronization process on your behalf.
 */
@available(iOS 16.1, *)
public protocol DengageLiveActivityContentState: Decodable, Encodable, Hashable {
    /**
     A reserved attribute name used by the Dengage SDK.  When the live activity is
     updated, this attribute may be provided by the Dengage backend as a way to
     communicate with the Dengage SDK.
     */
    var dengage: DengageLiveActivityContentStateData? { get set }
}

/**
 Dengage-specific metadata used internally. When the live activity is updated, this
 attribute may be provided by the Dengage backend as a way to communicate with the
 Dengage SDK.
 */
public struct DengageLiveActivityContentStateData: Decodable, Encodable, Hashable {
    public var notificationId: String
}
#endif


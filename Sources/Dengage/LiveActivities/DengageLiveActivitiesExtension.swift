import Foundation
import ActivityKit

public extension Dengage {
    /**
     Enable the DengageSDK to setup the provided`ActivityAttributes` structure, which conforms to the
     `DengageLiveActivityAttributes`. When using this function, Dengage will manage the capturing
     and synchronizing of both pushToStart and pushToUpdate tokens.
     - Parameters
        - activityType: The specific `DengageLiveActivityAttributes` structure tied to the live activity.
        - options: An optional structure to provide for more granular setup options.
     */
    @available(iOS 16.1, *)
    static func setupLiveActivity<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, options: LiveActivitySetupOptions? = nil) {
        DengageLiveActivitiesManagerImpl.setup(activityType, options: options)
    }

    /**
     Indicate this device is capable of receiving pushToStart live activities for the `activityType`.
     - Parameters
        - activityType: The specific `ActivityAttributes` structure tied to the live activity.
        - withToken: The activity type's pushToStart token.
     */
    @available(iOS 17.2, *)
    static func setPushToStartToken<T: ActivityAttributes>(_ activityType: T.Type, withToken: String) {
        DengageLiveActivitiesManagerImpl.setPushToStartToken(activityType, withToken: withToken)
    }

    /**
     Indicate this device is no longer capable of receiving pushToStart live activities for the `activityType`.
     - Parameters
        - activityType: The specific `ActivityAttributes` structure tied to the live activity.
     */
    @available(iOS 17.2, *)
    static func removePushToStartToken<T: ActivityAttributes>(_ activityType: T.Type) {
        DengageLiveActivitiesManagerImpl.removePushToStartToken(activityType)
    }

    /**
     Enable the DengageSDK to setup the default`DefaultLiveActivityAttributes` structure, which conforms to the
     `DengageLiveActivityAttributes`. When using this function, the widget attributes are owned by the Dengage SDK,
     which will allow the SDK to handle the entire lifecycle of the live activity.  All that is needed from an app-perspective is to create
     a Live Activity widget in a widget extension, with a `ActivityConfiguration` for `DefaultLiveActivityAttributes`.
     This is most useful for users that (1) only have one Live Activity widget and (2) are using a cross-platform framework and do not
     want to create the cross-platform <-> iOS native bindings to manage ActivityKit.
     - Parameters
        - options: An optional structure to provide for more granular setup options.
     */
    @available(iOS 16.1, *)
    static func setupDefaultLiveActivity(options: LiveActivitySetupOptions? = nil) {
        DengageLiveActivitiesManagerImpl.setupDefault(options: options)
    }

    /**
     Start a new LiveActivity that is modelled by the default`DefaultLiveActivityAttributes` structure. The `DefaultLiveActivityAttributes`
     is initialized with the dynamic `attributes` and `content` passed in.
     - Parameters
        - activityId: The activity identifier the live activity on this device will be started and eligible to receive updates for.
        - attributes: A dictionary of the static attributes passed into `DefaultLiveActivityAttributes`.
        - content: A dictionary of the initial content state passed into `DefaultLiveActivityAttributes`.
     */
    @available(iOS 16.1, *)
    static func startDefaultLiveActivity(_ activityId: String, attributes: [String: Any], content: [String: Any]) {
        DengageLiveActivitiesManagerImpl.startDefault(activityId, attributes: attributes, content: content)
    }
    
    /**
     Indicate this device has entered a live activity, identified within Dengage by the `activityId`.
     - Parameters
        - activityId: The activity identifier the live activity on this device will receive updates for.
        - withToken: The live activity's update token to receive the updates.
     */
    @objc
    static func enterLiveActivity(_ activityId: String, withToken: String) {
        DengageLiveActivitiesManagerImpl.enter(activityId, withToken: withToken)
    }

    /**
     Indicate this device has exited a live activity, identified within Dengage by the `activityId`.
     - Parameters
        - activityId: The activity identifier the live activity on this device will no longer receive updates for.
     */
    @objc
    static func exitLiveActivity(_ activityId: String) {
        DengageLiveActivitiesManagerImpl.exit(activityId)
    }
}

/**
 The setup options for `Dengage.setupLiveActivity`.
 */
@objc(LiveActivitySetupOptions)
public class LiveActivitySetupOptions: NSObject {
    /**
     When true, Dengage will listen for pushToStart tokens for the `DengageLiveActivityAttributes` structure.
     */
    @objc
    public var enablePushToStart: Bool = true

    /**
     When true, Dengage will listen for pushToUpdate  tokens for each start live activity that uses the
     `DengageLiveActivityAttributes` structure.
     */
    @objc
    public var enablePushToUpdate: Bool = true

    @objc
    public init(enablePushToStart: Bool = true, enablePushToUpdate: Bool = true) {
        self.enablePushToStart = enablePushToStart
        self.enablePushToUpdate = enablePushToUpdate
    }
}

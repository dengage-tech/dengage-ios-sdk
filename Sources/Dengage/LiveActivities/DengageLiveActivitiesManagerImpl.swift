// Effectively blanks out this file for Mac Catalyst
#if targetEnvironment(macCatalyst)
#else
import Foundation
import ActivityKit

enum LiveActivitiesError: Error {
    case invalidActivityType(String)
}

public class DengageLiveActivitiesManagerImpl: NSObject {
    private static var _executor: DengageLiveActivitiesExecutor?
    
    private static var apiClient: DengageNetworking?
    private static var config: DengageConfiguration?

    public static func initialize(apiClient: DengageNetworking, config: DengageConfiguration) {
        self.apiClient = apiClient
        self.config = config
        _executor = DengageLiveActivitiesExecutor(
            requestDispatch: DispatchQueue(label: "Dengage.LiveActivities"),
            apiClient: apiClient,
            config: config
        )
        _executor?.start()
    }

    public static func enter(_ activityId: String, withToken: String) {
        guard let config = config else {
            Logger.log(message: "Dengage.LiveActivities enter called but not initialized")
            return
        }
        Logger.log(message: "Dengage.LiveActivities enter called with activityId: \(activityId) token: \(withToken)")
        let request = DengageRequestSetUpdateToken(key: activityId, token: withToken, config: config)
        _executor?.append(request)
    }

    public static func exit(_ activityId: String) {
        guard let config = config else {
            Logger.log(message: "Dengage.LiveActivities exit called but not initialized")
            return
        }
        Logger.log(message: "Dengage.LiveActivities exit called with activityId: \(activityId)")
        let request = DengageRequestRemoveUpdateToken(key: activityId, config: config)
        _executor?.append(request)
    }

    @available(iOS 17.2, *)
    public static func setPushToStartToken(_ activityType: String, withToken: String) throws {
        guard let config = config else {
            throw LiveActivitiesError.invalidActivityType("Dengage.LiveActivities not initialized")
        }
        Logger.log(message: "Dengage.LiveActivities setStartToken called with activityType: \(activityType) token: \(withToken)")

        guard let activityType = activityType.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) else {
            throw LiveActivitiesError.invalidActivityType("Cannot translate activity type to url encoded string.")
        }

        let request = DengageRequestSetStartToken(key: activityType, token: withToken, config: config)
        _executor?.append(request)
    }

    @available(iOS 17.2, *)
    public static func removePushToStartToken(_ activityType: String) throws {
        guard let config = config else {
            throw LiveActivitiesError.invalidActivityType("Dengage.LiveActivities not initialized")
        }
        Logger.log(message: "Dengage.LiveActivities removeStartToken called with activityType: \(activityType)")

        guard let activityType = activityType.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) else {
            throw LiveActivitiesError.invalidActivityType("Cannot translate activity type to url encoded string.")
        }

        let request = DengageRequestRemoveStartToken(key: activityType, config: config)
        _executor?.append(request)
    }

    @available(iOS 17.2, *)
    public static func setPushToStartToken<T>(_ activityType: T.Type, withToken: String) where T: ActivityAttributes {
        do {
            try DengageLiveActivitiesManagerImpl.setPushToStartToken("\(activityType)", withToken: withToken)
        } catch LiveActivitiesError.invalidActivityType(let message) {
            // This should never happen, because a struct name should always be URL encodable.
            Logger.log(message: message)
        } catch {
            // This should never happen.
            Logger.log(message: "Could not set push to start token")
        }
    }

    @available(iOS 17.2, *)
    public static func removePushToStartToken<T>(_ activityType: T.Type) where T: ActivityAttributes {
        do {
            try DengageLiveActivitiesManagerImpl.removePushToStartToken("\(activityType)")
        } catch LiveActivitiesError.invalidActivityType(let message) {
            // This should never happen, because a struct name should always be URL encodable.
            Logger.log(message: message)
        } catch {
            // This should never happen.
            Logger.log(message: "Could not remove push to start token")
        }
    }

    @available(iOS 16.1, *)
    public static func setup<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, options: LiveActivitySetupOptions? = nil) {
        if #available(iOS 17.2, *) {
            listenForPushToStart(activityType, options: options)
        }
        listenForActivity(activityType, options: options)
    }

    @available(iOS 16.1, *)
    public static func setupDefault(options: LiveActivitySetupOptions? = nil) {
        setup(DefaultLiveActivityAttributes.self, options: options)
    }

    @available(iOS 16.1, *)
    public static func startDefault(_ activityId: String, attributes: [String: Any], content: [String: Any]) {
        let dengageAttribute = DengageLiveActivityAttributeData.create(activityId: activityId)

        var attributeData = [String: AnyCodable]()
        for attribute in attributes {
            attributeData.updateValue(AnyCodable(attribute.value), forKey: attribute.key)
        }

        var contentData = [String: AnyCodable]()
        for contentItem in content {
            contentData.updateValue(AnyCodable(contentItem.value), forKey: contentItem.key)
        }

        let attributes = DefaultLiveActivityAttributes(data: attributeData, dengage: dengageAttribute)
        let contentState = DefaultLiveActivityAttributes.ContentState(data: contentData)
        do {
            _ = try Activity<DefaultLiveActivityAttributes>.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: .token)
        } catch let error {
            Logger.log(message: "Cannot start default live activity: \(error.localizedDescription)")
        }
    }

    @available(iOS 17.2, *)
    private static func listenForPushToStart<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, options: LiveActivitySetupOptions? = nil) {
        if options == nil || options!.enablePushToStart {
            Task {
                Logger.log(message: "Dengage.LiveActivities listening for pushToStart on: \(activityType)")
                for try await data in Activity<Attributes>.pushToStartTokenUpdates {
                    let token = data.map {String(format: "%02x", $0)}.joined()
                    DengageLiveActivitiesManagerImpl.setPushToStartToken(Attributes.self, withToken: token)
                }
            }
        }
    }

    @available(iOS 16.1, *)
    private static func listenForActivity<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, options: LiveActivitySetupOptions? = nil) {

        /*
         Apple has confirmed that when using push-to-start, it is best to check both `Activity<...>.activities` in addition
         `Activity<...>.activityUpdates` --- because your app may need to launch in the background and the launch time may end
         up being slower than the new values come in. In those cases, your task on the update sequence may start listening after
         the initial values were already provided.
         */

        // Establish listeners for activity (if any exist)
        for activity in Activity<Attributes>.activities {
            listenForActivityStateUpdates(activityType, activity: activity, options: options)
            listenForActivityPushToUpdate(activityType, activity: activity, options: options)
            if #available(iOS 16.2, *) {
                listenForContentUpdates(activityType, activity: activity)
            }
        }

        // Establish listeners for activity updates
        Task {
            Logger.log(message: "Dengage.LiveActivities listening for activity on: \(activityType)")
            for await activity in Activity<Attributes>.activityUpdates {
                if #available(iOS 16.2, *) {
                    // if there's already an activity with the same Dengage activityId, dismiss it before
                    // listening for the new activity's events.
                    for otherActivity in Activity<Attributes>.activities {
                        if activity.id != otherActivity.id && otherActivity.attributes.dengage.activityId == activity.attributes.dengage.activityId {
                            Logger.log(message: "Dengage.LiveActivities dismissing other activity: \(activityType):\(otherActivity.attributes.dengage.activityId):\(otherActivity.id)")
                            await otherActivity.end(nil, dismissalPolicy: ActivityUIDismissalPolicy.immediate)
                        }
                    }
                }

                listenForActivityStateUpdates(activityType, activity: activity, options: options)
                listenForActivityPushToUpdate(activityType, activity: activity, options: options)
                if #available(iOS 16.2, *) {
                    listenForContentUpdates(activityType, activity: activity)
                }
            }
        }
    }

    @available(iOS 16.1, *)
    private static func listenForActivityStateUpdates<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, activity: Activity<Attributes>, options: LiveActivitySetupOptions? = nil) {
        // listen for activity dismisses so we can forget about the token
        Task {
            Logger.log(message: "Dengage.LiveActivities listening for state update on: \(activityType):\(activity.attributes.dengage.activityId):\(activity.id)")
            for await activityState in activity.activityStateUpdates {
                switch activityState {
                case .dismissed:
                    DengageLiveActivitiesManagerImpl.exit(activity.attributes.dengage.activityId)
                case .active: break
                case .ended: break
                case .stale: break
                default: break
                }
            }
        }
    }

    @available(iOS 16.1, *)
    private static func listenForActivityPushToUpdate<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, activity: Activity<Attributes>, options: LiveActivitySetupOptions? = nil) {
        if options == nil || options!.enablePushToUpdate {

            /*
             Apple has confirmed that when using push-to-start, it is best to check both `Activity<...>.pushToken` in addition
             `Activity<...>.pushTokenUpdates` --- because your app may need to launch in the background and the launch time may end
             up being slower than the new values come in. In those cases, your task on the update sequence may start listening after
             the initial values were already provided.
             */

            // Set the initial pushToken (if one exists)
            if let pushToken = activity.pushToken {
                Logger.log(message: "Dengage.LiveActivities enter with existing pushToken for: \(activityType):\(activity.attributes.dengage.activityId):\(activity.id)")
                let token = pushToken.map {String(format: "%02x", $0)}.joined()
                DengageLiveActivitiesManagerImpl.enter(activity.attributes.dengage.activityId, withToken: token)
            }

            // listen for activity update token updates so we can tell Dengage how to update the activity
            Task {
                Logger.log(message: "Dengage.LiveActivities listening for pushToUpdate on: \(activityType):\(activity.attributes.dengage.activityId):\(activity.id)")
                for await pushToken in activity.pushTokenUpdates {
                    Logger.log(message: "Dengage.LiveActivities pushTokenUpdates observed for: \(activityType):\(activity.attributes.dengage.activityId):\(activity.id)")
                    let token = pushToken.map {String(format: "%02x", $0)}.joined()
                    DengageLiveActivitiesManagerImpl.enter(activity.attributes.dengage.activityId, withToken: token)
                }
            }
        }
    }

    @available(iOS 16.2, *)
    private static func listenForContentUpdates<Attributes: DengageLiveActivityAttributes>(_ activityType: Attributes.Type, activity: Activity<Attributes>) {
        Task {
            for await content in activity.contentUpdates {
                // Don't track a live activity started / updated "in app" without a notification
                if let notificationId = activity.content.state.dengage?.notificationId {
                    Logger.log(message: "Dengage.LiveActivities content update with notificationId: \(notificationId)")
                    // You can add receive receipt logic here if needed
                }
            }
        }
    }
}
#endif


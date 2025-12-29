import Foundation
import UserNotifications
import Dengage
#if targetEnvironment(macCatalyst)
#else
import ActivityKit

@objc
class DengageLiveActivityController: NSObject {

    @available(iOS 16.1, *)
    @objc
    static func start() {
        // ExampleAppFirstWidgetAttributes and ExampleAppSecondWidgetAttributes enable the Dengage SDK to
        // listen for start/update tokens, this is the only call needed.
        Dengage.setupLiveActivity(ExampleAppFirstWidgetAttributes.self)
        Dengage.setupLiveActivity(ExampleAppSecondWidgetAttributes.self)

        // There is a "built in" Live Activity Widget Attributes called `DefaultLiveActivityAttributes`.
        // This is mostly for cross-platform SDKs and allows Dengage to handle everything but the
        // creation of the Widget Extension.
        Dengage.setupDefaultLiveActivity()

        if #available(iOS 17.2, *) {
            // ExampleAppThirdWidgetAttributes is an example of how to manually set up LA.
            // Setup an async task to monitor and send pushToStartToken updates to DengageSDK.
            Task {
                for try await data in Activity<ExampleAppThirdWidgetAttributes>.pushToStartTokenUpdates {
                    let token = data.map {String(format: "%02x", $0)}.joined()
                    Dengage.setPushToStartToken(ExampleAppThirdWidgetAttributes.self, withToken: token)
                }
            }
            // Setup an async task to monitor for an activity to be started, for each started activity we
            // can then set up an async task to monitor and send updateToken updates to DengageSDK.  We
            // filter out LA started in-app, because the `createActivity` function below does its own
            // updateToken update monitoring. If there can be multiple instances of this activity-type,
            // the activity-id (i.e. "my-activity-id") is most likely passed down as an attribute within
            // ExampleAppThirdWidgetAttributes.
            Task {
                for await activity in Activity<ExampleAppThirdWidgetAttributes>.activityUpdates
                    where activity.attributes.isPushToStart {
                    Task {
                        for await pushToken in activity.pushTokenUpdates {
                            let token = pushToken.map {String(format: "%02x", $0)}.joined()
                            Dengage.enterLiveActivity("my-activity-id", withToken: token)
                        }
                    }
                }
            }
        }
    }

     /**
      An example of starting a Live Activity whose attributes are "Dengage SDK aware". The SDK will handle listening for update tokens on behalf of the app.
      */
     static var counter1 = 0
     @available(iOS 13.0, *)
     @objc
     static func createDengageAwareActivity(activityId: String) {
         if #available(iOS 16.1, *) {
             counter1 += 1
             let dengageAttribute = DengageLiveActivityAttributeData.create(activityId: activityId)
             let attributes = ExampleAppFirstWidgetAttributes(title: "#" + String(counter1) + " Dengage Dev App Live Activity", dengage: dengageAttribute)
             let contentState = ExampleAppFirstWidgetAttributes.ContentState(message: "Update this message through push or with Activity Kit")
             do {
                 _ = try Activity<ExampleAppFirstWidgetAttributes>.request(
                         attributes: attributes,
                         contentState: contentState,
                         pushType: .token)
             } catch let error {
                 print(error.localizedDescription)
             }
         }
     }

    /**
     An example of starting a Live Activity using the DefaultLiveActivityAttributes.  The SDK will handle listening for update tokens on behalf of the app.
     */
    @available(iOS 13.0, *)
    @objc
    static func createDefaultActivity(activityId: String) {
        if #available(iOS 16.1, *) {
            let attributeData: [String: Any] = ["title": "in-app-title"]
            let contentData: [String: Any] = ["message": ["en": "HELLO", "es": "HOLA"], "progress": 0.58, "status": "1/15", "bugs": 2]

            Dengage.startDefaultLiveActivity(activityId, attributes: attributeData, content: contentData)
        }
    }

    /**
     An example of starting a Live Activity whose attributes are **not** "Dengage SDK aware".  The app must handle listening for update tokens and notify the Dengage SDK.
     */
    static var counter2 = 0
    @available(iOS 13.0, *)
    @objc
    static func createActivity(activityId: String) async {
        if #available(iOS 16.1, *) {
            counter2 += 1
            let attributes = ExampleAppThirdWidgetAttributes(title: "#" + String(counter2) + " Dengage Dev App Live Activity", isPushToStart: false)
            let contentState = ExampleAppThirdWidgetAttributes.ContentState(message: "Update this message through push or with Activity Kit")
            do {
                let activity = try Activity<ExampleAppThirdWidgetAttributes>.request(
                        attributes: attributes,
                        contentState: contentState,
                        pushType: .token)
                for await data in activity.pushTokenUpdates {
                    let myToken = data.map {String(format: "%02x", $0)}.joined()
                    Dengage.enterLiveActivity(activityId, withToken: myToken)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
#endif


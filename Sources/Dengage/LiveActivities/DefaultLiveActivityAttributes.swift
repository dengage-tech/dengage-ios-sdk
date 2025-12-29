// Effectively blanks out this file for Mac Catalyst
#if targetEnvironment(macCatalyst)
#else

/**
 A default struct conforming to DengageLiveActivityAttributes which is registered with Dengage as a Live Activity
 through `Dengage.LiveActivities.setupDefault`.  The only action required by the customer app is
 to implement a Widget in their Widget Extension with an `ActivityConfiguration` for
 `DefaultLiveActivityAttributes`.  All properties (attributes and content-state) within this widget are
 dynamically defined as a dictionary of values within the static `data` property. Note that the `data` properties are
 required in the payloads.
 
 Example "start notification" payload using DefaultLiveActivityAttributes:
 ```
 {
   "name": "Live Activity Update XXXX",
   "event": "start",
   "activity_type": "DefaultLiveActivityAttributes",
   "event_attributes": {
       "data": {
         "yourAttributesKey": "yourAttributesValue"
       }
    },
   "event_updates": {
       "data": {
         "yourContentStateKey": "yourContentStateValue"
       }
   }
 }
 ```

 Example "update notification" payload using DefaultLiveActivityAttributes:
 ```
 {
   "name": "Live Activity Update XXXX",
   "event": "update",
   "event_updates": {
       "data": {
         "yourContentStateKey": "yourContentStateValue"
       }
   }
 }
 ```
 */
public struct DefaultLiveActivityAttributes: DengageLiveActivityAttributes {
    public struct ContentState: DengageLiveActivityContentState {
        public var data: [String: AnyCodable]
        public var dengage: DengageLiveActivityContentStateData?

    }

    public var data: [String: AnyCodable]
    public var dengage: DengageLiveActivityAttributeData
}
#endif


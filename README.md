# Dengage IOS SDK

## Table of Contents

- [SDK Setup](#sdk-setup)
  - [Requirements](#requirements)
  - [SDK Installation](#sdk-installation)
    - [CocoaPods Integration](#cocoapods-integration)
    - [SPM Integration](#spm-integration)
  - [Endpoint Configuration](#endpoint-configuration)
- [Integration](#integration)
  - [Initialization](#initialization)
  - [Logging](#logging)
- [User Profiles](#user-profiles)
  - [Contact Key](#contact-key)
  - [setDeviceId](#setDeviceId)
- [User Events](#user-events)
  - [Login](#login)
    - [Set Contact Key](#set-contact-key)
    - [Get Contact Key](#get-contact-key)
  - [eCommerce Events](#ecommerce-events)
    - [Page View Events](#page-view-events)
    - [Shopping Cart Events](#shopping-cart-events)
    - [Order Events](#order-events)
    - [Search Event](#search-event)
    - [Wishlist Events](#wishlist-events)
  - [Custom Events](#custom-events)
- [Push Notifications](#push-notifications)
  - [Setup](#setup)
    - [APNS Setup](#apns-setup)
    - [AppDelegate](#appdelegate)
    - [Notification Service Extension](#notification-service-extension)
      - [CocoaPods](#cocoapods)
      - [SPM](#spm)
      - [Code](#code)
  - [Subscription](#subscription)
  - [Asking User Permission for Notification](#asking-user-permission-for-notification)
  - [getDeviceToken](#getdevicetoken)
  - [User Permission Management (optional)](#user-permission-management-optional)
  - [Carousel Push](#carousel-push)
- [Live Activities](#live-activities)
  - [How It Works](#how-it-works)
  - [Requirements](#live-activities-requirements)
  - [Permissions](#live-activities-permissions)
  - [Defining the Activity Attributes](#defining-the-activity-attributes)
  - [Creating the Widget](#creating-the-widget)
  - [Registering with the SDK](#registering-with-the-sdk)
  - [Starting an Activity](#starting-an-activity)
  - [Updating and Ending via Push](#updating-and-ending-via-push)
- [App Inbox](#app-inbox)
    - [Methods](#methods)
        - [Getting Inbox Messages](#getting-inbox-messages)
        - [Removing an Inbox Message](#removing-an-inbox-message)
        - [Removing all Inbox Messages](#removing-all-inbox-messages)
        - [Marking an Inbox Message as Clicked](#marking-an-inbox-message-as-clicked)
        - [Marking all Inbox Messages as Clicked](#marking-all-inbox-messages-as-clicked)
- [In-App Messaging](#in-app-messaging)
    - [Methods](#methods-1)
    - [Real Time In-App Messaging](#real-time-in-app-messaging)
    - [Custom Device Information for In-App Messages](#custom-device-information-for-in-app-messages)
    - [In-App Inline](#in-app-inline)
    - [App Stories](#app-stories)
- [Geofence](#geofence)
  - [Geofence Installation](#geofence-installation)
  - [Geofence Initialization](#geofence-initialization)
  - [Request Location Permission](#request-location-permission)
  - [Geofence Interceptor](#geofence-interceptor)


## SDK Setup

### Requirements

- Minimum iOS version supported `11.0`

### SDK Installation

#### CocoaPods Integration

**Dengage** is available through CocoaPods.

To install it, simply add the following line to your **Podfile**:

```ruby
pod 'Dengage', '~> 5.100'
```

Run `pod install` via terminal

#### SPM Integration

Installing the iOS SDK via Swift Package Manager (SPM) automates the majority of the installation process for you. Before beginning this process, ensure that you are using Xcode 12 or greater.

Open your project and navigate to your project's settings. Select the tab named Package Dependencies and click on the add button (+) at the bottom left.

Enter the URL of our iOS SDK repository in the text field and click Add Package.

Paste URL: https://github.com/dengage-tech/dengage-ios-sdk.git

Select the latest branch. You can find the latest released branch here https://github.com/dengage-tech/dengage-ios-sdk/tags

On the next screen, select the SDK version and click Add Package.

Select the package and click finish.

The Dengage SDK is organized into 2 modules, allowing you to import only what you need:

1. **Dengage**: If you don’t plan to use the geofence feature, simply include the `Dengage` module.
2. **DengageGeofence**: To enable geofence functionality, add the `DengageGeofence` module in addition to the `Dengage` module.

| **Module**      | **Description**                                                                              |
| --------------- | -------------------------------------------------------------------------------------------- |
| Dengage         | Core module required for analytics, in-app messaging and APNS messaging service integration. |
| DengageGeofence | Enables geofence features.                                                                   |

### Endpoint Configuration

For the initial setup, if you have been provided with URL addresses by the **Dengage Support Team**, you need to configure these URLs in the `Info.plist` file.

Refer to the [API Endpoints By Datacenter](https://dev.dengage.com/reference/api-endpoints-by-datacenter) section to correctly set your API endpoints.

Here’s an example configuration:

```xml
<key>DengageApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageDeviceIdApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageEventApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageGeofenceApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageInAppApiUrl</key>
<string>https://your_api_endpoint</string>
<key>fetchRealTimeINAPPURL</key>
<string>https://your_api_endpoint</string>
```

**Note:** Ensure the URLs match the ones provided by the Dengage Support Team and are appropriate for your data center.


## Integration

### Initialization


`start` method should be called once at the beginning of your application's lifecycle to initialize the Dengage SDK. It is recommended to place it inside the `application(_:didFinishLaunchingWithOptions:)` method of your `AppDelegate` class.

> **Recommendation:** Call it inside the `AppDelegate` class's `didFinishLaunchingWithOptions` method.


```swift
let dengageOptions = DengageOptions(
    disableOpenURL: false,
    badgeCountReset: false,
    disableRegisterForRemoteNotifications: false
)

Dengage.start(
    apiKey: "your-api-integration-key",
    application: application,
    launchOptions: launchOptions,
    dengageOptions: dengageOptions
)
```

| **Parameter Name** | **Description**                                                                                                                        |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| **apiKey**         | The integration key generated by the CDMP Platform while defining the application. It is a hash string containing application details. |
| **application**    | The `UIApplication` instance passed to the `application(_:didFinishLaunchingWithOptions:)` method in `AppDelegate`.                    |
| **launchOptions**  | The launch options dictionary passed to the `application(_:didFinishLaunchingWithOptions:)` method in `AppDelegate`.                   |
| **dengageOptions** | Configuration options for the Dengage SDK. See below for details.                                                                      |

The `DengageOptions` parameter allows you to configure various Dengage SDK settings:

| **Option**                              | **Description**                                                                                                  |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `disableOpenURL`                        | Prevents links from opening in Safari when clicked in push notifications.                                        |
| `badgeCountReset`                       | Resets the app badge count when the push notification is clicked.                                                |
| `disableRegisterForRemoteNotifications` | Disables automatic push notification registration. In this case, you should be doing it in the application code. |


### Logging

You can enable or disable logs comes from Dengage SDK.

```swift
Dengage.setLog(isVisible: true)
```

## User Profiles


### Contact Key

The **Contact Key** serves as a bridge between **Devices** and **Contacts**. Devices can be categorized into two types:

1. **Anonymous Devices**
2. **Contact Devices** (which include a Contact Key)

To associate devices with their respective contacts, the **Contact Key** must be set in the SDK.

> **Recommended Usage:**  
> You should call this method if you have user information.
> It is recommended to call this method during every app launch, as well as on login and logout pages.

```swift
Dengage.set(contactKey: "contact-key")
```

### setDeviceId

You can set a unique device id of for current device. This id will be used to identify the device in the Dengage system.

```swift
Dengage.set(deviceId: "unique-identifier-of-device")
```

## User Events

In order to collect app events and use that data to create behavioral segments in Dengage you have to determine the type of events and data that needs to collect. Once you have determined that, you will need to create a “Big Data” table in Dengage. Collected events will be stored in this table. Multiple tables can be defined depending on your specific need.

Any type of event can be collected. The content and the structure of the events are completely flexible and can be changed according to unique business requirements. You will just need to define a table for events.

Once defined, all you have to do is to send the event data to these tables. Dengage SDK has only 2 functions for sending events: `sendDeviceEvent` and `sendCustomEvent`. Most of the time you will just need the sendDeviceEvent function.

For eCommerce accounts, there are predefined event tables. And you can feed these tables by using eCommerce event functions.

### Login

If the user logs in or you have user information, this means you have `contact_key` for that user. You can set `contact_key` in order to match user with the device.

#### Set Contact Key

If user logged in set user id. This is important for identifying your users. You can put this function call in every page. It will not send unnecessary events.

```swift
Dengage.set(contactKey: "contact-key")
```

#### Get Contact Key

If you need to get contact key of current user from SDK use the function below:

```swift
Dengage.getContactKey()
```

### eCommerce Events

If your Dengage account is an eCommerce account, you should use standard eCommerce events in the SDK. If you need some custom events or your account is not a standard eCommerce account, you should use custom event functions.

Dengage SDK includes standard eCommerce events:

- **Page View Events**:
  - Home page view
  - Product page view
  - Category page view
  - Promotion page view
  - ...
- **Shopping Cart Events**:
  - Add to cart
  - Remove from cart
  - View cart
  - Begin checkout
- **Order Events**:
  - Order
  - Cancel order
- **Wishlist Events**:
  - Add to wishlist
  - Remove from wishlist
- **Search Event**

Each event corresponds to related tables in your account.

#### Page View Events

Page view events are sent to the `page_view_events` table. If you've added new columns to this table, include them in the event data.

```swift
// Home page view
Dengage.pageView(parameters: [
    "page_type": "home"
    // ... extra columns in page_view_events table, can be added here
])

// Product page view
Dengage.pageView(parameters: [
    "page_type": "product",
    "product_id": "1"
    // ... extra columns in page_view_events table, can be added here
])

// Category page view
Dengage.pageView(parameters: [
    "page_type": "category",
    "category_id": "1"
    // ... extra columns in page_view_events table, can be added here
])

// Promotion page view
Dengage.pageView(parameters: [
    "page_type": "promotion",
    "promotion_id": "1"
    // ... extra columns in page_view_events table, can be added here
])

// Custom page view
Dengage.pageView(parameters: [
    "page_type": "custom"
    // ... extra columns in page_view_events table, can be added here
])
```

> For other pages you can send anything as page_type

#### Shopping Cart Events

These events are stored in `shopping_cart_events` and `shopping_cart_events_detail` tables. The following functions are available for shopping cart events:

1. `addToCart`
2. `removeFromCart`
3. `viewCart`
4. `beginCheckout`

```swift
// Add To Cart
let params = [
    "product_id": 1,
    "product_variant_id": 1,
    "quantity": 1,
    "unit_price": 10.00,
    "discounted_price": 9.99,
    // ... extra columns in shopping_cart_events table, can be added here
]
Dengage.addToCart(parameters : params)

// Remove From Cart
let params = [
    "product_id": 1,
    "product_variant_id": 1,
    "quantity": 1,
    "unit_price": 10.00,
    "discounted_price": 9.99,
    // ... extra columns in shopping_cart_events table, can be added here
]
Dengage.removeFromCart(parameters : params)

// View Cart
let params = [
    // ... extra columns in shopping_cart_events table, can be added here
]
Dengage.viewCart(parameters: params);

// Begin Checkout
let params = [
    // ... extra columns in shopping_cart_events table, can be added here
]
Dengage.beginCheckout(parameters: params)
```

#### Order Events

Order events are stored in `order_events` and `order_events_detail` tables.

```swift
// Paid Order
var params: [String: Any] = [
    "order_id": 1,
    "item_count": 1, // total ordered item count
    "total_amount": 1, // total price
    "discounted_price": 9.99, // use total price if there is no discount
    "payment_method": "card",
    "shipping": 5,
    "coupon_code": ""
]
Dengage.order(parameters : params)

// Cancel Order
var params = [
    "order_id": 1, // canceled order id
    "item_count": 1, // canceled total item count
    "total_amount": 1, // canceled item's total price
    "discounted_price": 9.99, // use total price if there is no discount
    // ... extra columns in order_events table, can be added here
]
Dengage.cancelOrder(parameters : params)
```

#### Search Event

Search events are stored in the `search_events` table.

```swift
var params: [String: Any] = [
    "keywords": "some product name", // text in the searchbox
    "result_count": 12,
    "filters": "" // you can send extra filters selected by the user here
    // ... extra columns in search_events table, can be added here
]
Dengage.search(parameters : params)
```

#### Wishlist Events

These events are stored in `wishlist_events` and `wishlist_events_detail` tables. The available functions are:

1. `addToWishlist`
2. `removeFromWishlist`

You can send all items in the wishlist for every event, simplifying the tracking of the current wishlist items.

```swift
// Add To Wishlist
var params = [
    "product_id":1,
    // ... extra columns in wishlist_events table, can be added here
]
Dengage.addToWithList(parameters : params)

// Remove From Wishlist
var params = [
    "product_id":1,
    // ... extra columns in wishlist_events table, can be added here
]
Dengage.removeFromWithList(parameters : params)
```

### Custom Events

Use the `sendDeviceEvent` function to send events specific to a device. Events are sent to a big data table defined in your D·engage account, which must have a relation to the `master_device` table. If you set a `contact_key` for that device, collected events will be associated with the user.

```swift
// For example, if you have a table named "events"
// and the events table has "key", "event_date", "event_name", "product_id" columns
// You only need to send the columns except "key" and "event_date", as those are sent by the SDK

let params = [
    "event_name": "page_view",
    "product_id": "12345",
]
Dengage.sendCustomEvent(eventTable: "events", parameters: params)
```






## Push Notifications


### Setup

#### APNS Setup

Complete the [APNS iOS Setup](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns) to configure your iOS application for push notifications.

#### AppDelegate

Set up the `AppDelegate` class to handle push notifications. The following code snippets demonstrate how to handle push notifications in your application.

```swift
import UIKit
import Dengage

class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self

    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Dengage.register(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Dengage.didReceive(with: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void){
        Dengage.didReceivePush(center, response, withCompletionHandler: completionHandler)
    }

    final func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
```

#### Notification Service Extension

To handle push messages, you need to include the **Notification Service Extension** in your project. This extension is used to modify the content of remote notifications before they are displayed to the user. Place the following block inside the `<extensions>` tag of your `Info.plist` file to ensure proper integration:

```xml
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.usernotifications.service</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).NotificationService</string>
</dict>
```

##### CocoaPods

Add the Dengage SDK to your Notification Service Extension target in your `Podfile`:

```ruby
target 'DengageNotificationServiceExtension' do
    pod 'Dengage', '~> 5.100'
end
```

> Make sure the version of the SDK matches the version in your main target.

Run `pod install` via terminal

##### SPM

Open your project and navigate to your project's settings. Select the tab named Package Dependencies and click on the add button (+) at the bottom left.

Enter the URL of our iOS SDK repository in the text field and click Add Package.

Paste URL: https://github.com/dengage-tech/dengage-ios-sdk.git

Select the latest branch. You can find the latest released branch here https://github.com/dengage-tech/dengage-ios-sdk/tags

On the next screen, select the SDK version and click Add Package. Select your Notification Service Extension target and click finish.

##### Code

Modify the `NotificationService.swift` file to include the Dengage SDK. This file is used to handle push notifications and is automatically generated when you add the Notification Service Extension to your project. Replace the contents of the file with the following code:

```swift
import UserNotifications
import Dengage

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if #available(iOS 15.0, *) {
            bestAttemptContent?.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
        Dengage.didReceiveNotificationRequest(bestAttemptContent, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

### Subscription

`Subscription` is self-managed by SDK.

> **Definition**: Subscription is a process which is triggered by sending subscription event to Dengage. It contains necessary information about application to send push notifications to clients.

The SDK automatically sends subscription events in the following scenarios:

1. Initialization
2. Setting Contact Key
3. Setting Token
4. Setting User Permission (if permissions are manually managed)


### Asking User Permission for Notification

> Note: Android doesn't require to ask for push notifications explicitly. Therefore, you can only ask for push notification's permissions on iOS.

IOS uses shared `UNUserNotificationCenter` by itself while asking user to send notification. Dengage SDK manager uses `UNUserNotificationCenter` to ask permission as well.

> Referrer: [Apple Docs](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications)

If in your application, you want to get notification permissions explicitly, you can do by calling one of the following methods:

```swift
Dengage.promptForPushNotifications()

//OR
Dengage.promptForPushNotifications(completion: { isUserGranted in
    
})
```

### getDeviceToken

Retrieve the token for the current user’s subscription using this method.

```swift
let currentToken = Dengage.getDeviceToken()
```

### User Permission Management (optional)

If you manage your own user permission states on your application you may send user permission by using setUserPermission method.

```swift
// Use to set permission of current subscription
Dengage.set(permission: true)

// Use to get permission of current subscription
let permission = Dengage.getPermission() // Bool
```

### Carousel Push

To handle carousel push messages, you need to include the **Notification Content Extension** in your project. This extension is used to customize the appearance of your app’s notifications.

Change the `Info.plist` file of your **Notification Content Extension** target to include the following block:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>UNNotificationExtensionCategory</key>
        <string>DENGAGE_CAROUSEL_CATEGORY</string>
        <key>UNNotificationExtensionDefaultContentHidden</key>
        <true/>
        <key>UNNotificationExtensionInitialContentSizeRatio</key>
        <real>1</real>
        <key>UNNotificationExtensionUserInteractionEnabled</key>
        <true/>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.usernotifications.content-extension</string>
    <key>NSExtensionPrincipalClass</key>
    <string>NotificationContentExtension.NotificationViewController</string>
</dict>
<key>DengageApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageDeviceIdApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageEventApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageGeofenceApiUrl</key>
<string>https://your_api_endpoint</string>
<key>DengageInAppApiUrl</key>
<string>https://your_api_endpoint</string>
<key>fetchRealTimeINAPPURL</key>
<string>https://your_api_endpoint</string>
```

You need add Dengage SDK to your **Notification Content Extension** target as described in the **Notification Service Extension** section.

Open `NotificationViewController.swift` and replace the whole file contents with the below code.

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import Dengage
@objc(NotificationViewController)

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    let carouselView = DengageNotificationCarouselView.create()
    
    func didReceive(_ notification: UNNotification) {
        Dengage.setIntegrationKey(key: "your-api-integration-key")
        carouselView.didReceive(notification)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        carouselView.didReceive(response, completionHandler: completion)
    }
    
    override func loadView() {
        self.view = carouselView
    }
}
```


## Live Activities

Live Activities let you display real-time, glanceable information on the Lock Screen and in the Dynamic Island for an ongoing activity — such as a delivery, a live score, or a ride. Dengage drives Live Activities through ActivityKit and APNs: the SDK captures and synchronizes the **push-to-start** and **update** tokens on your behalf, and the Dengage backend sends the start/update/end pushes.

### How It Works

You define an `ActivityAttributes` structure that conforms to `DengageLiveActivityAttributes`, build a Live Activity widget for it in a Widget Extension, and register the type with `Dengage.setupLiveActivity(_:)`. From there:

- The SDK listens for the **push-to-start token** (iOS 17.2+) so the activity can be started remotely from Dengage.
- When an activity starts, the SDK listens for its **update token** so the activity can be updated/ended remotely.
- The `dengage` attribute carries the `activityId` Dengage uses to target the right activity.

You only build the widget UI and register the type — token capture and synchronization are handled by the SDK.

<a name="live-activities-requirements"></a>
### Requirements

- iOS **16.1+** for Live Activities; **17.2+** for remote push-to-start.
- A **Widget Extension** in your app containing an `ActivityConfiguration` for your attributes type.
- `NSSupportsLiveActivities` set to `YES` in the **app target's** `Info.plist`.
- The `ActivityAttributes` struct must be a member of **both** the app target and the Widget Extension target (otherwise the widget fails to compile with "Cannot find ... in scope").

<a name="live-activities-permissions"></a>
### Permissions

Live Activities do **not** require the standard notification permission. Showing and updating a Live Activity works independently of `UNUserNotificationCenter` authorization, so you do **not** need to call `requestAuthorization` (alert/badge/sound) for this feature — a Live Activity still appears and updates even if the user declined notifications.

What is actually involved:

| Item | Required? | Notes |
|------|-----------|-------|
| Notification permission (`requestAuthorization`) | ❌ No | Not needed to show or push-update Live Activities. |
| Live Activities enabled (`areActivitiesEnabled`) | ✅ Yes | **On by default** — there is no prompt. The user can turn it off in **Settings → (app) → Live Activities**; when off, nothing is shown. |
| Push Notifications capability (APNs) | ✅ For push | A developer-side capability/entitlement, not a user prompt. Needed to receive remote start/update/end pushes. |
| `NSSupportsLiveActivities = YES` | ✅ Yes | In the app target's `Info.plist`. |

Because Live Activities are enabled by default, there is no permission dialog to present. You can, however, check the current state before relying on the feature:

```swift
if #available(iOS 16.1, *) {
    let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
    print("Live Activities enabled: \(enabled)")
}
```

> **Note**: If `areActivitiesEnabled` is `false`, the user has disabled Live Activities for your app in Settings. In that case activities won't appear even though an APNs push may still return a `200` status — so this is a useful first check when a Live Activity does not show.

### Defining the Activity Attributes

Conform your attributes to `DengageLiveActivityAttributes` and your content state to `DengageLiveActivityContentState`. Both reserve a `dengage` field used by the SDK.

```swift
import ActivityKit
import Dengage

@available(iOS 16.1, *)
struct DeliveryActivityAttributes: DengageLiveActivityAttributes {
    // Reserved by Dengage — carries the activityId used to target updates.
    var dengage: DengageLiveActivityAttributeData

    // Your static attributes:
    var orderId: String

    struct ContentState: DengageLiveActivityContentState {
        // Reserved by Dengage (optional) — populated by the backend on updates.
        var dengage: DengageLiveActivityContentStateData?

        // Your dynamic content:
        var status: String
        var etaMinutes: Int
    }
}
```

> **Note**: Put this file in a location shared by the app and the Widget Extension, and enable **Target Membership** for both targets (File Inspector → Target Membership).

### Creating the Widget

Add a Live Activity widget for the attributes type in your Widget Extension and register it in your `WidgetBundle`.

```swift
import WidgetKit
import SwiftUI
import ActivityKit

@available(iOS 16.1, *)
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryActivityAttributes.self) { context in
            // Lock Screen / banner UI
            VStack(alignment: .leading) {
                Text("Order #\(context.attributes.orderId)")
                Text("\(context.state.status) · ETA \(context.state.etaMinutes) min")
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.status)
                }
            } compactLeading: {
                Text("🚚")
            } compactTrailing: {
                Text("\(context.state.etaMinutes)m")
            } minimal: {
                Text("🚚")
            }
        }
    }
}
```

```swift
@main
struct MyWidgetBundle: WidgetBundle {
    var body: some Widget {
        DeliveryLiveActivity()
    }
}
```

### Registering with the SDK

Register each attributes type once, after initializing Dengage (for example in `application(_:didFinishLaunchingWithOptions:)`). This is the only call needed — Dengage captures and synchronizes both the push-to-start and update tokens.

```swift
import Dengage

if #available(iOS 16.1, *) {
    Dengage.setupLiveActivity(DeliveryActivityAttributes.self)
}
```

This single call is all most apps need — the SDK captures and synchronizes both the push-to-start and update tokens for the registered type.

### Starting an Activity

Once a type is registered with `setupLiveActivity`, the device reports its **push-to-start token** to Dengage (iOS 17.2+), so an activity can be **started remotely** from Dengage — no extra in-app code is required. When an activity starts, the SDK automatically captures its **update token**, making it eligible for remote updates.

### Updating and Ending via Push

Updates and the final end event are delivered as APNs Live Activity pushes sent by Dengage to the activity's update token (synchronized by the SDK). The push `content-state` must decode into your `ContentState`, so make sure the fields the backend sends match your struct. The `dengage` field in attributes/content state is reserved and populated by the backend to target the correct activity.

## App Inbox

App Inbox is a screen within a mobile app that stores persistent messages. It's kind of like an email inbox, but it lives inside the app itself. App Inbox differs from other mobile channels such as push notifications or in-app messages. For both push and in-app messages, they're gone once you open them.

In other words, Dengage admin panel lets you keep selected messages on the platform and Mobile SDK may receive and display these messages when needed.

In order to save messages into App Inbox, you need to select the "Save to Inbox" option when sending messages in D·engage the admin panel by assigning an expiration date to it.

After selecting your Push content, you must activate the "Save To Inbox" option.

> To use the app inbox feature, please send an email to tech@dengage.com.

Inbox messages are kept in the memory storage of the phone until the app is completely closed or for a while and Dengage SDK provides functions for getting and managing these messages.

### Methods

When a push message is received with the `addToInbox` parameter, the message is saved during the notification building stage, allowing users to access these messages later. The following methods facilitate interaction with these messages:

#### Getting Inbox Messages

Retrieve stored inbox messages with pagination:

```swift
Dengage.getInboxMessages(offset: 0, // Starting point for retrieval
                        limit: 20, // Number of messages to retrieve
                        completion: { result in
    switch result {
    case .success(let messages):
        // Handle the result
        print(messages)
        // Handle the error
    case .failure(let error):
        print(error)
    }
})
```

#### Removing an Inbox Message

Delete a specific inbox message:

```swift
Dengage.deleteInboxMessage(with: "message-id", // ID of the message to delete
                           completion: { result in
    switch result {
    case .success:
        print("Message deleted successfully!")
    case .failure(let error):
        print("Failed to delete message: \(error)")
    }
})
```

#### Removing all Inbox Messages

Delete all inbox messages:

```swift
Dengage.deleteAllInboxMessages(completion: { result in
    switch result {
    case .success:
        print("All messages deleted successfully!")
    case .failure(let error):
        print("Failed to delete all messages: \(error)")
    }
})
```

#### Marking an Inbox Message as Clicked

Mark a message as clicked to update its status:

```swift
Dengage.setInboxMessageAsClicked(with: "message-id", // ID of the message to mark as clicked
                                completion: { result in
    switch result {
    case .success:
        print("Message marked as clicked successfully!")
    case .failure(let error):
        print("Failed to mark message as clicked: \(error)")
    }
})
```

#### Marking all Inbox Messages as Clicked

Mark all inbox messages as clicked to update their status:

```swift
Dengage.setAllInboxMessageAsClicked(completion: { result in
    switch result {
    case .success:
        print("All messages marked as clicked successfully!")
    case .failure(let error):
        print("Failed to mark all messages as clicked: \(error)")
    }
})
```

> `receiveDate` property is used to store inbox message receive date. It keeps date as a UTC time format ("yyyy-MM-ddTHH:mm:ss.fffZ"). The applications which are using our SDKs need to convert this UTC date to the client time zone if the applications want to display the message receive date to their users.



## In-App Messaging

An in-app message is a type of mobile message where the notification is displayed within the app. It is not sent at a specific time but it is shown to users when the user is using the app.

Examples include popups, yes/no prompts, banners, and more.

In order to show in-app messages, there is no permit requirement.

### Methods

Created messages will be stored in Dengage backend and will be served to mobile SDKs.

If you integrated mobile SDK correctly for push messages, for using in-app features you just have to add `setNavigation` function to every page navigation.

If you want to use a screen name filter, you should send the screen name to `setNavigation` function in every page navigation.

You should pass the current activity to setNavigation function.

```swift
// Without screen filter
Dengage.setNavigation()

// With screen filter
 Dengage.setNavigation(screenName: "screen-name")
```

### Real Time In-App Messaging

You can use the real time in-app functionality by using the function.

```swift
let customParams = [String: String]()
Dengage.showRealTimeInApp(
    screenName: "screen-name", // For filtering in app messages with respect to current screen in your app(optional)
    params: customParams // For filtering in app messages with respect to custom parameters(optional)
)

// Set cart for using in real time in app comparisons
let cart = Cart(items: [CartItem(
    productId: "product123",
    productVariantId: "variant456",
    categoryPath: "Electronics/Phones",
    price: 999,
    discountedPrice: 799,
    hasDiscount: true,
    hasPromotion: false,
    quantity: 2,
    attributes: ["color": "black", "storage":"128GB"]
)])
Dengage.setCart(cart: cart)

// Set category path for using in real time in app comparisons
Dengage.setCategory(path: "category-path")

// Set cart item count for using in real time in app comparisons
Dengage.setCart(itemCount: "cart-item-count")

// Set cart amount for using in real time in app comparisons
Dengage.setCart(amount: "cart-amount")

// Set state for using in real time in app comparisons
Dengage.setState(name: "state-name")

// Set city for using in real time in app comparisons
Dengage.setCity(name: "city-name")
```

### Custom Device Information for In-App Messages

You can set custom device information that will be available in your in-app message templates using Mustache templating.

```swift
// Set custom device information
Dengage.setInAppDeviceInfo(key: "user_level", value: "premium")
Dengage.setInAppDeviceInfo(key: "theme", value: "dark")

// Clear all custom device information
Dengage.clearInAppDeviceInfo()
```

The custom device information you set will be accessible in your in-app message HTML content through the `dnInAppDeviceInfo` object. For example, in your in-app message template, you can use:

```html
<div>Welcome {{#dnInAppDeviceInfo.user_level}}{{.}}{{/dnInAppDeviceInfo.user_level}} user!</div>
<div>You are using {{#dnInAppDeviceInfo.theme}}{{.}}{{/dnInAppDeviceInfo.theme}} app theme</div>
```

### In-App Inline

The **In-App Inline** feature allows you to seamlessly integrate inline in-app messages into your app's content, dynamically populating specific parts of your app for a better user experience.


```swift
var inappInlineView: InAppInlineElementView = {
    let wv = InAppInlineElementView.init(frame: CGRect.init(x: 20, y: 380, width: UIScreen.main.bounds.width - 40,
                                        height: UIScreen.main.bounds.height - 420))
    wv.translatesAutoresizingMaskIntoConstraints = false
    wv.contentMode = .scaleAspectFit
    wv.sizeToFit()
    wv.autoresizesSubviews = true
    wv.backgroundColor = .green
    return wv
}()


Dengage.showInAppInLine(propertyID: "property-id",
                        inAppInlineElement: inappInlineView,
                        screenName: "screen-name",
                        customParams: customParams,
                        hideIfNotFound: true
)
```

Parameters:

- **`inAppInlineElement`** An instance of `InAppInlineElementView` that will display the inline in-app message.
- **`propertyID`** The IOS selector linked to the in-app inline campaign created in the Dengage panel.
- **`customParams`** _(optional)_ A `Dictionary` of custom parameters used for filtering inline messages.
- **`screenName`** _(optional)_ Specifies the screen where the inline in-app message will be displayed.
- **`hideIfNotFound`** _(optional, default: `false`)_ If set to `true`, the `InAppInlineElementView` will be hidden if no inline message is found.


### App Stories

The **App Stories** feature allows you to display story-like content within your app.

The `showAppStory` method accepts a completion handler that yields an optional `StoriesListView` reference – this callback returns `nil` when no App Stories match the specified parameters.

```swift
Dengage.showAppStory(storyPropertyID: storyPropertyID,
                        storiesListView: storiesListView,
                        screenName: screenName,
                        customParams: customParams,
                        hideIfNotFound: true
) { storiesListView in
    
    if let storiesListView = storiesListView {
        self.view.addSubview(storiesListView)
    }
})
```

Parameters:

- **`screenName`** _(optional)_ Specifies the screen where the app stories should be displayed.
- **`storyPropertyID`** The story property ID associated with the app stories campaign created in the Dengage panel.
- **`customParams`** _(optional)_ A `Dictionary` of custom parameters used for filtering stories.
- **`storyCompletion`** A completion handler that yields an optional `StoriesListView` reference.


## Geofence

### Geofence Installation

**DengageGeofence** is available through CocoaPods. 

To install it, simply add the following line to your **Podfile**:

```ruby
pod 'Dengage', '~> 5.100'
pod 'DengageGeofence', '~> 5.100'
```

Run `pod install` via terminal

> Ensure the `DengageGeofence` version matches the `Dengage` version.

To install the SDK via Swift Package Manager (SPM), follow the same steps as the Dengage SDK installation.

> Ensure the `DengageGeofence` version matches the `Dengage` version.

To enable location services you should add the following keys to your `Info.plist` file:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app uses location services to enhance your app experience</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location services to enhance your app experience</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
    <string>remote-notification</string>
</array>
```


### Geofence Initialization

After initializing the core SDK with `Dengage.init`, you can enable geofence by calling the `DengageGeofence.startGeofence` method in your `AppDelegate` class.

```swift
import DengageGeofence

DengageGeofence.startGeofence()
```

### Request Location Permission

To request location permissions at runtime, use the `DengageGeofence.requestLocationPermissions` method.

```swift
DengageGeofence.requestLocationPermissions()
```

### Geofence Interceptor

The `DengageGeofenceInterceptor` protocol lets your app react when the user enters a monitored geofence region. This is useful when you want to run custom logic on a geofence trigger — for example, posting a local notification, logging analytics, or updating in-app state.

1. Conform your class (typically `AppDelegate`) to `DengageGeofenceInterceptor`.
2. Assign it to `DengageGeofence.geofenceInterceptor` **before** calling `DengageGeofence.startGeofence()`.
3. Implement `onGeofenceEnter(...)` to handle the event.

```swift
import Dengage
import DengageGeofence

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Dengage.start(apiKey: "your-api-key",
                      application: application,
                      launchOptions: launchOptions,
                      dengageOptions: DengageOptions())

        DengageGeofence.geofenceInterceptor = self
        DengageGeofence.startGeofence()

        return true
    }
}

// MARK: - DengageGeofenceInterceptor
extension AppDelegate: DengageGeofenceInterceptor {
    func onGeofenceEnter(latitude: Double,
                         longitude: Double,
                         radius: Double,
                         clusterId: Int,
                         clusterName: String?,
                         geofenceItemId: Int,
                         geofenceItemName: String?) {
        print("GeofenceInterceptor enter | lat=\(latitude), lon=\(longitude), radius=\(radius), clusterId=\(clusterId), clusterName=\(clusterName ?? "nil"), itemId=\(geofenceItemId), itemName=\(geofenceItemName ?? "nil")")
    }
}
```

#### Callback Parameters

| Parameter           | Type      | Description                                                                       |
|---------------------|-----------|-----------------------------------------------------------------------------------|
| `latitude`          | `Double`  | Latitude of the geofence region's center.                                         |
| `longitude`         | `Double`  | Longitude of the geofence region's center.                                        |
| `radius`            | `Double`  | Radius of the geofence region, in meters.                                         |
| `clusterId`         | `Int`     | Identifier of the geofence cluster the region belongs to.                         |
| `clusterName`       | `String?` | Human-readable name of the cluster, if provided on the server side.               |
| `geofenceItemId`    | `Int`     | Identifier of the specific geofence item that was entered.                        |
| `geofenceItemName`  | `String?` | Human-readable name of the geofence item, if provided on the server side.        |

> **Note**: The interceptor only adds your custom behavior; it does **not** replace the SDK's built-in geofence event reporting. The SDK will continue to send geofence events to Dengage regardless of whether an interceptor is registered.

### Performance Considerations and Best Practices

Geofence usage can have significant impacts on your application's performance and battery consumption. Here are important considerations:

#### App Launch Behavior

When a geofence is triggered while the app is not running (terminated state), iOS launches the app in the background and calls the `application(_:didFinishLaunchingWithOptions:)` method. This has important implications:

- **Initialization Order**: All code in `didFinishLaunchingWithOptions` will execute when a geofence triggers, even if the user hasn't explicitly opened the app. Ensure your initialization code handles this scenario gracefully.
- **Heavy Operations**: Avoid placing heavy synchronous operations (large data loads, complex UI setup, network calls that block the main thread) at the beginning of `didFinishLaunchingWithOptions`. These will delay geofence event processing and may cause the system to terminate your app.
- **Launch Options Check**: You can check if the app was launched due to a location event:

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let _ = launchOptions?[.location] {
        // App was launched due to a location event (geofence trigger)
        // Perform minimal initialization here
        initializeEssentialServicesOnly()
    } else {
        // Normal app launch
        initializeAllServices()
    }

    return true
}
```

- **Background Execution Time**: When launched in the background, your app has limited execution time (~10 seconds). Perform only essential operations and defer non-critical tasks.

#### How DengageGeofence SDK Works

DengageGeofence SDK uses iOS's native region monitoring capabilities with the following characteristics:

- **Region Monitoring**: The SDK uses `CLLocationManager`'s region monitoring (not continuous GPS tracking), which is battery-efficient as iOS handles geofence detection at the system level.
- **Maximum 20 Regions**: iOS limits apps to monitor up to 20 regions simultaneously. The SDK automatically manages this limit by selecting the 20 nearest geofences to the user's current location.
- **Automatic Region Updates**: When the user moves, the SDK recalculates and updates the monitored regions to always track the nearest 20 geofences from the server.
- **Low-Power Location Manager**: The SDK uses a secondary low-power location manager with 3km accuracy for background location updates, minimizing battery impact.
- **Rate Limiting**: Geofence data is fetched from the server at most every 15 minutes, and event signals for the same geofence are rate-limited to once every 5 minutes.

#### Recommendations

1. **Lazy Initialization**: Defer non-essential service initialization when the app is launched due to a geofence trigger:

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Always initialize Dengage SDK first
    Dengage.start(apiKey: "your-api-key",
                  application: application,
                  launchOptions: launchOptions,
                  dengageOptions: DengageOptions())

    // Initialize geofence
    DengageGeofence.startGeofence()

    // Defer heavy initialization when launched by geofence
    if launchOptions?[.location] == nil {
        // Only initialize these when user opens the app
        initializeAnalytics()
        initializeUIComponents()
        preloadCachedData()
    }

    return true
}
```

2. **Minimize Background Work**: When the app is launched due to a geofence trigger, minimize the work performed:
   - Avoid UI-related operations
   - Skip non-essential network requests
   - Don't load large datasets into memory

3. **Test Background Scenarios**: Thoroughly test your app's behavior when launched from a terminated state due to geofence triggers. Use Xcode's location simulation features to test various scenarios.

4. **User Communication**: Inform users about the benefits of location permissions and how geofencing enhances their experience. Users are more likely to grant "Always" location permission if they understand the value.

> **Note**: If your app doesn't require geofence functionality, avoid including the `DengageGeofence` module to prevent unnecessary location permission requests.

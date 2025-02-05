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
- [App Inbox](#app-inbox)
    - [Methods](#methods)
        - [Getting Inbox Messages](#getting-inbox-messages)
        - [Removing an Inbox Message](#removing-an-inbox-message)
        - [Marking an Inbox Message as Clicked:](#marking-an-inbox-message-as-clicked)
- [In-App Messaging](#in-app-messaging)
    - [Methods](#methods-1)
    - [Real Time In-App Messaging](#real-time-in-app-messaging)
    - [In-App Inline](#in-app-inline)
    - [App Stories](#app-stories)
- [Geofence](#geofence)
  - [Geofence Installation](#geofence-installation)
  - [Geofence Initialization](#geofence-initialization)
  - [Request Location Permission](#request-location-permission)


## SDK Setup

### Requirements

- Minimum iOS version supported `11.0`

### SDK Installation

#### CocoaPods Integration

**Dengage** is available through CocoaPods.

To install it, simply add the following line to your **Podfile**:

```ruby
pod 'Dengage', '~> 5.73'
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

1. **Dengage**: If you don’t plan to use the geofence feature or Huawei messaging service, simply include the `Dengage` module.
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
    pod 'Dengage', '~> 5.73'
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

#### Marking an Inbox Message as Clicked:

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
                        screenName: screenName,
                        customParams: customParams,
                        storyCompletion: { storiesListView in
    
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
pod 'Dengage', '~> 5.73'
pod 'DengageGeofence', '~> 5.73'
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

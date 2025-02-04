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
  - [setContactKey](#setcontactkey)
  - [setDeviceId](#setdeviceid)
  - [setCountry](#setcountry)


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

Installing the iOS SDK via Swift Package Manager (SPM) automates the majority of the installation process for you. Before beginning this process, ensure that you are using Xcode 12 or greater. (Note:Applies to new SDK.)

Open your project and navigate to your project's settings. Select the tab named Swift Packages and click on the add button (+) at the bottom left.

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




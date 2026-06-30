# Changelog


## [5.99] - 2026-06-30

### New Features

- Add `hideIfNotFound` support for App Story via `Dengage.showAppStory`
- Support embedded `StoriesListView` placement with clear-on-not-found behavior matching inline in-app

### Bug Fixes

- Fix in-app message overlay remaining visible when opening a deeplink from the message
- Fix crash when clearing story content after a failed property id lookup
- Hide the story placement when `hideIfNotFound` is `true` and property id / targeting does not match


## [5.98] - 2026-06-25

### Bug Fixes

- Implement DengageDeviceIdKeychainStore to fix device id keychain problems.

## [5.97] - 2026-06-22

### New Features

- Implement getCancelledSendIds
- Fix user agent non ASCII characters


## [5.96] - 2026-06-03

### New Features

- Implement Live Activities
- Add new features to App Story


## [5.95] - 2026-05-09

### New Features

- Implement GeofenceInterceptor
- Include system push authorization status in subscription permission



## [5.94] - 2026-04-01

### Bug Fixes

- Fix for StoryProgressView crash




## [5.93] - 2026-03-31

### Bug Fixes

- Hide story CTA button when isEnabled is false




## [5.90] - 2026-02-21

### New Features

- Change in event manager based on tracking permission

### Bug Fixes

- Prevent duplicate push open events using messageDetails deduplication
- Fix HttpRequestHandler response body





## [5.89] - 2026-01-22

### New Features
- Implement `subscriptionEnabled` switch in GetSDKParamsResponse
- Implement `eventsEnabled` switch in GetSDKParamsResponse
- Implement `geofenceEnabled` switch in GetSDKParamsResponse
- Implement `copyToClipboard` functionality in In-App Messages
- Add custom params support in inbox

### Bug Fixes
- Fix for `getDeviceCountry` method
- Fix duplicate in-app message display and multiple coupon assignments on consecutive `setNavigation` calls 

### Improvements
- Persist in-app message showCount across API responses with auto-cleanup
- Add Locale `en_US_POSIX` to `convertDate` and `convertToString` methods for consistent date formatting
- Remove `deviceId` from GetSDKParamsRequest
- Update appStory

### Documentation
- Update geofence section in readme

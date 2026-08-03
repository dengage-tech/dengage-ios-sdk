# Changelog


## [5.101] - 2026-07-24


### New Features

- Introduce Geofence Engine v2 (`DengageGeofence/Engine`): server-synced geofences with ETag revalidation, nearest-N region monitoring, and enter / exit / dwell reporting through `POST /event-signal` v2
- Keep `DengageGeofence` as the public entry point; `startGeofence` / `stopGeofence` / `requestLocationPermissions` now drive the new engine
- Handle geofence silent push (`sourceType=geofence`) automatically through `GeofenceSilentPushDispatcher`, using a runtime bridge so the core SDK works without the geofence module
- Emit synthetic transitions when the OS callback is late or missing, so a dropped exit no longer leaves a fence permanently stuck
- Repair missed exits on other fences when a region transition wakes the engine, without firing campaigns for them
- Gate synthetic transitions on fix confidence: both horizontal accuracy and fix age feed the decision margin, and fixes older than 15 minutes are ignored
- Send `occurredAt` from the location fix time instead of processing time, and report `accuracyM`, `syntheticTransition` and `token` in event-signal requests
- Cache campaign content for offline triggers and fire it as a local notification, queueing the event until connectivity returns
- Add remote tuning through `SdkParameters.geofence` (top-N, re-evaluation distance, adaptive threshold, wake-up cap, heartbeat interval, offline queue size), clamped to safe ranges on read
- Keep a wake source alive while the wake-up cap is paused, so the engine can still be woken by significant displacement

### Bug Fixes

- Bypass `URLCache` on geofence sync so ETag revalidation controls freshness; a cached response could previously be served as a fresh fence list for days
- Hold a background task assertion while geofence events are being sent, fixing push notifications arriving hours after the trigger
- Deduplicate region callbacks so a single physical crossing no longer produces multiple events
- Arm at most one dwell timer per fence, preventing repeated dwell notifications after re-registration
- Populate `locationPermission` in the subscription request, which was previously sent empty
- Fix `LocalNotificationFirer` so tapping a locally shown notification opens the app or its deep link
- Fix App Story cover ring staying active after stories are watched
- Mark cover as watched when closing while on the last snap
- Persist story seen/resume state reliably via JSON UserDefaults storage
- Refresh story list ring state after dismissing the fullscreen viewer



## [5.100] - 2026-07-06

### New Features

- Add liveActivityPermission to DengageRequestSetStartToken

## [5.99] - 2026-06-30

### New Features

- Add `hideIfNotFound` support for App Story via `Dengage.showAppStory`
- Support embedded `StoriesListView` placement with clear-on-not-found behavior matching inline in-app
- Hide status bar in fullscreen inapp

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

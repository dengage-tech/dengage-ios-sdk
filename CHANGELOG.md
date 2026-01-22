# Changelog

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

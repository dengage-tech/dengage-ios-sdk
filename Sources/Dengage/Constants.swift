import Foundation


var SUBSCRIPTION_SERVICE_URL = "https://push.dengage.com"
var EVENT_SERVICE_URL = "https://event.dengage.com"

let DEVICE_EVENT_QUEUE = "device-event-queue"
let SUBSCRIPTION_QUEUE = "subscription-queue"

let SDK_VERSION = "5.60.2"
let SUIT_NAME = "group.dengage"
let DEFAULT_CARRIER_ID = "1"
let MESSAGE_SOURCE = "DENGAGE"

let INBOX_FETCH_INTERVAL = 10 //minute
let SDKPARAMS_FETCH_INTERVAL =  24

let GEOFENCE_MAX_MONITOR_COUNT = 20
let GEOFENCE_MAX_FETCH_INTERVAL = TimeInterval(15 * 60)
let GEOFENCE_MAX_EVENT_SIGNAL_INTERVAL = TimeInterval(5 * 60)
let GEOFENCE_FETCH_HISTORY_MAX_COUNT = 100
let GEOFENCE_EVENT_HISTORY_MAX_COUNT = 100

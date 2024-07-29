(function() {
    'use strict';
    function _typeof(obj) {
        "@babel/helpers - typeof";
        if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") {
            _typeof = function(obj) {
                return typeof obj
            }
        } else {
            _typeof = function(obj) {
                return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj
            }
        }
        return _typeof(obj)
    }
    function _defineProperty(obj, key, value) {
        if (key in obj) {
            Object.defineProperty(obj, key, {
                value: value,
                enumerable: true,
                configurable: true,
                writable: true
            })
        } else {
            obj[key] = value
        }
        return obj
    }
    function _slicedToArray(arr, i) {
        return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _unsupportedIterableToArray(arr, i) || _nonIterableRest()
    }
    function _toConsumableArray(arr) {
        return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _unsupportedIterableToArray(arr) || _nonIterableSpread()
    }
    function _arrayWithoutHoles(arr) {
        if (Array.isArray(arr))
            return _arrayLikeToArray(arr)
    }
    function _arrayWithHoles(arr) {
        if (Array.isArray(arr))
            return arr
    }
    function _iterableToArray(iter) {
        if (typeof Symbol !== "undefined" && Symbol.iterator in Object(iter))
            return Array.from(iter)
    }
    function _iterableToArrayLimit(arr, i) {
        if (typeof Symbol === "undefined" || !(Symbol.iterator in Object(arr)))
            return;
        var _arr = [];
        var _n = true;
        var _d = false;
        var _e = undefined;
        try {
            for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) {
                _arr.push(_s.value);
                if (i && _arr.length === i)
                    break
            }
        } catch (err) {
            _d = true;
            _e = err
        } finally {
            try {
                if (!_n && _i["return"] != null)
                    _i["return"]()
            } finally {
                if (_d)
                    throw _e
            }
        }
        return _arr
    }
    function _unsupportedIterableToArray(o, minLen) {
        if (!o)
            return;
        if (typeof o === "string")
            return _arrayLikeToArray(o, minLen);
        var n = Object.prototype.toString.call(o).slice(8, -1);
        if (n === "Object" && o.constructor)
            n = o.constructor.name;
        if (n === "Map" || n === "Set")
            return Array.from(o);
        if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))
            return _arrayLikeToArray(o, minLen)
    }
    function _arrayLikeToArray(arr, len) {
        if (len == null || len > arr.length)
            len = arr.length;
        for (var i = 0, arr2 = new Array(len); i < len; i++)
            arr2[i] = arr[i];
        return arr2
    }
    function _nonIterableSpread() {
        throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")
    }
    function _nonIterableRest() {
        throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")
    }
    function _createForOfIteratorHelper(o, allowArrayLike) {
        var it;
        if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) {
            if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") {
                if (it)
                    o = it;
                var i = 0;
                var F = function() {};
                return {
                    s: F,
                    n: function() {
                        if (i >= o.length)
                            return {
                                done: true
                            };
                        return {
                            done: false,
                            value: o[i++]
                        }
                    },
                    e: function(e) {
                        throw e
                    },
                    f: F
                }
            }
            throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")
        }
        var normalCompletion = true, didErr = false, err;
        return {
            s: function() {
                it = o[Symbol.iterator]()
            },
            n: function() {
                var step = it.next();
                normalCompletion = step.done;
                return step
            },
            e: function(e) {
                didErr = true;
                err = e
            },
            f: function() {
                try {
                    if (!normalCompletion && it.return != null)
                        it.return()
                } finally {
                    if (didErr)
                        throw err
                }
            }
        }
    }
    var appSettings = JSON.parse('{  "name": "",  "siteUrl": "https://ugur-e.github.io/inline-dev.github.io/",  "autoShow": true,  "bellSettings": {},  "blockedPopup": {    "delay": 5,    "title": "",    "enabled": false,    "message": "",    "buttonText": "",    "showButton": false,    "titleColor": "",    "buttonColor": "#1165f1",    "maxShowCount": 5,    "repromptAfterXHours": 24  },  "siteVariable": {    "customJS": "",    "dataLayer": [      {        "value": "",        "source": "",        "paramDisplayName": ""      }    ],    "basketInfo": {      "basketCount": {        "value": "",        "source": "DATA_LAYER",        "paramDisplayName": ""      },      "basketAmount": {        "value": "",        "source": "DATA_LAYER",        "paramDisplayName": ""      }    },    "localStorage": [      {        "value": "",        "source": "",        "paramDisplayName": ""      }    ]  },  "slideSettings": {    "text": "Do you want to allow Webpush from Inline Development ",    "fixed": true,    "theme": "BOTTOM_BTNS",    "title": "",    "details": {      "border": 0,      "shadow": true,      "textSyle": {        "fontSize": 15,        "textColor": "#555555",        "fontWeight": "normal"      },      "titleSyle": {        "fontSize": 16,        "textColor": "#555555",        "fontWeight": "bold"      },      "fontFamily": "ARIAL",      "borderColor": "#1165F1",      "borderRadius": 3,      "acceptBtnStyle": {        "border": 0,        "shadow": false,        "fontSize": 16,        "textColor": "#FFFFFF",        "fontWeight": "normal",        "borderColor": "#1165f1",        "borderRadius": 3,        "hoverTextColor": "#FFFFFF",        "backgroundColor": "#1165f1",        "hoverBackgroundColor": "#0e51c1"      },      "cancelBtnStyle": {        "border": 0,        "shadow": true,        "fontSize": 16,        "textColor": "#1165f1",        "fontWeight": "normal",        "borderColor": "#1165f1",        "borderRadius": 3,        "hoverTextColor": "#0e51c1",        "backgroundColor": "#FFFFFF",        "hoverBackgroundColor": "#FFFFFF"      },      "backgroundColor": "#FFFFFF"    },    "location": "TOP_CENTER",    "showIcon": false,    "mainColor": "#12BFA7",    "showTitle": false,    "borderColor": "#1165f1",    "acceptBtnText": "Allow",    "cancelBtnText": "No Thanks",    "advancedOptions": false  },  "allowedDomains": [],  "bannerSettings": {    "text": "We\'d like to show you notifications for the latest news and updates.",    "fixed": true,    "theme": "DEFAULT",    "details": null,    "location": "BOTTOM",    "showIcon": false,    "mainColor": "#333333",    "acceptBtnText": "Enable",    "advancedOptions": false  },  "defaultIconUrl": "https://avatars2.githubusercontent.com/u/57666388?s=460&v=4",  "selectedPrompt": "SLIDE",  "autoShowSettings": {    "delay": 0,    "denyWaitTime": 1,    "promptAfterXVisits": 0,    "repromptAfterXMinutes": 30  },  "subdomainDataSync": false,  "siteVariableEnabled": false,  "welcomeNotification": {    "link": "",    "title": "",    "enabled": false,    "message": ""  },  "showNativeWhenPossible": false,  "triggerNavigationOnLoad": true}');
    appSettings.allowedDomains = appSettings.allowedDomains || [];
    appSettings.allowedDomains.push(appSettings.siteUrl);
    appSettings.allowedDomains = appSettings.allowedDomains.map((function(d) {
        var u = new URL(d);
        return u.host
    }
    ));
    function CrossStorageClient(url, opts) {
        opts = opts || {};
        this._id = CrossStorageClient._generateUUID();
        this._promise = opts.promise || Promise;
        this._frameId = opts.frameId || 'CrossStorageClient-' + this._id;
        this._origin = CrossStorageClient._getOrigin(url);
        this._requests = {};
        this._connected = false;
        this._closed = false;
        this._count = 0;
        this._timeout = opts.timeout || 5e3;
        this._listener = null;
        this._installListener();
        var frame;
        if (opts.frameId) {
            frame = document.getElementById(opts.frameId)
        }
        if (frame) {
            this._poll()
        }
        frame = frame || this._createFrame(url);
        this._hub = frame.contentWindow
    }
    CrossStorageClient.frameStyle = {
        display: 'none',
        position: 'absolute',
        top: '-999px',
        left: '-999px'
    };
    CrossStorageClient._getOrigin = function(url) {
        var uri, protocol, origin;
        uri = document.createElement('a');
        uri.href = url;
        if (!uri.host) {
            uri = window.location
        }
        if (!uri.protocol || uri.protocol === ':') {
            protocol = window.location.protocol
        } else {
            protocol = uri.protocol
        }
        origin = protocol + '//' + uri.host;
        origin = origin.replace(/:80$|:443$/, '');
        return origin
    }
    ;
    CrossStorageClient._generateUUID = function() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (function(c) {
            var r = Math.random() * 16 | 0
              , v = c == 'x' ? r : r & 3 | 8;
            return v.toString(16)
        }
        ))
    }
    ;
    CrossStorageClient.prototype.onConnect = function() {
        var client = this;
        if (this._connected) {
            return this._promise.resolve()
        } else if (this._closed) {
            return this._promise.reject(new Error('CrossStorageClient has closed'))
        }
        if (!this._requests.connect) {
            this._requests.connect = []
        }
        return new this._promise((function(resolve, reject) {
            var timeout = setTimeout((function() {
                reject(new Error('CrossStorageClient could not connect'))
            }
            ), client._timeout);
            client._requests.connect.push((function(err) {
                clearTimeout(timeout);
                if (err)
                    return reject(err);
                resolve()
            }
            ))
        }
        ))
    }
    ;
    CrossStorageClient.prototype.set = function(key, value) {
        return this._request('set', {
            key: key,
            value: value
        })
    }
    ;
    CrossStorageClient.prototype.get = function(key) {
        var args = Array.prototype.slice.call(arguments);
        return this._request('get', {
            keys: args
        })
    }
    ;
    CrossStorageClient.prototype.del = function() {
        var args = Array.prototype.slice.call(arguments);
        return this._request('del', {
            keys: args
        })
    }
    ;
    CrossStorageClient.prototype.clear = function() {
        return this._request('clear')
    }
    ;
    CrossStorageClient.prototype.getKeys = function() {
        return this._request('getKeys')
    }
    ;
    CrossStorageClient.prototype.close = function() {
        var frame = document.getElementById(this._frameId);
        if (frame) {
            frame.parentNode.removeChild(frame)
        }
        if (window.removeEventListener) {
            window.removeEventListener('message', this._listener, false)
        } else {
            window.detachEvent('onmessage', this._listener)
        }
        this._connected = false;
        this._closed = true
    }
    ;
    CrossStorageClient.prototype._installListener = function() {
        var client = this;
        this._listener = function(message) {
            var i, origin, error, response;
            if (client._closed || !message.data || typeof message.data !== 'string') {
                return
            }
            origin = message.origin === 'null' ? 'file://' : message.origin;
            if (origin !== client._origin)
                return;
            if (message.data === 'cross-storage:unavailable') {
                if (!client._closed)
                    client.close();
                if (!client._requests.connect)
                    return;
                error = new Error('Closing client. Could not access localStorage in hub.');
                for (i = 0; i < client._requests.connect.length; i++) {
                    client._requests.connect[i](error)
                }
                return
            }
            if (message.data.indexOf('cross-storage:') !== -1 && !client._connected) {
                client._connected = true;
                if (!client._requests.connect)
                    return;
                for (i = 0; i < client._requests.connect.length; i++) {
                    client._requests.connect[i](error)
                }
                delete client._requests.connect
            }
            if (message.data === 'cross-storage:ready')
                return;
            try {
                response = JSON.parse(message.data)
            } catch (e) {
                return
            }
            if (!response.id)
                return;
            if (client._requests[response.id]) {
                client._requests[response.id](response.error, response.result)
            }
        }
        ;
        if (window.addEventListener) {
            window.addEventListener('message', this._listener, false)
        } else {
            window.attachEvent('onmessage', this._listener)
        }
    }
    ;
    CrossStorageClient.prototype._poll = function() {
        var client, interval, targetOrigin;
        client = this;
        targetOrigin = client._origin === 'file://' ? '*' : client._origin;
        interval = setInterval((function() {
            if (client._connected)
                return clearInterval(interval);
            if (!client._hub)
                return;
            client._hub.postMessage('cross-storage:poll', targetOrigin)
        }
        ), 1e3)
    }
    ;
    CrossStorageClient.prototype._createFrame = function(url) {
        var frame, key;
        frame = window.document.createElement('iframe');
        frame.id = this._frameId;
        for (key in CrossStorageClient.frameStyle) {
            if (CrossStorageClient.frameStyle.hasOwnProperty(key)) {
                frame.style[key] = CrossStorageClient.frameStyle[key]
            }
        }
        window.document.body.appendChild(frame);
        frame.src = url;
        return frame
    }
    ;
    CrossStorageClient.prototype._request = function(method, params) {
        var req, client;
        if (this._closed) {
            return this._promise.reject(new Error('CrossStorageClient has closed'))
        }
        client = this;
        client._count++;
        req = {
            id: this._id + ':' + client._count,
            method: 'cross-storage:' + method,
            params: params
        };
        return new this._promise((function(resolve, reject) {
            var timeout, originalToJSON, targetOrigin;
            timeout = setTimeout((function() {
                if (!client._requests[req.id])
                    return;
                delete client._requests[req.id];
                reject(new Error('Timeout: could not perform ' + req.method))
            }
            ), client._timeout);
            client._requests[req.id] = function(err, result) {
                clearTimeout(timeout);
                delete client._requests[req.id];
                if (err)
                    return reject(new Error(err));
                resolve(result)
            }
            ;
            if (Array.prototype.toJSON) {
                originalToJSON = Array.prototype.toJSON;
                Array.prototype.toJSON = null
            }
            targetOrigin = client._origin === 'file://' ? '*' : client._origin;
            client._hub.postMessage(JSON.stringify(req), targetOrigin);
            if (originalToJSON) {
                Array.prototype.toJSON = originalToJSON
            }
        }
        ))
    }
    ;
    var crossStorage = null;
    var storageDefaultValueMap = {
        device_id: null,
        contact_key: null,
        webpush: {},
        legacy_onsite: {},
        onsite_display_infos: [],
        extra: {},
        visits: [],
        session: {},
        visitor_info: {},
        story_set_visits: {}
    };
    var data$1 = Object.assign({}, storageDefaultValueMap);
    var updateMap = {};
    function triggerUpdate(key) {
        if (!updateMap[key]) {
            updateMap[key] = true;
            setTimeout((function() {
                updateMap[key] = false;
                updateStorage(key)
            }
            ), 1e3)
        }
    }
    function updateStorage(key) {
        var value = data$1[key];
        if (['device_id', 'contact_key'].includes(key)) {
            localStorage.setItem('dengage_' + key, value)
        } else {
            value = JSON.stringify(value)
        }
        key = 'dn_' + key;
        if (!crossStorage || !crossStorage._connected) {
            localStorage.setItem(key, value)
        } else {
            if (key === 'dn_legacy_onsite') {
                localStorage.setItem(key, value)
            }
            crossStorage.set(key, value)
        }
    }
    function getValue(key) {
        if (key.includes('.')) {
            var keyParts = key.split('.');
            return data$1[keyParts[0]][keyParts[1]]
        }
        return data$1[key]
    }
    function setValue(key, value) {
        if (value == getValue(key)) {
            return
        }
        var keyParts = key.split('.');
        if (keyParts.length > 1) {
            data$1[keyParts[0]][keyParts[1]] = value
        } else {
            data$1[key] = value
        }
        triggerUpdate(keyParts[0])
    }
    function removeValue(key) {
        if (!crossStorage || !crossStorage._connected) {
            localStorage.removeItem(key)
        } else {
            crossStorage.del(key)
        }
    }
    function migrateData() {
        setValue('device_id', localStorage.getItem('dengage_device_id'));
        setValue('contact_key', normalizeShort(localStorage.getItem('dengage_contact_key')));
        setValue('webpush', {
            token: normalizeLong(localStorage.getItem('dengage_webpush_token')),
            type: normalizeShort(localStorage.getItem('dengage_webpush_token_type')),
            sub: normalizeLong(localStorage.getItem('dengage_webpush_sub')),
            user_perm: normalizeShort(localStorage.getItem('dengage_user_permission')),
            prompt_last_a: localStorage.getItem('dengage_webpush_last_a') || '',
            prompt_last_t: localStorage.getItem('dengage_webpush_last_d') || 0,
            blocked_prompt_count: localStorage.getItem('dengage_push_blocked_count') || 0,
            blocked_prompt_last_t: localStorage.getItem('dengage_push_blocked_last_d') || 0,
            domain: window._Dn_globaL_.cookieData.webpushDomain || ''
        });
        setValue('legacy_onsite', {
            messages: getValue('legacy_onsite.messages') || [],
            last_msg_created: localStorage.getItem('dengage_onsite_last_created') || getValue('legacy_onsite.last_msg_created') || 0,
            get_message_t: localStorage.getItem('dengage_onsite_get_message_timestamp') || getValue('legacy_onsite.get_message_t') || 0
        });
        setValue('extra', {
            tracking_perm: normalizeShort(localStorage.getItem('dengage_tracking_permission')) || true,
            country: localStorage.getItem('dengage_country'),
            last_cat: '',
            last_visit: 0,
            next_onsite_message_t: localStorage.getItem('next_onsite_message_display_time') || 0,
            debug: normalizeShort(localStorage.getItem('dn_debug')) || false,
            log_level: normalizeShort(localStorage.getItem('dengage_log_level')) || 'error'
        });
        ['dengage_webpush_token', 'dengage_webpush_token_type', 'dengage_webpush_sub', 'dengage_user_permission', 'dengage_webpush_last_a', 'dengage_webpush_last_d', 'dengage_push_blocked_count', 'dengage_push_blocked_last_d', 'dengage_onsite_last_created', 'dengage_onsite_get_message_timestamp', 'dengage_tracking_permission', 'dengage_country', 'next_onsite_message_display_time', 'dn_debug', 'dengage_log_level'].forEach((function(key) {
            localStorage.removeItem(key)
        }
        ))
    }
    var storage = {
        isAvailable: function isAvailable() {
            sessionStorage.getItem('dengage_subscription_sent');
            var did = localStorage.getItem('dengage_device_id');
            var keys = Object.keys(data$1);
            return new Promise((function(resolve, reject) {
                if (!isCrossFrameStorageEnabled()) {
                    reject();
                    return
                }
                crossStorage = new CrossStorageClient('https://f6db8103-830e-d147-3a40-afef0c991358.dengagecdn.com/cross-domain-storage-hub.html',{
                    timeout: 1e3,
                    frameId: 'dnStorage'
                });
                var legacyOnsiteKeyIndex = -1;
                var displayInfosKeyIndex = -1;
                crossStorage.onConnect().then((function() {
                    var _crossStorage;
                    logInfo('iframe storage connected');
                    for (var i = 0; i < keys.length; i++) {
                        if (keys[i] === 'legacy_onsite') {
                            legacyOnsiteKeyIndex = i;
                            continue
                        }
                        if (keys[i] === 'onsite_display_infos') {
                            displayInfosKeyIndex = i;
                            continue
                        }
                        localStorage.removeItem('dn_' + keys[i])
                    }
                    return (_crossStorage = crossStorage).get.apply(_crossStorage, _toConsumableArray(keys.map((function(key) {
                        return 'dn_' + key
                    }
                    ))))
                }
                )).then((function(values) {
                    var crossLegacyOnsite = jsonParse(values[legacyOnsiteKeyIndex], {
                        messages: []
                    });
                    removeValue('dn_legacy_onsite');
                    var localLegacyOnsite = jsonParse(localStorage.getItem('dn_legacy_onsite'), {
                        messages: []
                    });
                    localStorage.removeItem('dn_legacy_onsite');
                    var now = (new Date).getTime();
                    if (Array.isArray(localLegacyOnsite.messages)) {
                        crossLegacyOnsite.messages = localLegacyOnsite.messages.reduce((function(result, localMessage) {
                            if ((localMessage.messageObj && localMessage.messageObj.endDate ? DateParse(localMessage.messageObj.endDate) > now : false) && (!result.length || result.some((function(crossMessage) {
                                return localMessage.id !== crossMessage.id
                            }
                            )))) {
                                result.push(localMessage)
                            }
                            return result
                        }
                        ), crossLegacyOnsite.messages || [])
                    }
                    crossLegacyOnsite.messages = (crossLegacyOnsite.messages || []).filter((function(crossMessage) {
                        return crossMessage.messageObj && crossMessage.messageObj.endDate ? DateParse(crossMessage.messageObj.endDate) > now : false
                    }
                    ));
                    crossLegacyOnsite.last_msg_created = Math.max(crossLegacyOnsite.last_msg_created, localLegacyOnsite.last_msg_created, 0);
                    crossLegacyOnsite.get_message_t = Math.max(crossLegacyOnsite.get_message_t, localLegacyOnsite.get_message_t, 0);
                    var crossDisplayInfos = jsonParse(values[displayInfosKeyIndex], []);
                    var localDisplayInfos = jsonParse(localStorage.getItem('dn_onsite_display_infos'), []);
                    crossDisplayInfos = localDisplayInfos.reduce((function(result, localDisplayInfo) {
                        var sharedInfoIndex = result.findIndex((function(crossDisplayInfo) {
                            return localDisplayInfo.id === crossDisplayInfo.id && localDisplayInfo.contactKey === crossDisplayInfo.contactKey
                        }
                        ));
                        if (sharedInfoIndex !== -1) {
                            result[sharedInfoIndex].displayCount = parseInt(result[sharedInfoIndex].displayCount) + parseInt(localDisplayInfo.displayCount);
                            result[sharedInfoIndex].isClicked = !!(result[sharedInfoIndex].isClicked || localDisplayInfo.isClicked);
                            result[sharedInfoIndex].lastDisplayTime = Math.max(result[sharedInfoIndex].lastDisplayTime, localDisplayInfo.lastDisplayTime, 0)
                        } else {
                            result.push(localDisplayInfo)
                        }
                        return result
                    }
                    ), crossDisplayInfos);
                    localStorage.removeItem('dn_onsite_display_infos');
                    values[legacyOnsiteKeyIndex] = JSON.stringify(crossLegacyOnsite);
                    values[displayInfosKeyIndex] = JSON.stringify(crossDisplayInfos);
                    setValue('legacy_onsite', crossLegacyOnsite);
                    setValue('onsite_display_infos', crossDisplayInfos);
                    resolve(values)
                }
                )).catch(reject)
            }
            )).catch((function(error) {
                if (error) {
                    logError(error)
                }
                var localLegacyOnsite = jsonParse(localStorage.getItem('dn_legacy_onsite'), {
                    messages: []
                });
                localStorage.removeItem('dn_legacy_onsite');
                var now = new Date;
                localLegacyOnsite.messages = (localLegacyOnsite.messages || []).filter((function(localMessage) {
                    return localMessage.messageObj && localMessage.messageObj.endDate ? DateParse(localMessage.messageObj.endDate) > now : false
                }
                ));
                setValue('legacy_onsite', localLegacyOnsite);
                return keys.map((function(key) {
                    return localStorage.getItem('dn_' + key)
                }
                ))
            }
            )).then((function(values) {
                data$1 = Object.assign(data$1, keys.reduce((function(result, key, keyIndex) {
                    result[key] = ['device_id', 'contact_key'].includes(key) ? values[keyIndex] : jsonParse(values[keyIndex], storageDefaultValueMap[key]);
                    return result
                }
                ), {}));
                window._Dn_globaL_.storage = data$1;
                if (!data$1['device_id'] && did) {
                    migrateData()
                }
                return true
            }
            ))
        },
        get: function get(key) {
            return getValue(key)
        },
        set: function set(key, value) {
            setValue(key, value)
        },
        remove: function remove(key) {
            removeValue(key)
        },
        increment: function increment(key) {
            var val = parseInt(getValue(key)) || 0;
            setValue(key, val + 1)
        },
        getInt: function getInt(key) {
            return toInt$1(getValue(key))
        },
        sessionGet: function sessionGet(key) {
            try {
                return sessionStorage.getItem('dengage_' + key)
            } catch (e) {
                return null
            }
        },
        sessionSet: function sessionSet(key, value) {
            try {
                sessionStorage.setItem('dengage_' + key, value)
            } catch (e) {}
        },
        changeContact: function changeContact() {}
    };
    function isCrossFrameStorageEnabled(showError) {
        var crossFrameEnabled = false;
        try {
            crossFrameEnabled = JSON.parse('true')
        } catch (e) {}
        if (crossFrameEnabled == false && showError === true) {
            logWarning('Cross Frame Storage is not enabled for this site');
            return false
        }
        return crossFrameEnabled
    }
    function isDnPushEnabled(showError) {
        var pushEnabled = false;
        try {
            pushEnabled = JSON.parse('true')
        } catch (e) {}
        if (pushEnabled == false && showError === true) {
            logWarning('Web push is not enabled for this site on dengage platform');
            return false
        }
        return pushEnabled
    }
    function isDnLegacyOnsiteEnabled(showError) {
        var onsiteEnabled = false;
        try {
            onsiteEnabled = JSON.parse('true')
        } catch (e) {}
        if (onsiteEnabled == false && showError === true) {
            logWarning('Onsite messages are not enabled for this site on dengage platform');
            return false
        }
        return onsiteEnabled
    }
    function isDnRealtimeOnsiteEnabled(showError) {
        var onsiteEnabled = false;
        try {
            onsiteEnabled = JSON.parse('true')
        } catch (e) {}
        if (onsiteEnabled == false && showError === true) {
            logWarning('Realtime Onsite messages are not enabled for this site on dengage platform');
            return false
        }
        return onsiteEnabled
    }
    function isDnSafariPushEnabled() {
        var safariEnabled = false;
        try {
            safariEnabled = JSON.parse('false')
        } catch (e) {}
        return safariEnabled
    }
    function isDnEventsEnabled() {
        var enabled = true;
        try {
            enabled = JSON.parse('true')
        } catch (e) {}
        return enabled
    }
    function shouldPushManagerStart() {
        if (appSettings.subdomainDataSync) {
            var webpushDomain = window._Dn_globaL_.cookieData.webpushDomain;
            if (webpushDomain && webpushDomain != location.host) {
                return false
            }
        }
        return (isSafariPushSupported() || isNativePushSupported()) && isDnPushEnabled(false)
    }
    function shouldOnsiteManagerStart(showError) {
        return isDnRealtimeOnsiteEnabled(showError) || isDnLegacyOnsiteEnabled(showError)
    }
    function isSendEventEnabled() {
        var enabled = isDnEventsEnabled();
        if (enabled) {
            enabled = getTrackingPermission$1()
        }
        return enabled
    }
    function isSafariPushSupported() {
        return 'safari'in window && _typeof(window.safari) == 'object' && 'pushNotification'in window.safari
    }
    function isNativePushSupported() {
        return 'serviceWorker'in navigator && 'PushManager'in window && 'Notification'in window && typeof Notification.requestPermission == 'function'
    }
    function getTrackingPermission$1() {
        var val = storage.get('extra.tracking_perm');
        return val === 'false' ? false : true
    }
    function sha256(ascii) {
        function rightRotate(value, amount) {
            return value >>> amount | value << 32 - amount
        }
        var mathPow = Math.pow;
        var maxWord = mathPow(2, 32);
        var lengthProperty = 'length';
        var i, j;
        var result = '';
        var words = [];
        var asciiBitLength = ascii[lengthProperty] * 8;
        var hash = sha256.h = sha256.h || [];
        var k = sha256.k = sha256.k || [];
        var primeCounter = k[lengthProperty];
        var isComposite = {};
        for (var candidate = 2; primeCounter < 64; candidate++) {
            if (!isComposite[candidate]) {
                for (i = 0; i < 313; i += candidate) {
                    isComposite[i] = candidate
                }
                hash[primeCounter] = mathPow(candidate, .5) * maxWord | 0;
                k[primeCounter++] = mathPow(candidate, 1 / 3) * maxWord | 0
            }
        }
        ascii += '';
        while (ascii[lengthProperty] % 64 - 56) {
            ascii += '\0'
        }
        for (i = 0; i < ascii[lengthProperty]; i++) {
            j = ascii.charCodeAt(i);
            if (j >> 8)
                return;
            words[i >> 2] |= j << (3 - i) % 4 * 8
        }
        words[words[lengthProperty]] = asciiBitLength / maxWord | 0;
        words[words[lengthProperty]] = asciiBitLength;
        for (j = 0; j < words[lengthProperty]; ) {
            var w = words.slice(j, j += 16);
            var oldHash = hash;
            hash = hash.slice(0, 8);
            for (i = 0; i < 64; i++) {
                var w15 = w[i - 15]
                  , w2 = w[i - 2];
                var a = hash[0]
                  , e = hash[4];
                var temp1 = hash[7] + (rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25)) + (e & hash[5] ^ ~e & hash[6]) + k[i] + (w[i] = i < 16 ? w[i] : w[i - 16] + (rightRotate(w15, 7) ^ rightRotate(w15, 18) ^ w15 >>> 3) + w[i - 7] + (rightRotate(w2, 17) ^ rightRotate(w2, 19) ^ w2 >>> 10) | 0);
                var temp2 = (rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22)) + (a & hash[1] ^ a & hash[2] ^ hash[1] & hash[2]);
                hash = [temp1 + temp2 | 0].concat(hash);
                hash[4] = hash[4] + temp1 | 0
            }
            for (i = 0; i < 8; i++) {
                hash[i] = hash[i] + oldHash[i] | 0
            }
        }
        for (i = 0; i < 8; i++) {
            for (j = 3; j + 1; j--) {
                var b = hash[i] >> j * 8 & 255;
                result += (b < 16 ? 0 : '') + b.toString(16)
            }
        }
        return result
    }
    var token = null;
    var webSubscription = null;
    var params$1 = {
        swUrl: '/dengage-webpush-sw.js',
        swScope: '/',
        useSwQueryParams: true
    };
    function generateToken(subscription) {
        var subText = JSON.stringify(subscription);
        subText = subText.replace(/[^ -~]+/g, '');
        return 'dn_' + sha256(subText)
    }
    function setSubscriptionValues(subscription) {
        if (!subscription) {
            return
        }
        var sub = deepCopy(subscription);
        if (!sub) {
            return
        }
        var subObj = {
            endpoint: sub.endpoint,
            expirationTime: null,
            keys: {
                p256dh: sub.keys.p256dh,
                auth: sub.keys.auth
            }
        };
        webSubscription = JSON.stringify(subObj);
        token = generateToken(subObj)
    }
    function subscribePush(registration) {
        var options = {
            userVisibleOnly: true,
            applicationServerKey: 'BO5X91Erg-7HaPUkKLfyOvvJ1VPFE5HqCoPIPXR78I_mstoRKfqUopPNMnxLlXqrMAJ3BJsLHKg5x7NsUEMraDs'
        };
        return registration.pushManager.subscribe(options).then((function(newSubscription) {
            setSubscriptionValues(newSubscription)
        }
        ), errorLoggerRejected('pushManager.subscribe failed'))
    }
    function refreshSubscription(registration) {
        return registration.pushManager.getSubscription().then((function(subscription) {
            if (subscription) {
                if (base64Normalize(arrayBufferToBase64(subscription.options.applicationServerKey)) == base64Normalize('BO5X91Erg-7HaPUkKLfyOvvJ1VPFE5HqCoPIPXR78I_mstoRKfqUopPNMnxLlXqrMAJ3BJsLHKg5x7NsUEMraDs')) {
                    setSubscriptionValues(subscription)
                } else {
                    return subscription.unsubscribe().then((function() {
                        return subscribePush(registration)
                    }
                    )).catch((function() {
                        logError('subscription.unsubscribe() failed');
                        return subscribePush(registration)
                    }
                    ))
                }
            } else {
                return subscribePush(registration)
            }
        }
        ), errorLoggerRejected('getSubscription failed'))
    }
    var webPushApiClient = {
        detected: isNativePushSupported,
        init: function init() {
            var currentPermission = Notification.permission;
            if (currentPermission === 'granted') {
                var serviceWorkerUrl = params$1.swUrl;
                if (params$1.useSwQueryParams) {
                    serviceWorkerUrl += '?account_id=10&app_guid=f6db8103-830e-d147-3a40-afef0c991358&domain=' + encodeURIComponent(window._Dn_globaL_.domain)
                }
                return navigator.serviceWorker.register(serviceWorkerUrl, {
                    scope: params$1.swScope,
                    updateViaCache: 'none'
                }).then((function(registration) {
                    if (params$1.swScope == '/') {
                        return navigator.serviceWorker.ready.then((function(registration) {
                            return refreshSubscription(registration)
                        }
                        ), errorLoggerRejected('serviceWorker.ready failed'))
                    } else {
                        return new Promise((function(resolve, reject) {
                            setTimeout((function() {
                                resolve(refreshSubscription(registration))
                            }
                            ), 5e3)
                        }
                        ))
                    }
                }
                ), errorLoggerRejected('An error occurred while registering service worker'))
            } else {
                logError('init called when permission is not granted');
                return Promise.reject()
            }
        },
        getTokenInfo: function getTokenInfo() {
            var currentPermission = Notification.permission;
            if (currentPermission === 'granted') {
                if (token == null || webSubscription == null) {
                    return navigator.serviceWorker.ready.then((function(registration) {
                        return refreshSubscription(registration)
                    }
                    )).then((function() {
                        return {
                            token: token,
                            tokenType: 'W',
                            webSubscription: webSubscription
                        }
                    }
                    ), errorLoggerResolved('serviceWorker.ready failed', null))
                }
                return Promise.resolve({
                    token: token,
                    tokenType: 'W',
                    webSubscription: webSubscription
                })
            }
            return Promise.resolve(null)
        },
        requestPermission: function requestPermission() {
            return Notification.requestPermission()
        },
        getPermission: function getPermission() {
            return Notification.permission
        },
        setParams: function setParams(p) {
            objectAssign(params$1, p)
        }
    };
    var endpoints = ['https://fcm.googleapis.com/fcm/send/', 'https://updates.push.services.mozilla.com/wpush/v2/', 'https://bn3p.notify.windows.com/w/?token=', 'https://wns2-by3p.notify.windows.com/w/?token=', 'https://wns2-db5p.notify.windows.com/w/?token=', 'https://wns2-sg2p.notify.windows.com/w/?token=', 'https://dm3p.notify.windows.com/w/?token=', 'https://bn2-ppe.notify.windows.com/w/?token=', 'https://wns2-bl2p.notify.windows.com/w/?token=', 'https://par02p.notify.windows.com/w/?token=', 'https://sg2p.notify.windows.com/w/?token=', 'https://am3p.notify.windows.com/w/?token='];
    function encodeCookieData(cookieData) {
        var tokenType = getTokenType$1(cookieData);
        var _token = getToken$1(cookieData, tokenType);
        var cookieStr = escapePipe(cookieData.deviceId) + '|' + tokenType + '|' + _token + '|' + escapePipe(cookieData.contactKey) + '|' + escapePipe(cookieData.webpushDomain);
        return cookieStr
    }
    function parseCookieData(cookieStr) {
        if (!cookieStr) {
            return null
        }
        cookieStr = cookieStr.replace(/\%\|/g, '##DN_PIPE_A6H8VBC##');
        var parts = cookieStr.split('|');
        for (var i = 0; i < parts.length; i++) {
            parts[i] = parts[i].replace(/##DN_PIPE_A6H8VBC##/g, '|')
        }
        var tokenType = parts[1] == 'S' || parts[1] == 'F' || parts[1] == '' ? parts[1] : 'W'
          , token = parts[2]
          , webSubscription = null;
        if (tokenType == 'W') {
            var urlPrefix = parts[1] == 'W' ? '' : endpoints[parseInt(parts[1]) - 1];
            webSubscription = {
                endpoint: urlPrefix + parts[2],
                expirationTime: null,
                keys: {
                    p256dh: parts[3],
                    auth: parts[4]
                }
            };
            token = generateToken(webSubscription)
        }
        if (parts.length == 7) {
            var cookieData = {
                deviceId: parts[0],
                tokenType: tokenType,
                token: token,
                webSubscription: JSON.stringify(webSubscription),
                contactKey: parts[5],
                webpushDomain: parts[6]
            };
            return cookieData
        } else {
            logError('cookie should be 7 parts');
            return null
        }
    }
    function getTokenType$1(cookieData) {
        if (cookieData.tokenType == 'S' || cookieData.tokenType == 'F') {
            return cookieData.tokenType
        }
        if (cookieData.token && cookieData.webSubscription) {
            var webSubscription = JSON.parse(cookieData.webSubscription);
            var ep = endpoints.find((function(e) {
                return webSubscription.endpoint.startsWith(e)
            }
            ));
            if (ep) {
                return endpoints.indexOf(ep) + 1 + ''
            }
            return 'W'
        }
        return ''
    }
    function getToken$1(cookieData, tokenType) {
        if (!cookieData.token || !tokenType) {
            return '||'
        }
        if (tokenType == 'S' || tokenType == 'F') {
            return escapePipe(cookieData.token) + '||'
        }
        var webSubscription = JSON.parse(cookieData.webSubscription);
        var endpoint = webSubscription.endpoint;
        if (tokenType != 'W') {
            var index = parseInt(tokenType) - 1;
            endpoint = endpoint.replace(endpoints[index], '')
        }
        return escapePipe(endpoint) + '|' + escapePipe(webSubscription.keys.p256dh) + '|' + escapePipe(webSubscription.keys.auth)
    }
    function escapePipe(str) {
        str = str || '';
        return str.replace && str.replace(/\|/g, '%|') || str
    }
    function sendEvent(table, key, data) {
        if (storage.get('session.id') && isSendEventEnabled()) {
            var params = {
                accountId: '90db7e2a-5839-53cd-605f-9d3ffc328e21',
                key: key,
                eventTable: table,
                eventDetails: data
            };
            logInfo(params);
            return fetch('https://dev-event.dengage.com/api/web/event', {
                method: 'POST',
                mode: 'cors',
                cache: 'no-cache',
                credentials: 'omit',
                headers: {
                    'Content-Type': 'text/plain'
                },
                body: JSON.stringify(params)
            }).catch((function(e) {
                logError(e.toString())
            }
            ))
        }
    }
    function sendDeviceEvent(table, data) {
        var deviceId = getDeviceId();
        data.session_id = storage.get('session.id');
        return sendEvent(table, deviceId, data)
    }
    function sendCustomEvent(table, key, data) {
        return sendEvent(table, key, data)
    }
    var terms = {
        traffic: {
            utm: 'utm',
            organic: 'organic',
            referral: 'referral',
            typein: 'typein'
        },
        referer: {
            referral: 'referral',
            organic: 'organic',
            social: 'social'
        },
        none: '(none)',
        oops: '(Houston, we have a problem)'
    };
    var utils = {
        escapeRegexp: function escapeRegexp(string) {
            return string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&')
        },
        setDate: function setDate(date, offset) {
            var utc_offset = date.getTimezoneOffset() / 60
              , now_hours = date.getHours()
              , custom_offset = offset || offset === 0 ? offset : -utc_offset;
            date.setHours(now_hours + utc_offset + custom_offset);
            var year = date.getFullYear()
              , month = this.setLeadingZeroToInt(date.getMonth() + 1, 2)
              , day = this.setLeadingZeroToInt(date.getDate(), 2)
              , hour = this.setLeadingZeroToInt(date.getHours(), 2)
              , minute = this.setLeadingZeroToInt(date.getMinutes(), 2)
              , second = this.setLeadingZeroToInt(date.getSeconds(), 2);
            return year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second
        },
        setLeadingZeroToInt: function setLeadingZeroToInt(num, size) {
            var s = num + '';
            while (s.length < size) {
                s = '0' + s
            }
            return s
        },
        randomInt: function randomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min
        }
    };
    var data = {
        containers: {
            current: '_dn_current',
            current_extra: '_dn_current_add',
            first: '_dn_first',
            first_extra: '_dn_first_add',
            session: '_dn_session',
            udata: '_dn_udata'
        },
        delimiter: '|||',
        aliases: {
            main: {
                type: 'typ',
                source: 'src',
                medium: 'mdm',
                campaign: 'cmp',
                content: 'cnt',
                term: 'trm'
            },
            extra: {
                fire_date: 'fd',
                entrance_point: 'ep',
                referer: 'rf'
            },
            session: {
                pages_seen: 'pgs',
                current_page: 'cpg'
            },
            udata: {
                visits: 'vst',
                ip: 'uip',
                agent: 'uag'
            }
        },
        pack: {
            main: function main(s_data) {
                return data.aliases.main.type + '=' + s_data.type + data.delimiter + data.aliases.main.source + '=' + s_data.source + data.delimiter + data.aliases.main.medium + '=' + s_data.medium + data.delimiter + data.aliases.main.campaign + '=' + s_data.campaign + data.delimiter + data.aliases.main.content + '=' + s_data.content + data.delimiter + data.aliases.main.term + '=' + s_data.term
            },
            extra: function extra(timezone_offset) {
                return data.aliases.extra.fire_date + '=' + utils.setDate(new Date, timezone_offset) + data.delimiter + data.aliases.extra.entrance_point + '=' + document.location.href + data.delimiter + data.aliases.extra.referer + '=' + (document.referrer || terms.none)
            },
            user: function user(visits, user_ip) {
                return data.aliases.udata.visits + '=' + visits + data.delimiter + data.aliases.udata.ip + '=' + user_ip + data.delimiter + data.aliases.udata.agent + '=' + navigator.userAgent
            },
            session: function session(pages) {
                return data.aliases.session.pages_seen + '=' + pages + data.delimiter + data.aliases.session.current_page + '=' + document.location.href
            }
        }
    };
    var delimiter = data.delimiter;
    var cookies = {
        encodeData: function encodeData(s) {
            return encodeURIComponent(s).replace(/\!/g, '%21').replace(/\~/g, '%7E').replace(/\*/g, '%2A').replace(/\'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29')
        },
        decodeData: function decodeData(s) {
            try {
                return decodeURIComponent(s).replace(/\%21/g, '!').replace(/\%7E/g, '~').replace(/\%2A/g, '*').replace(/\%27/g, "'").replace(/\%28/g, '(').replace(/\%29/g, ')')
            } catch (err1) {
                try {
                    return unescape(s)
                } catch (err2) {
                    return ''
                }
            }
        },
        set: function set(name, value, minutes, domain, excl_subdomains) {
            name = this.encodeData(name);
            var expires = new Date;
            expires.setTime(expires.getTime() + minutes * 60 * 1e3);
            var sData = storage.get('extra.temp');
            var data = {};
            if (sData) {
                data = deepCopy(sData)
            }
            data[name] = this.encodeData(value);
            data[name + '_exp'] = expires.getTime();
            storage.set('extra.temp', data)
        },
        get: function get(name) {
            name = this.encodeData(name);
            var sData = storage.get('extra.temp') || {};
            var value = sData[name];
            var expires = parseInt(sData[name + '_exp']);
            if (value && expires && expires >= Date.now()) {
                return this.decodeData(value)
            }
            return null
        },
        destroy: function destroy(name, domain, excl_subdomains) {
            this.set(name, '', -1, domain, excl_subdomains)
        },
        parse: function parse(yummy) {
            var cookies = []
              , data = {};
            if (typeof yummy === 'string') {
                cookies.push(yummy)
            } else {
                for (var prop in yummy) {
                    if (yummy.hasOwnProperty(prop)) {
                        cookies.push(yummy[prop])
                    }
                }
            }
            for (var i1 = 0; i1 < cookies.length; i1++) {
                var cookie_array;
                data[this.unprefix(cookies[i1])] = {};
                if (this.get(cookies[i1])) {
                    cookie_array = this.get(cookies[i1]).split(delimiter)
                } else {
                    cookie_array = []
                }
                for (var i2 = 0; i2 < cookie_array.length; i2++) {
                    var tmp_array = cookie_array[i2].split('=')
                      , result_array = tmp_array.splice(0, 1);
                    result_array.push(tmp_array.join('='));
                    data[this.unprefix(cookies[i1])][result_array[0]] = this.decodeData(result_array[1])
                }
            }
            return data
        },
        unprefix: function unprefix(string) {
            return string.replace('_dn_', '')
        }
    };
    var uri = {
        parse: function parse(str) {
            var o = this.parseOptions
              , m = o.parser[o.strictMode ? 'strict' : 'loose'].exec(str)
              , uri = {}
              , i = 14;
            while (i--) {
                uri[o.key[i]] = m[i] || ''
            }
            uri[o.q.name] = {};
            uri[o.key[12]].replace(o.q.parser, (function($0, $1, $2) {
                if ($1) {
                    uri[o.q.name][$1] = $2
                }
            }
            ));
            return uri
        },
        parseOptions: {
            strictMode: false,
            key: ['source', 'protocol', 'authority', 'userInfo', 'user', 'password', 'host', 'port', 'relative', 'path', 'directory', 'file', 'query', 'anchor'],
            q: {
                name: 'queryKey',
                parser: /(?:^|&)([^&=]*)=?([^&]*)/g
            },
            parser: {
                strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
                loose: /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
            }
        },
        getParam: function getParam(custom_params) {
            var query_string = {}
              , query = custom_params ? custom_params : window.location.search.substring(1)
              , vars = query.split('&');
            for (var i = 0; i < vars.length; i++) {
                var pair = vars[i].split('=');
                if (typeof query_string[pair[0]] === 'undefined') {
                    query_string[pair[0]] = pair[1]
                } else if (typeof query_string[pair[0]] === 'string') {
                    var arr = [query_string[pair[0]], pair[1]];
                    query_string[pair[0]] = arr
                } else {
                    query_string[pair[0]].push(pair[1])
                }
            }
            return query_string
        },
        getHost: function getHost(request) {
            return this.parse(request).host.replace('www.', '')
        }
    };
    var params = {
        fetch: function fetch(prefs) {
            var user = prefs || {}
              , params = {};
            params.lifetime = this.validate.checkFloat(user.lifetime) || 6;
            params.lifetime = parseInt(params.lifetime * 30 * 24 * 60);
            params.session_length = this.validate.checkInt(user.session_length) || 30;
            params.timezone_offset = this.validate.checkInt(user.timezone_offset);
            params.campaign_param = user.campaign_param || false;
            params.term_param = user.term_param || false;
            params.content_param = user.content_param || false;
            params.user_ip = user.user_ip || terms.none;
            if (user.typein_attributes && user.typein_attributes.source && user.typein_attributes.medium) {
                params.typein_attributes = {};
                params.typein_attributes.source = user.typein_attributes.source;
                params.typein_attributes.medium = user.typein_attributes.medium
            } else {
                params.typein_attributes = {
                    source: '(direct)',
                    medium: '(none)'
                }
            }
            if (user.domain && this.validate.isString(user.domain)) {
                params.domain = {
                    host: user.domain,
                    isolate: false
                }
            } else if (user.domain && user.domain.host) {
                params.domain = user.domain
            } else {
                params.domain = {
                    host: uri.getHost(document.location.hostname),
                    isolate: false
                }
            }
            params.referrals = [];
            if (user.referrals && user.referrals.length > 0) {
                for (var ir = 0; ir < user.referrals.length; ir++) {
                    if (user.referrals[ir].host) {
                        params.referrals.push(user.referrals[ir])
                    }
                }
            }
            params.organics = [];
            if (user.organics && user.organics.length > 0) {
                for (var io = 0; io < user.organics.length; io++) {
                    if (user.organics[io].host && user.organics[io].param) {
                        params.organics.push(user.organics[io])
                    }
                }
            }
            params.organics.push({
                host: 'bing.com',
                param: 'q',
                display: 'bing'
            });
            params.organics.push({
                host: 'yahoo.com',
                param: 'p',
                display: 'yahoo'
            });
            params.organics.push({
                host: 'about.com',
                param: 'q',
                display: 'about'
            });
            params.organics.push({
                host: 'aol.com',
                param: 'q',
                display: 'aol'
            });
            params.organics.push({
                host: 'ask.com',
                param: 'q',
                display: 'ask'
            });
            params.organics.push({
                host: 'globososo.com',
                param: 'q',
                display: 'globo'
            });
            params.organics.push({
                host: 'go.mail.ru',
                param: 'q',
                display: 'go.mail.ru'
            });
            params.organics.push({
                host: 'rambler.ru',
                param: 'query',
                display: 'rambler'
            });
            params.organics.push({
                host: 'tut.by',
                param: 'query',
                display: 'tut.by'
            });
            params.referrals.push({
                host: 't.co',
                display: 'twitter.com'
            });
            params.referrals.push({
                host: 'plus.url.google.com',
                display: 'plus.google.com'
            });
            return params
        },
        validate: {
            checkFloat: function checkFloat(v) {
                return v && this.isNumeric(parseFloat(v)) ? parseFloat(v) : false
            },
            checkInt: function checkInt(v) {
                return v && this.isNumeric(parseInt(v)) ? parseInt(v) : false
            },
            isNumeric: function isNumeric(v) {
                return !isNaN(v)
            },
            isString: function isString(v) {
                return Object.prototype.toString.call(v) === '[object String]'
            }
        }
    };
    function getTrafficSource$1(prefs) {
        var p = params.fetch(prefs);
        var get_param = uri.getParam();
        var domain = p.domain.host
          , isolate = p.domain.isolate
          , lifetime = p.lifetime;
        var _s_type, _s_source, _s_medium, _s_campaign, _s_content, _s_term;
        function mainData() {
            var result;
            if (typeof get_param.utm_source !== 'undefined' || typeof get_param.utm_medium !== 'undefined' || typeof get_param.utm_campaign !== 'undefined' || typeof get_param.utm_content !== 'undefined' || typeof get_param.utm_term !== 'undefined' || typeof get_param.gclid !== 'undefined' || typeof get_param.yclid !== 'undefined' || typeof get_param[p.campaign_param] !== 'undefined' || typeof get_param[p.term_param] !== 'undefined' || typeof get_param[p.content_param] !== 'undefined') {
                setFirstAndCurrentExtraData();
                result = getData(terms.traffic.utm)
            } else if (checkReferer(terms.traffic.organic)) {
                setFirstAndCurrentExtraData();
                result = getData(terms.traffic.organic)
            } else if (!cookies.get(data.containers.session) && checkReferer(terms.traffic.referral)) {
                setFirstAndCurrentExtraData();
                result = getData(terms.traffic.referral)
            } else if (!cookies.get(data.containers.first) && !cookies.get(data.containers.current)) {
                setFirstAndCurrentExtraData();
                result = getData(terms.traffic.typein)
            } else {
                return cookies.get(data.containers.current)
            }
            return result
        }
        function getData(type) {
            switch (type) {
            case terms.traffic.utm:
                _s_type = terms.traffic.utm;
                if (typeof get_param.utm_source !== 'undefined') {
                    _s_source = get_param.utm_source
                } else if (typeof get_param.gclid !== 'undefined') {
                    _s_source = 'google'
                } else if (typeof get_param.yclid !== 'undefined') {
                    _s_source = 'yandex'
                } else {
                    _s_source = terms.none
                }
                if (typeof get_param.utm_medium !== 'undefined') {
                    _s_medium = get_param.utm_medium
                } else if (typeof get_param.gclid !== 'undefined') {
                    _s_medium = 'cpc'
                } else if (typeof get_param.yclid !== 'undefined') {
                    _s_medium = 'cpc'
                } else {
                    _s_medium = terms.none
                }
                if (typeof get_param.utm_campaign !== 'undefined') {
                    _s_campaign = get_param.utm_campaign
                } else if (typeof get_param[p.campaign_param] !== 'undefined') {
                    _s_campaign = get_param[p.campaign_param]
                } else if (typeof get_param.gclid !== 'undefined') {
                    _s_campaign = 'google_cpc'
                } else if (typeof get_param.yclid !== 'undefined') {
                    _s_campaign = 'yandex_cpc'
                } else {
                    _s_campaign = terms.none
                }
                if (typeof get_param.utm_content !== 'undefined') {
                    _s_content = get_param.utm_content
                } else if (typeof get_param[p.content_param] !== 'undefined') {
                    _s_content = get_param[p.content_param]
                } else {
                    _s_content = terms.none
                }
                if (typeof get_param.utm_term !== 'undefined') {
                    _s_term = get_param.utm_term
                } else if (typeof get_param[p.term_param] !== 'undefined') {
                    _s_term = get_param[p.term_param]
                } else {
                    _s_term = getUtmTerm() || terms.none
                }
                break;
            case terms.traffic.organic:
                _s_type = terms.traffic.organic;
                _s_source = _s_source || uri.getHost(document.referrer);
                _s_medium = terms.referer.organic;
                _s_campaign = terms.none;
                _s_content = terms.none;
                _s_term = terms.none;
                break;
            case terms.traffic.referral:
                _s_type = terms.traffic.referral;
                _s_source = _s_source || uri.getHost(document.referrer);
                _s_medium = _s_medium || terms.referer.referral;
                _s_campaign = terms.none;
                _s_content = uri.parse(document.referrer).path;
                _s_term = terms.none;
                break;
            case terms.traffic.typein:
                _s_type = terms.traffic.typein;
                _s_source = p.typein_attributes.source;
                _s_medium = p.typein_attributes.medium;
                _s_campaign = terms.none;
                _s_content = terms.none;
                _s_term = terms.none;
                break;
            default:
                _s_type = terms.oops;
                _s_source = terms.oops;
                _s_medium = terms.oops;
                _s_campaign = terms.oops;
                _s_content = terms.oops;
                _s_term = terms.oops
            }
            var _data = {
                type: _s_type,
                source: _s_source,
                medium: _s_medium,
                campaign: _s_campaign,
                content: _s_content,
                term: _s_term
            };
            return data.pack.main(_data)
        }
        function getUtmTerm() {
            var referer = document.referrer;
            if (get_param.utm_term) {
                return get_param.utm_term
            } else if (referer && uri.parse(referer).host && uri.parse(referer).host.match(/^(?:.*\.)?yandex\..{2,9}$/i)) {
                try {
                    return uri.getParam(uri.parse(document.referrer).query).text
                } catch (err) {
                    return false
                }
            } else {
                return false
            }
        }
        function checkReferer(type) {
            var referer = document.referrer;
            switch (type) {
            case terms.traffic.organic:
                return !!referer && checkRefererHost(referer) && isOrganic(referer);
            case terms.traffic.referral:
                return !!referer && checkRefererHost(referer) && isReferral(referer);
            default:
                return false
            }
        }
        function checkRefererHost(referer) {
            if (p.domain) {
                if (!isolate) {
                    var host_regex = new RegExp('^(?:.*\\.)?' + utils.escapeRegexp(domain) + '$','i');
                    return !uri.getHost(referer).match(host_regex)
                } else {
                    return uri.getHost(referer) !== uri.getHost(domain)
                }
            } else {
                return uri.getHost(referer) !== uri.getHost(document.location.href)
            }
        }
        function isOrganic(referer) {
            var y_host = 'yandex'
              , y_param = 'text'
              , g_host = 'google';
            var y_host_regex = new RegExp('^(?:.*\\.)?' + utils.escapeRegexp(y_host) + '\\..{2,9}$')
              , y_param_regex = new RegExp('.*' + utils.escapeRegexp(y_param) + '=.*')
              , g_host_regex = new RegExp('^(?:www\\.)?' + utils.escapeRegexp(g_host) + '\\..{2,9}$');
            if (!!uri.parse(referer).query && !!uri.parse(referer).host.match(y_host_regex) && !!uri.parse(referer).query.match(y_param_regex)) {
                _s_source = y_host;
                return true
            } else if (!!uri.parse(referer).host.match(g_host_regex)) {
                _s_source = g_host;
                return true
            } else if (!!uri.parse(referer).query) {
                for (var i = 0; i < p.organics.length; i++) {
                    if (uri.parse(referer).host.match(new RegExp('^(?:.*\\.)?' + utils.escapeRegexp(p.organics[i].host) + '$','i')) && uri.parse(referer).query.match(new RegExp('.*' + utils.escapeRegexp(p.organics[i].param) + '=.*','i'))) {
                        _s_source = p.organics[i].display || p.organics[i].host;
                        return true
                    }
                    if (i + 1 === p.organics.length) {
                        return false
                    }
                }
            } else {
                return false
            }
        }
        function isReferral(referer) {
            if (p.referrals.length > 0) {
                for (var i = 0; i < p.referrals.length; i++) {
                    if (uri.parse(referer).host.match(new RegExp('^(?:.*\\.)?' + utils.escapeRegexp(p.referrals[i].host) + '$','i'))) {
                        _s_source = p.referrals[i].display || p.referrals[i].host;
                        _s_medium = p.referrals[i].medium || terms.referer.referral;
                        return true
                    }
                    if (i + 1 === p.referrals.length) {
                        _s_source = uri.getHost(referer);
                        return true
                    }
                }
            } else {
                _s_source = uri.getHost(referer);
                return true
            }
        }
        function setFirstAndCurrentExtraData() {
            cookies.set(data.containers.current_extra, data.pack.extra(p.timezone_offset), lifetime, domain, isolate);
            if (!cookies.get(data.containers.first_extra)) {
                cookies.set(data.containers.first_extra, data.pack.extra(p.timezone_offset), lifetime, domain, isolate)
            }
        }
        (function setData() {
            cookies.set(data.containers.current, mainData(), lifetime, domain, isolate);
            if (!cookies.get(data.containers.first)) {
                cookies.set(data.containers.first, cookies.get(data.containers.current), lifetime, domain, isolate)
            }
            var visits, udata;
            if (!cookies.get(data.containers.udata)) {
                visits = 1;
                udata = data.pack.user(visits, p.user_ip)
            } else {
                visits = parseInt(cookies.parse(data.containers.udata)[cookies.unprefix(data.containers.udata)][data.aliases.udata.visits]) || 1;
                visits = cookies.get(data.containers.session) ? visits : visits + 1;
                udata = data.pack.user(visits, p.user_ip)
            }
            cookies.set(data.containers.udata, udata, lifetime, domain, isolate);
            var pages_count;
            if (!cookies.get(data.containers.session)) {
                pages_count = 1
            } else {
                pages_count = parseInt(cookies.parse(data.containers.session)[cookies.unprefix(data.containers.session)][data.aliases.session.pages_seen]) || 1;
                pages_count += 1
            }
            cookies.set(data.containers.session, data.pack.session(pages_count), p.session_length, domain, isolate)
        }
        )();
        return cookies.parse(data.containers)
    }
    var parentDomain = findParentDomain(appSettings.allowedDomains) || '';
    if (parentDomain.length < 5 || location.host.indexOf(parentDomain) < 0) {
        parentDomain = location.host
    }
    function getSessionData() {
        var s = getTrafficSource$1({
            session_length: 30,
            domain: {
                host: parentDomain,
                isolate: false
            }
        });
        return {
            type: s.current.typ,
            source: getNotNone(s.current.src),
            medium: getNotNone(s.current.mdm),
            campaign: getNotNone(s.current.cmp),
            content: getNotNone(s.current.cnt),
            term: getNotNone(s.current.trm),
            date: new Date(s.current_add.fd).getTime(),
            entry: getNotNone(s.current_add.ep),
            referrer: getNotNone(s.current_add.rf),
            gclid: getQueryStringParameter('gclid') || getQueryStringParameter('yclid') || null,
            dn_channel: getQueryStringParameter('dn_channel') || null,
            dn_send_id: getQueryStringParameter('dn_send_id') || null
        }
    }
    function resetSession() {
        document.cookie = '_dn_sid=; expires=Thu, 01 Jan 1970 00:00:00 UTC;domain=.' + parentDomain + '; path=/;'
    }
    function startSession() {
        var storedSessionId = getCookie('_dn_sid');
        var storedData = storage.get('session');
        var data = getSessionData();
        if (storedData.id) {
            var _old = storedData;
            _old = _old.type + '-' + _old.source + '-' + _old.medium + '-' + _old.campaign;
            var _new = data.type + '-' + data.source + '-' + data.medium + '-' + data.campaign;
            logInfo('_old', _old);
            logInfo('_new', _new);
            if (_old != _new) {
                storedSessionId = null
            }
        }
        var todayNumber = Math.floor(Date.now() / (24 * 60 * 60 * 1e3));
        var lastDayNumber = storage.getInt('extra.curr_day');
        if (lastDayNumber != todayNumber) {
            storedSessionId = null;
            var visits = storage.get('visits') || [];
            var vc = storage.get('extra.visit') || 1;
            var pview = storage.get('extra.pview') || 1;
            visits.push([lastDayNumber, vc, pview]);
            visits = visits.filter((function(v) {
                return v[0] > todayNumber - 90
            }
            ));
            storage.set('visits', visits.slice());
            storage.set('extra.curr_day', todayNumber);
            storage.set('extra.visit', 0);
            storage.set('extra.pview', 0)
        }
        var sessionId = storedSessionId || generateUUID();
        var now = new Date;
        now.setTime(now.getTime() + 30 * 60 * 1e3);
        document.cookie = '_dn_sid=' + sessionId + '; path=/; domain=.' + parentDomain + '; expires=' + now.toUTCString() + ';';
        data.id = sessionId;
        if (!storedSessionId) {
            data.pviv = 1;
            storage.set('extra.last_visit', storedData.id ? storedData.date : data.date);
            data.first = !storedData.id;
            data.date = Date.now();
            storage.increment('extra.visit');
            sendSession(data)
        } else {
            data.gclid = storedData.gclid;
            data.dn_channel = storedData.dn_channel;
            data.dn_send_id = storedData.dn_send_id;
            data.pviv = (parseInt(storedData.pviv) || 0) + 1;
            data.first = storedData.first || false
        }
        storage.set('session', data);
        storage.increment('extra.pview');
        logInfo('Session', data);
        var debug = getQueryStringParameter('dn_debug') || null;
        if (debug == 'true') {
            storage.set('extra.debug', true)
        } else if (debug == 'false') {
            storage.set('extra.debug', true)
        } else {
            storage.set('extra.debug', false)
        }
        var contact_key = getQueryStringParameter('dn_contact_key') || null;
        if (contact_key) {
            setContactKey(contact_key)
        }
    }
    function getNotNone(val) {
        return val == '(none)' ? null : val
    }
    function sendSession(data) {
        var eventData = {
            utm_source: data.source,
            utm_medium: data.medium,
            utm_campaign: data.campaign,
            utm_content: data.content,
            utm_term: data.term,
            referer: data.referer,
            gclid: data.gclid,
            channel: data.dn_channel,
            send_id: data.dn_send_id
        };
        sendDeviceEvent('session_info', eventData)
    }
    var isStarted$1 = false;
    var triggerAfterStart = false;
    var aboutToSend = false;
    function triggerSend() {
        if (isStarted$1 == false) {
            triggerAfterStart = true;
            return
        }
        if (aboutToSend == false) {
            aboutToSend = true;
            setTimeout((function() {
                aboutToSend = false;
                saveSubscriptionCookie();
                sendSubscription()
            }
            ), 1e3)
        }
    }
    function start$4() {
        if (getToken() == null && isSendEventEnabled() == false && shouldOnsiteManagerStart() == false) {
            return
        }
        isStarted$1 = true;
        if (triggerAfterStart) {
            triggerSend()
        }
    }
    function setDeviceId(value) {
        var deviceId = normalizeLong$1(value);
        if (deviceId && getDeviceId() != deviceId) {
            storage.set('device_id', deviceId);
            triggerSend()
        }
    }
    function getDeviceId() {
        var deviceId = normalizeLong$1(storage.get('device_id'));
        if (!deviceId) {
            deviceId = deviceId || generateUUID();
            resetSession();
            storage.set('device_id', deviceId);
            triggerSend()
        }
        return deviceId
    }
    function getContactKey() {
        var val = storage.get('contact_key');
        return normalizeShort$1(val)
    }
    function setContactKey(value, isOnlyStorage) {
        if (getContactKey() != normalizeShort$1(value)) {
            storage.set('contact_key', normalizeShort$1(value) || '');
            if (!isOnlyStorage) {
                triggerSend()
            }
        }
    }
    function getToken() {
        var val = storage.get('webpush.token');
        return normalizeLong$1(val)
    }
    function setToken(value) {
        if (getToken() != normalizeLong$1(value)) {
            storage.set('webpush.token', normalizeLong$1(value) || '');
            triggerSend();
            if (isStarted$1 == false) {
                start$4()
            }
        }
    }
    function getTokenType() {
        var val = storage.get('webpush.type');
        return normalizeShort$1(val)
    }
    function setTokenType(value) {
        if (getTokenType() != normalizeShort$1(value)) {
            storage.set('webpush.type', normalizeShort$1(value) || '');
            triggerSend()
        }
    }
    function getWebSubscription() {
        var val = storage.get('webpush.sub');
        return normalizeLong$1(val)
    }
    function setWebSubscription(value) {
        if (getWebSubscription() != normalizeLong$1(value)) {
            storage.set('webpush.sub', normalizeLong$1(value) || '');
            triggerSend()
        }
    }
    function getUserPermission() {
        var val = storage.get('webpush.user_perm');
        return normalizeShort$1(val)
    }
    function setUserPermission(value) {
        if (getUserPermission() != normalizeShort$1(value)) {
            storage.set('webpush.user_perm', normalizeShort$1(value) || '');
            triggerSend()
        }
    }
    function getTrackingPermission() {
        var val = storage.get('extra.tracking_perm');
        return normalizeShort$1(val) || true
    }
    function setTrackingPermission(value) {
        if (getTrackingPermission() != normalizeShort$1(value)) {
            storage.set('extra.tracking_perm', normalizeShort$1(value) || '');
            triggerSend()
        }
    }
    function getCountry() {
        var val = storage.get('extra.country');
        return normalizeShort$1(val)
    }
    function setCountry(value) {
        if (getCountry() != normalizeShort$1(value)) {
            storage.set('extra.country', normalizeShort$1(value) || '');
            triggerSend()
        }
    }
    function sendSubscription() {
        var userPermission = getUserPermission();
        var deviceId = getDeviceId();
        var data = {
            integrationKey: 'dPfs6p5b_p_l_K_p_l__p_l_Y8VhrU2Wl91zleK2npa6cHKyW63dele1dg1G8vRtwZkmRAPmJcPgEQqUSIlB_p_l_674Du7Pb0qg1P3KcPIP3ZPlx9_s_l_lfKmDy57YLwa_p_l_yWHfmVuQLWCqgrKUQ8xYSN3AC4BMvMRyJ1Z8JQ_e_q__e_q_',
            token: getToken(),
            contactKey: getContactKey(),
            permission: userPermission == null || userPermission == 'true' ? true : false,
            udid: deviceId,
            advertisingId: '',
            carrierId: null,
            appVersion: null,
            sdkVersion: '1.5.1',
            trackingPermission: getTrackingPermission(),
            webSubscription: getWebSubscription(),
            tokenType: getTokenType(),
            timezone: getTimezone(),
            language: navigator.language || navigator.userLanguage,
            country: getCountry()
        };
        fetch('https://dev-push.dengage.com/api/web/subscription', {
            method: 'POST',
            mode: 'cors',
            cache: 'no-cache',
            credentials: 'omit',
            headers: {
                'Content-Type': 'text/plain'
            },
            body: JSON.stringify(data)
        }).catch((function(e) {
            logError(e.toString())
        }
        ))
    }
    function saveSubscriptionCookie() {
        if (appSettings.subdomainDataSync) {
            var cookieData = {
                deviceId: getDeviceId(),
                tokenType: getTokenType(),
                token: getToken(),
                webSubscription: getWebSubscription(),
                contactKey: getContactKey(),
                webpushDomain: _Dn_globaL_.cookieData.webpushDomain
            };
            var cookieStr = encodeCookieData(cookieData);
            document.cookie = '_dn_data=' + cookieStr + '; path=/; domain=.' + findParentDomain(appSettings.allowedDomains);
            _Dn_globaL_.cookieData = cookieData
        }
    }
    function normalizeShort$1(val) {
        if (!val || val === 'null') {
            return null
        }
        return val
    }
    function normalizeLong$1(val) {
        if (!val || typeof val == 'string' && val.length < 10) {
            return null
        }
        return val
    }
    function setLogLevel(level) {
        if (level == 'info' || level == 'error' || level == 'none') {
            storage.set('extra.log_level', level);
            window._Dn_globaL_.logLevel = level
        } else {
            console.error('dengage: wrong log level')
        }
    }
    function isDebugMode() {
        return storage.get('extra.debug') + '' == 'true'
    }
    function getTotalVisitCount(lastXDays) {
        lastXDays = lastXDays || 91;
        var todayNumber = Math.floor(Date.now() / (24 * 60 * 60 * 1e3));
        var minDay = todayNumber - lastXDays;
        var result = storage.getInt('extra.visit');
        var visits = storage.getInt('visits') || [];
        visits.forEach((function(v) {
            if (getInt(v[0]) >= minDay) {
                result += getInt(v[1])
            }
        }
        ));
        return result
    }
    function getTotalPageViewCount() {
        var result = storage.getInt('extra.pview');
        var visits = storage.getInt('visits') || [];
        visits.forEach((function(v) {
            result += getInt(v[2])
        }
        ));
        return result
    }
    function fetchVisitorInfo() {
        var storageVisitorInfo = storage.get('visitor_info');
        var lastVisitorInfoTime = new Date(Number(storageVisitorInfo === null || storageVisitorInfo === void 0 ? void 0 : storageVisitorInfo.last_request_time) || 0).getTime();
        var lastRequestUrl = storageVisitorInfo === null || storageVisitorInfo === void 0 ? void 0 : storageVisitorInfo.last_request_url;
        var contactKey = getContactKey();
        var url = "https://dev-push.dengage.com/api/audience/visitor-info?acc=90db7e2a-5839-53cd-605f-9d3ffc328e21&did=".concat(getDeviceId()).concat(contactKey ? '&ckey=' + contactKey : '');
        if (!storageVisitorInfo || lastRequestUrl !== url || (new Date).getTime() - lastVisitorInfoTime > 2.5 * 60 * 1e3) {
            return fetch(url).then((function(response) {
                return response.json()
            }
            )).then((function(visitorInfo) {
                storage.set('visitor_info.last_request_time', (new Date).getTime());
                storage.set('visitor_info.last_request_url', url);
                storage.set('visitor_info.tags', visitorInfo.Tags.map((function(tag) {
                    return String(tag)
                }
                )) || []);
                storage.set('visitor_info.segments', visitorInfo.Segments.map((function(segment) {
                    return String(segment)
                }
                )) || []);
                storage.set('visitor_info.attrs', visitorInfo.Attrs || {})
            }
            )).catch(logError).finally((function() {
                return Promise.resolve()
            }
            ))
        } else
            return Promise.resolve()
    }
    function getInt(num) {
        return parseInt(num) || 0
    }
    function deepCopy(input) {
        return JSON.parse(JSON.stringify(input))
    }
    function objectAssign(target, varArgs) {
        if (target === null || target === undefined) {
            throw new TypeError('Cannot convert undefined or null to object')
        }
        var to = Object(target);
        for (var index = 1; index < arguments.length; index++) {
            var nextSource = arguments[index];
            if (nextSource !== null && nextSource !== undefined) {
                for (var nextKey in nextSource) {
                    if (Object.prototype.hasOwnProperty.call(nextSource, nextKey) && nextSource[nextKey] !== undefined) {
                        to[nextKey] = nextSource[nextKey]
                    }
                }
            }
        }
        return to
    }
    function shadeHexColor(color, percent) {
        var f = parseInt(color.slice(1), 16)
          , t = percent < 0 ? 0 : 255
          , p = percent < 0 ? percent * -1 : percent
          , R = f >> 16
          , G = f >> 8 & 255
          , B = f & 255;
        return '#' + (16777216 + (Math.round((t - R) * p) + R) * 65536 + (Math.round((t - G) * p) + G) * 256 + (Math.round((t - B) * p) + B)).toString(16).slice(1)
    }
    function getFontFamily(font) {
        switch (font) {
        case 'ARIAL':
            return 'Helvetica, Arial, sans-serif';
        case 'TAHOMA':
            return 'Tahoma, sans-serif';
        case 'VERDANA':
            return 'Verdana, sans-serif';
        case 'GEORGIA':
            return 'Georgia, Times, serif';
        case 'TIMES':
            return '"Times New Roman", Times, serif';
        case 'COURIER':
            return '"Courier New", Courier, monospace'
        }
        return 'inherit'
    }
    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (function(c) {
            var r = Math.random() * 16 | 0
              , v = c == 'x' ? r : r & 3 | 8;
            return v.toString(16).toLowerCase()
        }
        ))
    }
    function logError() {
        var level = window._Dn_globaL_.storage.extra ? window._Dn_globaL_.storage.extra.log_level : 'error';
        if (isDebugMode() || level != 'none') {
            var _console;
            for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
                args[_key] = arguments[_key]
            }
            (_console = console).error.apply(_console, ['dengage: '].concat(args))
        }
    }
    function logWarning() {
        var level = window._Dn_globaL_.storage.extra ? window._Dn_globaL_.storage.extra.log_level : 'error';
        if (isDebugMode() || level != 'none') {
            var _console2;
            for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
                args[_key2] = arguments[_key2]
            }
            (_console2 = console).warn.apply(_console2, ['dengage: '].concat(args))
        }
    }
    function logInfo() {
        var level = window._Dn_globaL_.storage.extra ? window._Dn_globaL_.storage.extra.log_level : 'error';
        if (isDebugMode() || level == 'info') {
            var _console3;
            for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
                args[_key3] = arguments[_key3]
            }
            (_console3 = console).log.apply(_console3, ['dengage: '].concat(args))
        }
    }
    function errorLoggerResolved(errorText, resolveValue) {
        return function(input) {
            logError(errorText, input);
            return resolveValue
        }
    }
    function errorLoggerRejected(errorText, rejectValue) {
        return function(input) {
            logError(errorText, input);
            return Promise.reject(rejectValue)
        }
    }
    function arrayBufferToBase64(buffer) {
        var binary = '';
        var bytes = new Uint8Array(buffer);
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i])
        }
        return window.btoa(binary)
    }
    function base64Normalize(input) {
        return input.replace(/\-/g, '+').replace(/\_/g, '/').replace(/^\=+|\=+$/g, '')
    }
    function getQueryStringParameter(name, url) {
        if (!url)
            url = window.location.href;
        name = name.replace(/[\[\]]/g, '\\$&');
        var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)')
          , results = regex.exec(url);
        if (!results)
            return null;
        if (!results[2])
            return '';
        return decodeURIComponent(results[2].replace(/\+/g, ' '))
    }
    function DateParse(datelike) {
        var date = datelike instanceof Date ? datelike : new Date(datelike);
        var result = date.getTime();
        if (isNaN(result)) {
            return 0
        }
        return result
    }
    function isIsoDate(str) {
        if (!/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/.test(str))
            return false;
        var d = new Date(str);
        return d.toISOString() === str
    }
    function isBlinkBrowser() {
        var isOpera = !!window.opr && !!opr.addons || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;
        var isChrome = !!window.chrome && (!!window.chrome.webstore || !!window.chrome.runtime);
        return (isChrome || isOpera) && !!window.CSS
    }
    function isFirefoxBrowser() {
        return typeof InstallTrigger !== 'undefined'
    }
    function toInt$1(input) {
        if (typeof input == 'number') {
            return input
        }
        if (typeof input == 'string') {
            return input === '' ? 0 : parseInt(input)
        }
        return 0
    }
    function runOnWindowLoaded(func) {
        if (document.readyState == 'complete') {
            func()
        } else {
            window.addEventListener('load', (function() {
                func()
            }
            ))
        }
    }
    function findParentDomain(domains) {
        if (_typeof(domains) != 'object' || domains.length == 0) {
            return ''
        }
        if (domains.length == 1) {
            return domains[0]
        }
        var level = 0;
        while (true) {
            var parts = domains.map((function(d) {
                return d.split('.').reverse()[level]
            }
            ));
            var allEqual = true;
            for (var i = 1; i < parts.length; i++) {
                if (parts[i] != parts[i - 1]) {
                    allEqual = false
                }
            }
            if (allEqual) {
                level++
            } else {
                break
            }
        }
        return domains[0].split('.').reverse().slice(0, level).reverse().join('.')
    }
    function getCookie(name) {
        var cookieArr = document.cookie.split(';');
        for (var i = 0; i < cookieArr.length; i++) {
            var cookiePair = cookieArr[i].split('=');
            if (name == cookiePair[0].trim()) {
                return decodeURIComponent(cookiePair[1])
            }
        }
        return null
    }
    function waitUntil(condFunc, deadline) {
        var start = (new Date).getTime();
        deadline = deadline || 12e4;
        return new Promise((function(resolve, reject) {
            function check() {
                if (condFunc()) {
                    resolve()
                } else {
                    var diff = (new Date).getTime() - start;
                    if (diff >= deadline) {
                        reject()
                    } else {
                        diff = diff < 1 ? 1 : diff;
                        var waitTime = diff < 1e3 ? diff : diff < 5e3 ? 500 : 1e3;
                        setTimeout(check, waitTime)
                    }
                }
            }
            check()
        }
        ))
    }
    function pad(number, length) {
        var str = '' + number;
        while (str.length < length) {
            str = '0' + str
        }
        return str
    }
    function pushIfNotExists(array, item) {
        if (array.indexOf(item) == -1) {
            array.push(item)
        }
    }
    function loadScript(src, callback) {
        var s, r, t;
        r = false;
        s = document.createElement('script');
        s.type = 'text/javascript';
        s.src = src;
        s.onload = s.onreadystatechange = function() {
            if (!r && (!this.readyState || this.readyState == 'complete')) {
                r = true;
                if (callback) {
                    callback()
                }
            }
        }
        ;
        t = document.getElementsByTagName('script')[0];
        t.parentNode.insertBefore(s, t)
    }
    function getTimezone() {
        var offset = (new Date).getTimezoneOffset();
        return 'GMT' + (offset <= 0 ? '+' : '-') + pad(parseInt(Math.abs(offset / 60)), 2) + ':' + pad(Math.abs(offset % 60), 2)
    }
    function normalizeShort(val) {
        if (!val || val === 'null') {
            return null
        }
        return val
    }
    function normalizeLong(val) {
        if (!val || typeof val == 'string' && val.length < 10) {
            return null
        }
        return val
    }
    function jsonParse(input, defaultVal) {
        try {
            return JSON.parse(input) || defaultVal
        } catch (e) {
            return null
        }
    }
    function isEqual(val1, val2) {
        if (_typeof(val1) !== _typeof(val2)) {
            return false
        }
        if (Array.isArray(val1) && Array.isArray(val2)) {
            return val1.length === val2.length && val1.every((function(item, index) {
                return val2[index] === item
            }
            ))
        }
        if (_typeof(val1) === 'object') {
            var keys1 = Object.keys(val1)
              , keys2 = Object.keys(val2);
            return (keys1.length > keys2.length ? keys1 : keys2).every((function(key) {
                return isEqual(val1[key], val2[key])
            }
            ))
        }
        return val1 === val2
    }
    function generateSlideHtml(appSettings) {
        var language = (document.documentElement.lang || appSettings.defaultLanguage || navigator.language).toLowerCase();
        var slideSettings = Array.isArray(appSettings.slideSettings) ? appSettings.slideSettings.find((function(settings) {
            return language.includes((settings.language || '').toLowerCase())
        }
        )) : appSettings.slideSettings;
        var mainColor = slideSettings.mainColor || '#1165f1';
        var theme = slideSettings.theme || 'BOTTOM_BTNS';
        var slide = {
            location: slideSettings.location || 'TOP_CENTER',
            showIcon: slideSettings.showIcon || false,
            title: slideSettings.showTitle ? slideSettings.title || '' : '',
            text: slideSettings.text || "We'd like to show you notifications for the latest news and updates.",
            acceptBtnText: slideSettings.acceptBtnText || 'Allow',
            cancelBtnText: slideSettings.cancelBtnText || 'No Thanks',
            fixed: slideSettings.fixed || false
        };
        var details = {};
        if (slideSettings.advancedOptions) {
            details = fixMissingSlideDetails(slideSettings.details, mainColor)
        } else {
            details = getDefaultSlideDetails(mainColor)
        }
        return "\n<div class=\"dn-slide ".concat(slide.showIcon ? '' : 'dn-slide--noLogo', " ").concat(slide.title ? '' : 'dn-slide--noTitle', " ").concat(theme, "\">\n  <div class=\"dn-slide-logo\"><img src=\"").concat(appSettings.defaultIconUrl, "\"></div>\n  <div class=\"dn-slide-body\">\n      <div class=\"dn-slide-title\">").concat(slide.title, "</div>\n      <p class=\"dn-slide-message\">").concat(slide.text, "</p>\n      <div class=\"dn-slide-buttons horizontal\">\n          <button class=\"dn-slide-deny-btn\">").concat(slide.cancelBtnText, "</button>\n          <button class=\"dn-slide-accept-btn\">").concat(slide.acceptBtnText, "</button>\n      </div>\n  </div>\n  <div class=\"dn-slide-buttons vertical\">\n      <button class=\"dn-slide-accept-btn\">").concat(slide.acceptBtnText, "</button>\n      <button class=\"dn-slide-deny-btn\">").concat(slide.cancelBtnText, "</button>\n  </div>\n</div>\n<style>\n\n  #dengage-push-perm-slide {\n    position: ").concat(slide.fixed ? 'fixed' : 'absolute', " !important;\n    width: 520px !important;\n    z-index: 100000000 !important;\n  }\n  #dengage-push-perm-slide.dn-top {\n    top: -260px !important;\n  }\n  #dengage-push-perm-slide.dn-bottom {\n    bottom: -260px !important;\n  }\n  #dengage-push-perm-slide.dn-top.dn-opened {\n    top: 0 !important;\n  }\n  #dengage-push-perm-slide.dn-bottom.dn-opened {\n    bottom: 0 !important;\n  }\n  #dengage-push-perm-slide.dn-center {\n    left: 50% !important;\n    margin-left: -260px !important;\n  }\n  #dengage-push-perm-slide.dn-right {\n    right: 0 !important;\n  }\n  #dengage-push-perm-slide.dn-left {\n    left: 0 !important;\n  }\n  .dn-slide {\n      box-shadow: ").concat(details.shadow ? '0 3px 10px 0 rgba(0, 0, 0, 0.43)' : 'none', " !important;\n      background: ").concat(details.backgroundColor, " !important;\n      border: ").concat(details.border, "px solid ").concat(details.borderColor, " !important;\n      border-radius: ").concat(details.borderRadius, "px !important;\n      display: flex !important;\n      overflow: auto !important;\n      width: 520px !important;\n      max-width: 520px !important;\n      height: auto !important;\n  }\n\n  .dn-slide-logo {\n      width: 30% !important;\n      padding: 15px !important;\n      box-sizing: border-box !important;\n      display: flex !important;\n      justify-content: center !important;\n      align-items: center !important;\n  }\n  .RIGHT_BTNS .dn-slide-logo {\n      width: 18% !important;\n      padding: 8px !important;\n  }\n  .dn-slide-logo img {\n      width: 100% !important;\n      opacity: 1 !important;\n  }\n  .dn-slide--noLogo .dn-slide-logo {\n      display: none !important;\n  }\n\n  .dn-slide-body {\n      width: 70% !important;\n      padding: 15px !important;\n      box-sizing: border-box !important;\n      line-height: 1.4 !important;\n      vertical-align: middle !important;\n      display: flex !important;\n      flex-direction: column !important;\n  }\n  .RIGHT_BTNS .dn-slide-body {\n      width: 58% !important;\n      padding: 8px !important;\n  }\n  .dn-slide--noLogo .dn-slide-body {\n      width: 100% !important;\n  }\n\n  .dn-slide-title {\n      background: none !important;\n      color: ").concat(details.titleSyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.titleSyle.fontSize, "px !important;\n      font-weight: ").concat(details.titleSyle.fontWeight, " !important;\n      margin: 0 !important;\n      padding: 0 !important;\n  }\n  .dn-slide--noTitle .dn-slide-title {\n      display: none !important;\n  }\n\n  .dn-slide-message {\n      background: none !important;\n      color: ").concat(details.textSyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.textSyle.fontSize, "px !important;\n      font-weight: ").concat(details.textSyle.fontWeight, " !important;\n      padding: 0 !important;\n      margin: 12px 0 !important;\n      flex: 1 !important;\n  }\n  .dn-slide--noTitle .dn-slide-message {\n      margin: 5px 0 20px 10px !important;\n  }\n\n  .dn-slide-buttons {\n      display: flex !important;\n  }\n  .dn-slide-buttons.vertical {\n      flex-direction: column !important;\n      justify-content: center !important;\n      align-items: center !important;\n      width: 24% !important;\n      padding: 8px !important;\n  }\n  .dn-slide-buttons.horizontal {\n      justify-content: flex-end !important;\n      align-items: center !important;\n  }\n  .BOTTOM_BTNS .vertical {\n      display: none !important;\n  }\n  .RIGHT_BTNS .horizontal {\n      display: none !important;\n  }\n  .dn-slide-buttons button {\n      padding: 8px 15px !important;\n      margin: 0 !important;\n      text-align: center !important;\n      cursor: pointer !important;\n  }\n  .dn-slide-buttons.horizontal button {\n      margin-left: 15px !important;\n  }\n  .dn-slide-buttons.vertical button {\n      width: 100% !important;\n  }\n  .dn-slide-buttons.vertical button:first-child {\n      margin-bottom: 5px !important;\n  }\n\n  .dn-slide-buttons .dn-slide-accept-btn {\n      background-color: ").concat(details.acceptBtnStyle.backgroundColor, " !important;\n      color: ").concat(details.acceptBtnStyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.acceptBtnStyle.fontSize, "px !important;\n      font-weight: ").concat(details.acceptBtnStyle.fontWeight, " !important;\n      border: ").concat(details.acceptBtnStyle.border, "px solid ").concat(details.acceptBtnStyle.borderColor, " !important;\n      border-radius: ").concat(details.acceptBtnStyle.borderRadius, "px !important;\n      box-shadow: ").concat(details.acceptBtnStyle.shadow ? '0 2px 5px 0 rgba(0, 0, 0, 0.4)' : 'none', " !important;\n  }\n  .dn-slide-buttons .dn-slide-accept-btn:hover {\n      background-color: ").concat(details.acceptBtnStyle.hoverBackgroundColor, " !important;\n      color: ").concat(details.acceptBtnStyle.hoverTextColor, " !important;\n  }\n\n  .dn-slide-buttons .dn-slide-deny-btn {\n      background-color: ").concat(details.cancelBtnStyle.backgroundColor, " !important;\n      color: ").concat(details.cancelBtnStyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.cancelBtnStyle.fontSize, "px !important;\n      font-weight: ").concat(details.cancelBtnStyle.fontWeight, " !important;\n      border: ").concat(details.cancelBtnStyle.border, "px solid ").concat(details.cancelBtnStyle.borderColor, " !important;\n      border-radius: ").concat(details.cancelBtnStyle.borderRadius, "px !important;\n      box-shadow: ").concat(details.cancelBtnStyle.shadow ? '0 2px 5px 0 rgba(0, 0, 0, 0.4)' : 'none', " !important;\n  }\n  .dn-slide-buttons .dn-slide-deny-btn:hover {\n      background-color: ").concat(details.cancelBtnStyle.hoverBackgroundColor, " !important;\n      color: ").concat(details.cancelBtnStyle.hoverTextColor, " !important;\n  }\n\n  @media only screen and (max-width: 500px) {\n      #dengage-push-perm-slide {\n        width: 100% !important;\n        margin-left: 0 !important;\n        left:0 !important;\n      }\n      #dengage-push-perm-slide.dn-center {\n        left: 0 !important;\n        margin-left: 0 !important;\n      }\n      #dengage-push-perm-slide.dn-right {\n        left: 0 !important;\n        right: 0 !important;\n        margin-left: 0 !important;\n      }\n\n      .dn-slide {\n          width: 100% !important;\n          max-width: 100% !important;\n      }\n\n      .dn-slide-logo {\n          width: 20% !important;\n          padding: 10px !important;\n      }\n\n      .dn-slide-body, .RIGHT_BTNS .dn-slide-body {\n          padding: 10px !important;\n          width: unset !important;\n          flex-grow: 1;\n      }\n\n      .dn-slide-title {\n          font-size: 12px !important;\n      }\n\n      .dn-slide-message {\n          font-size: 12px !important;\n          margin: 8px 0 !important;\n      }\n\n      .dn-slide-buttons.vertical {\n          width: 25% !important;\n      }\n\n      .dn-slide-buttons button {\n          padding: 6px 8px !important;\n      }\n\n      .dn-slide-buttons.horizontal button {\n          margin-left: 8px !important;\n      }\n\n      .dn-slide-buttons .dn-slide-accept-btn {\n          font-size: ").concat(details.acceptBtnStyle.fontSize * .75, "px !important;\n      }\n\n      .dn-slide-buttons .dn-slide-deny-btn {\n          font-size: ").concat(details.cancelBtnStyle.fontSize * .75, "px !important;\n      }\n\n  }\n</style>\n    ")
    }
    function getDefaultSlideDetails(mainColor) {
        return {
            backgroundColor: '#ffffff',
            fontFamily: 'ARIAL',
            border: 0,
            borderColor: mainColor,
            borderRadius: 3,
            shadow: true,
            textSyle: {
                textColor: '#555555',
                fontSize: '15',
                fontWeight: 'normal'
            },
            titleSyle: {
                textColor: '#555555',
                fontSize: '16',
                fontWeight: 'bold'
            },
            acceptBtnStyle: {
                backgroundColor: mainColor,
                hoverBackgroundColor: shadeHexColor(mainColor, -.2),
                textColor: '#ffffff',
                hoverTextColor: '#ffffff',
                fontSize: '16',
                fontWeight: 'normal',
                border: 0,
                borderColor: mainColor,
                borderRadius: 3,
                shadow: false
            },
            cancelBtnStyle: {
                backgroundColor: '#ffffff',
                hoverBackgroundColor: '#ffffff',
                textColor: mainColor,
                hoverTextColor: shadeHexColor(mainColor, -.2),
                fontSize: '16',
                fontWeight: 'normal',
                border: 0,
                borderColor: mainColor,
                borderRadius: 3,
                shadow: false
            }
        }
    }
    function fixMissingSlideDetails(details, mainColor) {
        var textSyle = details.textSyle || {};
        var titleSyle = details.titleSyle || {};
        var acceptBtnStyle = details.acceptBtnStyle || {};
        var cancelBtnStyle = details.cancelBtnStyle || {};
        return {
            backgroundColor: details.backgroundColor || '#ffffff',
            fontFamily: details.fontFamily || 'ARIAL',
            border: details.border || 0,
            borderColor: details.borderColor || mainColor,
            borderRadius: details.borderRadius || 3,
            shadow: details.shadow == null ? true : details.shadow,
            textSyle: {
                textColor: textSyle.textColor || '#555555',
                fontSize: textSyle.fontSize || '15',
                fontWeight: textSyle.fontWeight || 'normal'
            },
            titleSyle: {
                textColor: titleSyle.textColor || '#555555',
                fontSize: titleSyle.fontSize || '16',
                fontWeight: titleSyle.fontWeight || 'bold'
            },
            acceptBtnStyle: {
                backgroundColor: acceptBtnStyle.backgroundColor || mainColor,
                hoverBackgroundColor: acceptBtnStyle.hoverBackgroundColor || shadeHexColor(mainColor, -.2),
                textColor: acceptBtnStyle.textColor || '#ffffff',
                hoverTextColor: acceptBtnStyle.hoverTextColor || '#ffffff',
                fontSize: acceptBtnStyle.fontSize || '16',
                fontWeight: acceptBtnStyle.fontWeight || 'normal',
                border: acceptBtnStyle.border || 0,
                borderColor: acceptBtnStyle.borderColor || mainColor,
                borderRadius: acceptBtnStyle.borderRadius || 3,
                shadow: acceptBtnStyle.shadow == null ? false : acceptBtnStyle.shadow
            },
            cancelBtnStyle: {
                backgroundColor: cancelBtnStyle.backgroundColor || '#ffffff',
                hoverBackgroundColor: cancelBtnStyle.hoverBackgroundColor || '#ffffff',
                textColor: cancelBtnStyle.textColor || mainColor,
                hoverTextColor: cancelBtnStyle.hoverTextColor || shadeHexColor(mainColor, -.2),
                fontSize: cancelBtnStyle.fontSize || '16',
                fontWeight: cancelBtnStyle.fontWeight || 'normal',
                border: cancelBtnStyle.border || 0,
                borderColor: cancelBtnStyle.borderColor || mainColor,
                borderRadius: cancelBtnStyle.borderRadius || 3,
                shadow: cancelBtnStyle.shadow == null ? false : cancelBtnStyle.shadow
            }
        }
    }
    function showSlidePromt(appSettings, isPreview) {
        var container = document.createElement('div');
        var className = 'dengage-push-perm-slide';
        container.id = 'dengage-push-perm-slide';
        var language = (document.documentElement.lang || appSettings.defaultLanguage || navigator.language).toLowerCase();
        var slideSettings = Array.isArray(appSettings.slideSettings) ? appSettings.slideSettings.find((function(settings) {
            return language.includes((settings.language || '').toLowerCase())
        }
        )) : appSettings.slideSettings;
        if (slideSettings.location.indexOf('TOP') != -1) {
            className += ' dn-top'
        }
        if (slideSettings.location.indexOf('BOTTOM') != -1) {
            className += ' dn-bottom'
        }
        if (slideSettings.location.indexOf('CENTER') != -1) {
            className += ' dn-center'
        }
        if (slideSettings.location.indexOf('RIGHT') != -1) {
            className += ' dn-right'
        }
        if (slideSettings.location.indexOf('LEFT') != -1) {
            className += ' dn-left'
        }
        container.className = className;
        if (!isPreview) {
            container.style.transition = 'top 1s linear'
        }
        container.innerHTML = generateSlideHtml(appSettings);
        document.body.appendChild(container);
        setTimeout((function() {
            container.className += ' dn-opened'
        }
        ), 50);
        return {
            onAccept: function onAccept(callback) {
                var btns = container.querySelectorAll('.dn-slide-accept-btn');
                for (var i = 0; i < btns.length; i++) {
                    btns[i].addEventListener('click', (function() {
                        container.classList.remove('dn-opened');
                        callback();
                        setTimeout((function() {
                            document.body.removeChild(container)
                        }
                        ), 1e3)
                    }
                    ))
                }
            },
            onDeny: function onDeny(callback) {
                var btns = container.querySelectorAll('.dn-slide-deny-btn');
                for (var i = 0; i < btns.length; i++) {
                    btns[i].addEventListener('click', (function() {
                        container.classList.remove('dn-opened');
                        callback();
                        setTimeout((function() {
                            document.body.removeChild(container)
                        }
                        ), 1e3)
                    }
                    ))
                }
            }
        }
    }
    function generateBannerHtml$1(appSettings) {
        var language = (document.documentElement.lang || appSettings.defaultLanguage || navigator.language).toLowerCase();
        var bannerSettings = Array.isArray(appSettings.bannerSettings) ? appSettings.bannerSettings.find((function(settings) {
            return language.includes((settings.language || '').toLowerCase())
        }
        )) : appSettings.bannerSettings;
        var mainColor = bannerSettings.mainColor || '#333333';
        var banner = {
            location: bannerSettings.location || 'BOTTOM',
            showIcon: bannerSettings.showIcon || false,
            text: bannerSettings.text || "We'd like to show you notifications for the latest news and updates.",
            acceptBtnText: bannerSettings.acceptBtnText || 'Allow',
            fixed: bannerSettings.fixed || false
        };
        var details = {};
        if (bannerSettings.advancedOptions) {
            details = fixMissingBannerDetails(bannerSettings.details, mainColor)
        } else {
            details = getDefaultBannerDetails(mainColor)
        }
        return "\n<div class=\"dn-banner ".concat(banner.showIcon ? '' : 'dn-banner--noLogo', "\">\n  <div class=\"dn-banner-logo\"><img src=\"").concat(appSettings.defaultIconUrl, "\"></div>\n  <div class=\"dn-banner-text\">\n    ").concat(banner.text, "\n  </div>\n  <div class=\"dn-banner-buttons\">\n      <button class=\"dn-banner-accept-btn\">").concat(banner.acceptBtnText, "</button>\n      <button class=\"dn-banner-deny-btn\">x</button>\n  </div>\n</div>\n<style>\n\n  #dengage-push-perm-banner {\n    position: ").concat(banner.fixed ? 'fixed' : 'absolute', " !important;\n    width: 100% !important;\n    z-index: 100000000 !important;\n    left: 0 !important;\n  }\n  #dengage-push-perm-banner.dn-top {\n    top: -200px !important;\n  }\n  #dengage-push-perm-banner.dn-bottom {\n    bottom: -200px !important;\n  }\n  #dengage-push-perm-banner.dn-top.dn-opened {\n    top: 0 !important;\n  }\n  #dengage-push-perm-banner.dn-bottom.dn-opened {\n    bottom: 0 !important;\n  }\n\n  .dn-banner {\n      box-shadow: ").concat(details.shadow ? '0 3px 10px 0 rgba(0, 0, 0, 0.43)' : 'none', " !important;\n      background: ").concat(details.backgroundColor, " !important;\n      border-").concat(banner.location == 'TOP' ? 'bottom' : 'top', ": ").concat(details.border, "px solid ").concat(details.borderColor, " !important;\n      display: flex !important;\n      overflow: auto !important;\n      width: 100% !important;\n      height: auto !important;\n  }\n\n  .dn-banner-logo {\n      padding: 15px !important;\n      box-sizing: border-box !important;\n      display: flex !important;\n      justify-content: center !important;\n      align-items: center !important;\n  }\n  .dn-banner-logo img {\n      width: 36px !important;\n  }\n  .dn-banner--noLogo .dn-banner-logo {\n      display: none !important;\n  }\n\n  .dn-banner-text {\n      flex: 1 !important;\n      padding: 15px !important;\n      box-sizing: border-box !important;\n      line-height: 1.4 !important;\n      display: flex !important;\n      align-items: center !important;\n      color: ").concat(details.textSyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.textSyle.fontSize, "px !important;\n      font-weight: ").concat(details.textSyle.fontWeight, " !important;\n  }\n  .dn-banner--noLogo .dn-banner-body {\n      width: 100% !important;\n  }\n\n  .dn-banner-buttons {\n      display: flex !important;\n      padding-right: 10px !important;\n      align-items: center !important;\n  }\n  .dn-banner-buttons button {\n      padding: 8px 15px !important;\n      margin: 0 !important;\n      text-align: center !important;\n      cursor: pointer !important;\n  }\n\n  .dn-banner-buttons .dn-banner-accept-btn {\n      background-color: ").concat(details.acceptBtnStyle.backgroundColor, " !important;\n      color: ").concat(details.acceptBtnStyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.acceptBtnStyle.fontSize, "px !important;\n      font-weight: ").concat(details.acceptBtnStyle.fontWeight, " !important;\n      border: ").concat(details.acceptBtnStyle.border, "px solid ").concat(details.acceptBtnStyle.borderColor, " !important;\n      border-radius: ").concat(details.acceptBtnStyle.borderRadius, "px !important;\n      box-shadow: ").concat(details.acceptBtnStyle.shadow ? '0 2px 5px 0 rgba(0, 0, 0, 0.4)' : 'none', " !important;\n  }\n  .dn-banner-buttons .dn-banner-accept-btn:hover {\n      background-color: ").concat(details.acceptBtnStyle.hoverBackgroundColor, " !important;\n      color: ").concat(details.acceptBtnStyle.hoverTextColor, " !important;\n  }\n\n  .dn-banner-buttons .dn-banner-deny-btn {\n      background-color: ").concat(details.cancelBtnStyle.backgroundColor, " !important;\n      color: ").concat(details.cancelBtnStyle.textColor, " !important;\n      font-family: ").concat(getFontFamily(details.fontFamily), " !important;\n      font-size: ").concat(details.cancelBtnStyle.fontSize, "px !important;\n      font-weight: ").concat(details.cancelBtnStyle.fontWeight, " !important;\n      border: ").concat(details.cancelBtnStyle.border, "px solid ").concat(details.cancelBtnStyle.borderColor, " !important;\n      border-radius: ").concat(details.cancelBtnStyle.borderRadius, "px !important;\n      box-shadow: ").concat(details.cancelBtnStyle.shadow ? '0 2px 5px 0 rgba(0, 0, 0, 0.4)' : 'none', " !important;\n  }\n  .dn-banner-buttons .dn-banner-deny-btn:hover {\n      background-color: ").concat(details.cancelBtnStyle.hoverBackgroundColor, " !important;\n      color: ").concat(details.cancelBtnStyle.hoverTextColor, " !important;\n  }\n\n  @media only screen and (max-width: 500px) {\n    .dn-banner-logo {\n      display: none !important;\n    }\n    .dn-banner-body {\n      width: 100% !important;\n    }\n    .dn-banner-text {\n      font-size: 12px !important;\n    }\n    .dn-banner .dn-banner-accept-btn {\n      font-size: ").concat(details.acceptBtnStyle.fontSize * .75, "px !important;\n    }\n    .dn-banner .dn-banner-deny-btn {\n      font-size: ").concat(details.cancelBtnStyle.fontSize * .75, "px !important;\n    }\n  }\n</style>\n    ")
    }
    function getDefaultBannerDetails(mainColor) {
        return {
            backgroundColor: '#ffffff',
            fontFamily: 'ARIAL',
            border: 2,
            borderColor: mainColor,
            shadow: true,
            textSyle: {
                textColor: mainColor,
                fontSize: '15',
                fontWeight: 'normal'
            },
            acceptBtnStyle: {
                backgroundColor: mainColor,
                hoverBackgroundColor: shadeHexColor(mainColor, -.2),
                textColor: '#ffffff',
                hoverTextColor: '#ffffff',
                fontSize: '16',
                fontWeight: 'normal',
                border: 0,
                borderColor: '',
                borderRadius: 0,
                shadow: false
            },
            cancelBtnStyle: {
                backgroundColor: '#eeeeee',
                hoverBackgroundColor: '#cccccc',
                textColor: shadeHexColor(mainColor, .2),
                hoverTextColor: mainColor,
                fontSize: '16',
                fontWeight: 'bold',
                border: 0,
                borderColor: '',
                shadow: false
            }
        }
    }
    function fixMissingBannerDetails(details, mainColor) {
        var textSyle = details.textSyle || {};
        var acceptBtnStyle = details.acceptBtnStyle || {};
        var cancelBtnStyle = details.cancelBtnStyle || {};
        return {
            backgroundColor: details.backgroundColor || '#ffffff',
            fontFamily: details.fontFamily || 'ARIAL',
            border: details.border || 2,
            borderColor: details.borderColor || mainColor,
            borderRadius: details.borderRadius || 0,
            shadow: details.shadow == null ? true : details.shadow,
            textSyle: {
                textColor: textSyle.textColor || '#333333',
                fontSize: textSyle.fontSize || '15',
                fontWeight: textSyle.fontWeight || 'normal'
            },
            acceptBtnStyle: {
                backgroundColor: acceptBtnStyle.backgroundColor || mainColor,
                hoverBackgroundColor: acceptBtnStyle.hoverBackgroundColor || shadeHexColor(mainColor, -.2),
                textColor: acceptBtnStyle.textColor || '#ffffff',
                hoverTextColor: acceptBtnStyle.hoverTextColor || '#ffffff',
                fontSize: acceptBtnStyle.fontSize || '16',
                fontWeight: acceptBtnStyle.fontWeight || 'normal',
                border: acceptBtnStyle.border || 0,
                borderColor: acceptBtnStyle.borderColor || mainColor,
                borderRadius: acceptBtnStyle.borderRadius || 0,
                shadow: acceptBtnStyle.shadow == null ? false : acceptBtnStyle.shadow
            },
            cancelBtnStyle: {
                backgroundColor: cancelBtnStyle.backgroundColor || '#eeeeee',
                hoverBackgroundColor: cancelBtnStyle.hoverBackgroundColor || '#cccccc',
                textColor: cancelBtnStyle.textColor || shadeHexColor(mainColor, .2),
                hoverTextColor: cancelBtnStyle.hoverTextColor || mainColor,
                fontSize: cancelBtnStyle.fontSize || '16',
                fontWeight: cancelBtnStyle.fontWeight || 'normal',
                border: cancelBtnStyle.border || 0,
                borderColor: cancelBtnStyle.borderColor || '#eeeeee',
                shadow: cancelBtnStyle.shadow == null ? false : cancelBtnStyle.shadow
            }
        }
    }
    function showBannerPromt(appSettings, isPreview) {
        var container = document.createElement('div');
        var className = 'dengage-push-perm-banner';
        container.id = 'dengage-push-perm-banner';
        var language = (document.documentElement.lang || appSettings.defaultLanguage || navigator.language).toLowerCase();
        var bannerSettings = Array.isArray(appSettings.bannerSettings) ? appSettings.bannerSettings.find((function(settings) {
            return language.includes((settings.language || '').toLowerCase())
        }
        )) : appSettings.bannerSettings;
        if (bannerSettings.location.indexOf('TOP') != -1) {
            className += ' dn-top'
        }
        if (bannerSettings.location.indexOf('BOTTOM') != -1) {
            className += ' dn-bottom'
        }
        container.className = className;
        if (!isPreview) {
            container.style.transition = 'top 1s linear'
        }
        container.innerHTML = generateBannerHtml$1(appSettings);
        document.body.appendChild(container);
        setTimeout((function() {
            container.className += ' dn-opened'
        }
        ), 50);
        return {
            onAccept: function onAccept(callback) {
                var btn = container.querySelector('.dn-banner-accept-btn');
                btn.addEventListener('click', (function() {
                    container.classList.remove('dn-opened');
                    callback();
                    setTimeout((function() {
                        document.body.removeChild(container)
                    }
                    ), 1e3)
                }
                ))
            },
            onDeny: function onDeny(callback) {
                var btn = container.querySelector('.dn-banner-deny-btn');
                btn.addEventListener('click', (function() {
                    container.classList.remove('dn-opened');
                    callback();
                    setTimeout((function() {
                        document.body.removeChild(container)
                    }
                    ), 1e3)
                }
                ))
            }
        }
    }
    function generateBlockedHtml(appSettings) {
        var s = appSettings.blockedPopup;
        var slide = {
            title: s.title,
            titleColor: s.titleColor,
            message: s.message,
            showButton: s.showButton,
            buttonText: s.buttonText,
            buttonColor: s.buttonColor || '#1165f1'
        };
        return "\n      <div id=\"dn-blocked-popup\">\n        <div class=\"dn-blocked-container\">\n            <i class=\"dn-blocked-container-close\">X</i>\n            <img class=\"desktop\" src=\"".concat(isBlinkBrowser() ? 'https://cdn.dengage.com/internal/chrome.png' : 'https://cdn.dengage.com/internal/firefox.png', "\" />\n            <img class=\"mobile\" src=\"https://cdn.dengage.com/internal/mobile.png\" />\n            <div class=\"dn-blocked-container-body\">\n                <p class=\"dn-blocked-container-body-title\">\n                  ").concat(slide.title, "\n                </p>\n                <div class=\"dn-blocked-container-body-content\">\n                  ").concat(slide.message, "\n                </div>\n                <div class=\"dn-blocked-container-body-content-button ").concat(slide.showButton ? '' : 'dn-blocked-container-body-content--noLogo', "\">\n                    <button>").concat(slide.buttonText, "</button>\n                </div>\n            </div>\n        </div>\n      </div>\n      <style>\n        #dn-blocked-popup {\n          background: rgba(0,0,0,.4) !important;\n          position: fixed !important;\n          top: 0 !important;\n          left: 0 !important;\n          right: 0 !important;\n          bottom: 0 !important;\n          width: 100% !important;\n          z-index: 100000000 !important;\n        }\n        #dn-blocked-popup .dn-blocked-container {\n          position: absolute !important;\n          left: 130px !important;\n          top: 10px !important;\n        }\n        #dn-blocked-popup .dn-blocked-container img {\n          display: block !important;\n          width: 100% !important;\n        }\n        #dn-blocked-popup .dn-blocked-container img.mobile {\n          display: none !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-close {\n          position: absolute !important;\n          right: 5px !important;\n          cursor: pointer !important;\n          color: #000 !important;\n          font-family: Arial, Helvetica, sans-serif !important;\n          font-style: normal !important;\n          font-size: 12px !important;\n          font-weight: bold !important;\n          line-height: 17px !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-body {\n          background: #fff !important;\n          padding: 15px !important;\n          width: 280px !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-body-title {\n          font-family: Arial, Helvetica, sans-serif !important;\n          font-size: 15px !important;\n          font-weight: bold !important;\n          margin: 0 0 10px 0 !important;\n          color: ").concat(slide.titleColor, " !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-body-content {\n          margin-bottom: 15px !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-body-content--noLogo {\n          display: none !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-body-content-button {\n          text-align: right !important;\n        }\n        #dn-blocked-popup .dn-blocked-container-body-content-button button {\n          background: ").concat(slide.buttonColor, " !important;\n          color: #fff !important;\n          padding: 8px 15px !important;\n          outline: none !important;\n          cursor: pointer !important;\n          border: none !important;\n          font-family: Arial, Helvetica, sans-serif !important;\n        }\n        @media (max-width:550px) {\n          #dn-blocked-popup .dn-blocked-container {\n            display: flex !important;\n            flex-direction: column !important;\n            justify-content: center !important;\n            align-items: center !important;\n            min-height: 100vh !important;\n            position: static !important;\n            left: auto !important;\n            top: auto !important;\n          }\n          #dn-blocked-popup .dn-blocked-container img {\n            width: 310px !important;\n          }\n          #dn-blocked-popup .dn-blocked-container img.mobile {\n            display: block !important;\n          }\n          #dn-blocked-popup .dn-blocked-container img.desktop {\n            display: none !important;\n          }\n          #dn-blocked-popup .dn-blocked-container-close{\n            display: none !important;\n          }\n        }\n      </style>\n  ")
    }
    function showBlockedPromt(appSettings) {
        var container = document.createElement('div');
        container.id = 'dn-blocked-popup';
        container.innerHTML = generateBlockedHtml(appSettings);
        document.body.appendChild(container);
        return {
            onAccept: function onAccept(callback) {
                var btn = container.querySelector('.dn-blocked-container-body-content-button');
                btn.addEventListener('click', (function() {
                    callback();
                    setTimeout((function() {
                        document.body.removeChild(container)
                    }
                    ), 50)
                }
                ))
            },
            onClose: function onClose(callback) {
                var btn = container.querySelector('.dn-blocked-container-close');
                btn.addEventListener('click', (function() {
                    callback();
                    setTimeout((function() {
                        document.body.removeChild(container)
                    }
                    ), 50)
                }
                ))
            }
        }
    }
    var permissionData = null;
    function getWebsitePushID() {
        var host = new URL(appSettings.siteUrl);
        var webSiteID = host.hostname.split('.').concat('web').reverse().join('.');
        return webSiteID
    }
    function refreshPermissionData() {
        permissionData = window.safari.pushNotification.permission(getWebsitePushID())
    }
    var safariClient = {
        detected: function detected() {
            return isSafariPushSupported() && isDnSafariPushEnabled()
        },
        init: function init() {
            if (permissionData == null) {
                refreshPermissionData()
            }
            if (permissionData.permission == 'granted') {
                return Promise.resolve()
            } else {
                logError('init called when permission is not granted');
                return Promise.reject()
            }
        },
        getTokenInfo: function getTokenInfo() {
            if (permissionData == null) {
                refreshPermissionData()
            }
            if (permissionData.permission === 'granted') {
                return Promise.resolve({
                    token: permissionData.deviceToken,
                    tokenType: 'S',
                    webSubscription: null
                })
            }
            return Promise.resolve(null)
        },
        requestPermission: function requestPermission() {
            return new Promise((function(resolve, reject) {
                if (permissionData == null) {
                    refreshPermissionData()
                }
                function safariPermissionCb(result) {
                    permissionData = result;
                    if (permissionData.permission === 'default') {
                        logError('User made default. it is impossible')
                    } else if (permissionData.permission === 'denied') {
                        logInfo('User said no')
                    } else if (permissionData.permission === 'granted') {
                        logInfo('user said yes');
                        logInfo('Token: ' + permissionData.deviceToken)
                    }
                    resolve(permissionData.permission)
                }
                if (permissionData.permission == 'default') {
                    var deviceId = getDeviceId();
                    var websitePushID = getWebsitePushID();
                    var url = 'https://dev-push.dengage.com/api/safari/90db7e2a-5839-53cd-605f-9d3ffc328e21';
                    var userInfo = {
                        device_id: deviceId
                    };
                    try {
                        window.safari.pushNotification.requestPermission(url, websitePushID, userInfo, safariPermissionCb)
                    } catch (error) {
                        resolve(permissionData.permission)
                    }
                } else {
                    logError('requestPermission called when permission is not default');
                    reject()
                }
            }
            ))
        },
        getPermission: function getPermission() {
            if (permissionData == null) {
                refreshPermissionData()
            }
            return permissionData.permission
        },
        setParams: function setParams() {}
    };
    var pushClient = {
        detected: function detected() {
            return false
        }
    };
    if (safariClient.detected()) {
        objectAssign(pushClient, safariClient)
    } else {
        objectAssign(pushClient, webPushApiClient)
    }
    function showNativePrompt$1(grantedCallback, deniedCallback, isFromCustomPrompt) {
        var promptShowTime = new Date;
        var currentPermission = pushClient.getPermission();
        pushClient.requestPermission().then((function(permission) {
            var promptResponseTime = new Date;
            if (!isFromCustomPrompt && permission === currentPermission && promptResponseTime - promptShowTime < 200) {
                logInfo('Native Prompt is not directly available, custom prompt will be shown');
                showCustomPrompt$1(grantedCallback, deniedCallback, true)
            } else {
                if (permission === 'granted') {
                    setLocalStoragePromptResult('granted');
                    if (grantedCallback) {
                        grantedCallback()
                    }
                } else {
                    setLocalStoragePromptResult('denied');
                    if (deniedCallback) {
                        deniedCallback()
                    }
                }
            }
        }
        ))
    }
    function showCustomPrompt$1(grantedCallback, deniedCallback, isFromNative) {
        appSettings.selectedPrompt = appSettings.selectedPrompt === 'NATIVE' ? 'SLIDE' : appSettings.selectedPrompt;
        appSettings.showNativeWhenPossible = appSettings.selectedPrompt === 'NATIVE' ? true : !!appSettings.showNativeWhenPossible;
        if (appSettings.showNativeWhenPossible && !isFromNative) {
            showNativePrompt$1(grantedCallback, deniedCallback)
        } else {
            var prompt = (appSettings.selectedPrompt == 'SLIDE' ? showSlidePromt : showBannerPromt)(appSettings);
            prompt.onAccept((function() {
                showNativePrompt$1(grantedCallback, deniedCallback, true)
            }
            ));
            prompt.onDeny((function() {
                setLocalStoragePromptResult('denied');
                if (deniedCallback) {
                    deniedCallback()
                }
            }
            ))
        }
        setLocalStoragePromptResult('ask')
    }
    function startAutoPrompt(grantedCallback, deniedCallback) {
        var autoShowSettings = appSettings.autoShowSettings;
        var sessionStartTime = getSessionStartTime();
        var now = new Date;
        var setPrompt = function setPrompt() {
            var delay = toInt(autoShowSettings.delay || 1) * 1e3;
            var passedTime = now.valueOf() - sessionStartTime.valueOf();
            var waitTime = delay - passedTime;
            waitTime = waitTime > 0 ? waitTime : 0;
            setTimeout((function() {
                showCustomPrompt$1(grantedCallback, deniedCallback)
            }
            ), waitTime)
        };
        var visitCount = getTotalPageViewCount();
        if (toInt(autoShowSettings.promptAfterXVisits) <= visitCount) {
            var lastPromptAction = storage.get('webpush.prompt_last_a') || '';
            var lastPromptDate = toInt(storage.get('webpush.prompt_last_t'));
            lastPromptDate = new Date(lastPromptDate);
            var denyWaitTime = toInt(autoShowSettings.denyWaitTime || 24) * 60 * 60 * 1e3;
            var denyWaitUntil = new Date(lastPromptDate.valueOf() + denyWaitTime);
            var repromptWaitTime = toInt(autoShowSettings.repromptAfterXMinutes) * 60 * 60 * 1e3;
            var repromptWaitUntil = new Date(lastPromptDate.valueOf() + repromptWaitTime);
            if (lastPromptAction == 'denied') {
                if (now >= denyWaitUntil) {
                    setPrompt()
                }
            } else {
                if (now >= repromptWaitUntil) {
                    setPrompt()
                }
            }
        }
    }
    function startBlockedPrompt() {
        var blockedSettings = appSettings.blockedPopup;
        var sessionStartTime = getSessionStartTime();
        var now = new Date;
        var setPrompt = function setPrompt() {
            var delay = toInt(blockedSettings.delay || 1) * 1e3;
            var passedTime = now.valueOf() - sessionStartTime.valueOf();
            var waitTime = delay - passedTime;
            waitTime = waitTime > 0 ? waitTime : 0;
            setTimeout((function() {
                storage.set('webpush.blocked_prompt_count', blockedPromptCount + 1);
                storage.set('webpush.blocked_prompt_last_t', now.valueOf());
                var blockedPrompt = showBlockedPromt(appSettings);
                blockedPrompt.onAccept((function() {}
                ));
                blockedPrompt.onClose((function() {}
                ))
            }
            ), waitTime)
        };
        var blockedPromptCount = toInt(storage.get('webpush.blocked_prompt_count'));
        if (toInt(blockedSettings.maxShowCount) > blockedPromptCount) {
            var lastPromptDate = toInt(storage.get('webpush.blocked_prompt_last_t'));
            lastPromptDate = new Date(lastPromptDate);
            var waitTime = toInt(blockedSettings.repromptAfterXHours || 48) * 60 * 60 * 1e3;
            var waitUntil = new Date(lastPromptDate.valueOf() + waitTime);
            if (now >= waitUntil) {
                setPrompt()
            }
        }
    }
    function getSessionStartTime() {
        var val = toInt(storage.sessionGet('session_start'));
        if (val) {
            val = new Date(val)
        } else {
            val = new Date;
            storage.sessionSet('session_start', val.valueOf() + '')
        }
        return val
    }
    function toInt(input) {
        if (typeof input == 'number') {
            return input
        }
        if (typeof input == 'string') {
            return input === '' ? 0 : parseInt(input)
        }
        return 0
    }
    function setLocalStoragePromptResult(result) {
        storage.set('webpush.prompt_last_a', result);
        storage.set('webpush.prompt_last_t', (new Date).valueOf() + '')
    }
    var permissionPromptManager = Object.freeze({
        __proto__: null,
        showNativePrompt: showNativePrompt$1,
        showCustomPrompt: showCustomPrompt$1,
        startAutoPrompt: startAutoPrompt,
        startBlockedPrompt: startBlockedPrompt
    });
    function showNotificationSimple(data) {
        var title = data.title;
        var iconUrl = data.iconUrl == 'default_icon' ? appSettings.defaultIconUrl : (data.iconUrl || '').trim();
        var options = {
            body: data.message,
            requireInteraction: true
        };
        if (data.mediaUrl) {
            options.image = data.mediaUrl
        }
        if (iconUrl) {
            options.icon = iconUrl
        }
        if (data.badgeUrl) {
            options.badge = data.badgeUrl
        }
        var notif = new Notification(title,options);
        if (data.targetUrl) {
            notif.onclick = function(event) {
                if (event.notification) {
                    event.notification.close()
                }
                window.open(data.targetUrl);
                if (data.messageId != null && data.messageDetails != null) {
                    sendOpen(data.messageId, data.messageDetails)
                }
            }
        }
    }
    function sendOpen(messageId, messageDetails, buttonId) {
        var data = {
            integrationKey: 'dPfs6p5b_p_l_K_p_l__p_l_Y8VhrU2Wl91zleK2npa6cHKyW63dele1dg1G8vRtwZkmRAPmJcPgEQqUSIlB_p_l_674Du7Pb0qg1P3KcPIP3ZPlx9_s_l_lfKmDy57YLwa_p_l_yWHfmVuQLWCqgrKUQ8xYSN3AC4BMvMRyJ1Z8JQ_e_q__e_q_',
            messageId: messageId,
            messageDetails: messageDetails,
            buttonId: buttonId || ''
        };
        return fetch('https://dev-push.dengage.com/api/web/open', {
            method: 'POST',
            mode: 'cors',
            cache: 'no-cache',
            credentials: 'omit',
            headers: {
                'Content-Type': 'text/plain'
            },
            body: JSON.stringify(data)
        }).catch((function(e) {
            logError(e.toString())
        }
        ))
    }
    function startPushClient(callback, isFirstTime) {
        pushClient.init().then((function() {
            pushClient.getTokenInfo().then((function(tokenInfo) {
                logInfo('Token: ' + tokenInfo.token);
                setToken(tokenInfo.token);
                setTokenType(tokenInfo.tokenType);
                setWebSubscription(tokenInfo.webSubscription || null);
                _Dn_globaL_.cookieData.webpushDomain = location.host;
                if (isFirstTime) {
                    showWellcomeNotification()
                }
                callback()
            }
            )).catch((function(err) {
                logError('pushClient.getTokenInfo() failed. ', err);
                callback()
            }
            ))
        }
        )).catch((function(err) {
            logError('pushClient.init() failed. ', err);
            callback()
        }
        ))
    }
    function start$3(callback) {
        callback = callback || function() {}
        ;
        var currentPermission = pushClient.getPermission();
        if (currentPermission == 'granted') {
            logInfo('Notification permission already granted.');
            startPushClient(callback)
        } else if (currentPermission == 'default') {
            setToken(null);
            setTokenType(null);
            setWebSubscription(null);
            _Dn_globaL_.cookieData.webpushDomain = '';
            if (appSettings.autoShow) {
                var onPermissionGranted = function onPermissionGranted() {
                    logInfo('Notification permission granted.');
                    startPushClient(callback, true)
                };
                var onPermissionDenied = function onPermissionDenied() {
                    logInfo('Notification permission denied.')
                };
                startAutoPrompt(onPermissionGranted, onPermissionDenied)
            }
            callback()
        } else {
            if (appSettings.blockedPopup && appSettings.blockedPopup.enabled && (isBlinkBrowser() || isFirefoxBrowser())) {
                startBlockedPrompt()
            }
            logInfo('Notification permission denied');
            setToken(null);
            setTokenType(null);
            setWebSubscription(null);
            _Dn_globaL_.cookieData.webpushDomain = '';
            callback()
        }
    }
    function showNativePrompt() {
        return showPrompt('showNativePrompt')
    }
    function showCustomPrompt() {
        return showPrompt('showCustomPrompt')
    }
    function showPrompt(functionName) {
        return new Promise((function(resolve, reject) {
            var permission = pushClient.getPermission();
            if (permission == 'default') {
                permissionPromptManager[functionName]((function() {
                    startPushClient((function() {}
                    ), true);
                    resolve('granted')
                }
                ), (function() {
                    resolve('denied')
                }
                ))
            } else {
                resolve(permission)
            }
        }
        ))
    }
    function showWellcomeNotification() {
        if (appSettings.welcomeNotification.enabled) {
            setTimeout((function() {
                var data = {
                    title: appSettings.welcomeNotification.title,
                    message: appSettings.welcomeNotification.message,
                    targetUrl: appSettings.welcomeNotification.link
                };
                showNotificationSimple(data)
            }
            ), 500)
        }
    }
    var list = [' Daum/', ' DeuSu/', ' MuckRack/', ' Sysomos/', ' um-LN/', '!Susie', '/www\\.answerbus\\.com', '/www\\.unchaos\\.com', '/www\\.wmtips\\.com', '008/', '192\\.comAgent', '8484 Boston Project', '<http://www\\.sygol\\.com/>', '\\(privoxy/', '^AHC/', '^Amazon CloudFront', '^axios/', '^Disqus/', '^Friendica', '^Hatena', '^http_get', '^Jetty/', '^MeltwaterNews', '^MixnodeCache/', '^newspaper/', '^NextCloud-News/', '^ng/', '^NING', '^Nuzzel', '^okhttp', '^sentry/', '^Thinklab', '^Tiny Tiny RSS/', '^Traackr.com', '^Upflow/', '^Zabbix', 'Abonti', 'Aboundex', 'aboutthedomain', 'ac{1,2}oon', 'Ad Muncher', 'adbeat\\.com', 'AddThis', 'ADmantX', 'agada.de', 'agadine/', 'aggregator', 'aiderss/', 'airmail\\.etn', 'airmail\\net', 'aladin/', 'alexa site audit', 'allrati/', 'AltaVista Intranet', 'alyze\\.info', 'amzn_assoc', 'analyza', 'analyzer', 'Anemone', 'Anturis Agent', 'AnyEvent-HTTP', 'Apache-HttpClient', 'APIs-Google', 'Aport', 'AppEngine-Google', 'appie', 'AppInsights', 'Arachmo', 'arachnode\\.net', 'Arachnoidea', 'Arachnophilia/', 'araneo/', 'archive', 'archiving', 'asafaweb\\.com', 'asahina-antenna/', 'ask[-\\s]?jeeves', 'ask\\.24x\\.info', 'aspseek/', 'AspTear', 'assort/', 'asterias/', 'atomic_email_hunter/', 'atomz/', 'augurfind', 'augurnfind', 'auto', 'Avirt Gateway Server', 'Azureus', 'B-l-i-t-z-B-O-T', 'B_l_i_t_z_B_O_T', 'BackStreet Browser', 'BCKLINKS 1\\.0', 'beammachine/', 'beebwaredirectory/v0\\.01', 'bibnum\\.bnf', 'Big Brother', 'Big Fish', 'BigBozz/', 'bigbrother/', 'biglotron', 'bilbo/', 'BilderSauger', 'BingPreview', 'binlar', 'Blackboard Safeassign', 'BlackWidow', 'blaiz-bee/', 'bloglines/', 'Blogpulse', 'blogzice/', 'BMLAUNCHER', 'bobby/', 'boitho\\.com-dc', 'bookdog/x\\.x', 'Bookmark Buddy', 'Bookmark Renewal', 'bookmarkbase\\(2/;http://bookmarkbase\\.com\\)', 'BorderManager', 'bot', 'BrandVerity/', 'BravoBrian', 'Browsershots', 'bsdseek/', 'btwebclient/', 'BUbiNG', 'BullsEye', 'bumblebee@relevare\\.com', 'BunnySlippers', 'Buscaplus', 'butterfly', 'BW-C-2', 'bwh3_user_agent', 'calif/', 'capture', 'carleson/', 'CC Metadata Scaper', 'ccubee/x\\.x', 'CE-Preload', 'Ceramic Tile Installation Guide', 'Cerberian Drtrs', 'CERN-HTTPD', 'cg-eye interactive', 'changedetection', 'Charlotte', 'charon/', 'Chat Catcher/', 'check', 'China Local Browse', 'Chitika ContentHit', 'Chrome-Lighthouse', 'CJB\\.NET Proxy', 'classify', 'Claymont\\.com', 'cloakdetect/', 'CloudFlare-AlwaysOnline', 'clown', 'cnet\\.com', 'COAST WebMaster Pro/', 'CoBITSProbe', 'coccoc', 'cocoal\\.icio\\.us/', 'ColdFusion', 'collage\\.cgi/', 'collect', 'combine/', 'Commons-HttpClient', 'ContentSmartz', 'contenttabreceiver', 'control', 'convera', 'copperegg/revealuptime/fremontca', 'coralwebprx/', 'cosmos', 'Covac UPPS Cathan', 'Covario-IDS', 'crawl', 'crowsnest/', 'csci_b659/', 'Custo x\\.x \\(www\\.netwu\\.com\\)', 'cuwhois/', 'CyberPatrol', 'DA \\d', 'DAP x', 'DareBoost', 'datacha0s/', 'datafountains/dmoz', 'Datanyze', 'dataprovider', 'DAUMOA-video', 'dbdig\\(http://www\\.prairielandconsulting\\.com\\)', 'DBrowse \\d', 'dc-sakura/x\\.xx', 'DDD', 'deep[-\\s]?link', 'deepak-usc/isi', 'delegate/', 'DepSpid', 'detector', 'developers\\.google\\.com\\/\\+\\/web\\/snippet\\/', 'diagem/', 'diamond/x\\.0', 'Digg', 'DigOut4U', 'DISCo Pump x\\.x', 'dlman', 'dlvr\\.it/', 'DnloadMage', 'docomo/', 'DomainAppender', 'Download Demon', 'Download Druid', 'Download Express', 'Download Master', 'Download Ninja', 'Download Wonder', 'download(?:s|er)', 'Download\\.exe', 'DownloadDirect', 'DreamPassport', 'drupact', 'Drupal', 'DSurf15', 'DTAAgent', 'DTS Agent', 'Dual Proxy', 'e-sense', 'EARTHCOM', 'easydl/', 'EBrowse \\d', 'ecairn\\.com/grabber', 'echo!/', 'efp@gmx\\.net', 'egothor/', 'ejupiter\\.com', 'EldoS TimelyWeb/', 'ElectricMonk', 'EmailWolf', 'Embedly', 'envolk', 'ESurf15', 'evaliant', 'eventax/', 'Evliya Celebi', 'exactseek\\.com', 'Exalead', 'Expired Domain Sleuth', 'Exploratodo/', 'extract', 'EyeCatcher', 'eyes', 'ezooms', 'facebookexternalhit', 'faedit/', 'FairAd Client', 'fantom', 'FastBug', 'Faveeo/', 'FavIconizer', 'FavOrg', 'FDM \\d', 'feed', 'feeltiptop\\.com', 'fetch', 'fileboost\\.net/', 'filtrbox/', 'FindAnISP\\.com', 'finder', 'findlink', 'findthatfile', 'firefly/', 'FlashGet', 'FLATARTS_FAVICO', 'flexum/', 'FlipboardProxy/', 'FlipboardRSS/', 'fluffy', 'flunky', 'focusedsampler/', 'FollowSite', 'forensiq\\.com', 'francis/', 'freshdownload/x\\.xx', 'FSurf', 'FuseBulb\\.Com', 'g00g1e\\.net', 'galaxy\\.com', 'gather', 'gazz/x\\.x', 'geek-tools\\.org', 'genieknows', 'Genieo', 'getright(pro)?/', 'getter', 'ghostroutehunter/', 'gigabaz/', 'GigablastOpenSource', 'go!zilla', 'go-ahead-got-it/', 'Go-http-client', 'GoBeez', 'goblin/', 'GoForIt\\.com', 'Goldfire Server', 'gonzo[1-2]', 'gooblog/', 'goofer/', 'Google Favicon', 'Google Page Speed Insights', 'Google Web Preview', 'Google Wireless Transcoder', 'Google-PhysicalWeb', 'Google-Site-Verification', 'Google-Structured-Data-Testing-Tool', 'google-xrawler', 'GoogleImageProxy', 'gopher', 'gossamer-threads\\.com', 'grapefx/', 'gromit/', 'GroupHigh/', 'grub-client', 'GTmetrix', 'gulliver/', 'H010818', 'hack', 'harvest', 'haste/', 'HeadlessChrome/', 'helix/', 'heritrix', 'HiDownload', 'hippias/', 'HitList', 'Holmes', 'hotmail.com', 'hound', 'htdig', 'html2', 'http-header-abfrage/', 'http://anonymouse\\.org/', 'http://ask\\.24x\\.info/', 'http://www\\.ip2location\\.com', 'http://www\\.monogol\\.de', 'http://www\\.sygol\\.com', 'http://www\\.timelyweb\\.com/', 'http::lite/', 'http_client', 'HTTPGet', 'HTTPResume', 'httpunit', 'httrack', 'HubSpot Marketing Grader', 'hyperestraier/', 'HyperixScoop', 'ichiro', 'ics \\d', 'IDA', 'ideare - SignSite', 'idwhois\\.info', 'IEFav172Free', 'iframely/', 'IlTrovatore-Setaccio', 'imageengine/', 'images', 'imagewalker/', 'InAGist', 'incywincy\\(http://www\\.look\\.com\\)', 'index', 'info@pubblisito\\.com', 'infofly/', 'infolink/', 'infomine/', 'InfoSeek Sidewinder/', 'InfoWizards Reciprocal Link System PRO', 'inkpeek\\.com', 'Insitornaut', 'inspectorwww/', 'InstallShield DigitalWizard', 'integrity/', 'integromedb', 'intelix/', 'intelliseek\\.com', 'Internet Ninja', 'internetlinkagent/', 'InterseekWeb', 'IODC', 'IOI', 'ips-agent', 'iqdb/', 'iria/', 'irvine/', 'isitup\\.org', 'isurf', 'ivia/', 'iwagent/', 'j-phone/', 'Jack', 'java/', 'JBH Agent 2\\.0', 'JemmaTheTourist', 'JetCar', 'jigsaw/', 'jorgee', 'Journster', 'kalooga/kalooga-4\\.0-dev-datahouse', 'Kapere', 'kasparek@naparek\\.cz', 'KDDI-SN22', 'ke_1\\.0/', 'Kevin', 'KimonoLabs', 'kit-fireball/', 'KnowItAll', 'knowledge\\.com/', 'Kontiki Client', 'kulturarw3/', 'kummhttp/', 'L\\.webis', 'labrador/', 'Lachesis', 'Larbin', 'leech', 'leia/', 'LibertyW', 'library', 'libweb/clshttp', 'lightningdownload/', 'Lincoln State Web Browser', 'Link Commander', 'Link Valet', 'linkalarm/', 'linkdex', 'LinkExaminer', 'Linkguard', 'linkman', 'LinkPimpin', 'LinkProver', 'Links2Go', 'linksonar/', 'LinkStash', 'LinkTiger', 'LinkWalker', 'Lipperhey Link Explorer', 'Lipperhey SEO Service', 'Lipperhey Site Explorer', 'Lipperhey-Kaus-Australis/', 'loader', 'loadimpactrload/', 'locate', 'locator', 'Look\\.com', 'Lovel', 'ltx71', 'lwp-', 'lwp::', 'mabontland', 'mack', 'magicwml/', 'mail\\.ru/', 'mammoth/', 'MantraAgent', 'MapoftheInternet\\.com', 'Marketwave Hit List', 'Martini', 'Marvin', 'masagool/', 'MasterSeek', 'Mastodon/', 'Mata Hari/', 'mediaget', 'Mediapartners-Google', 'MegaSheep', 'Megite', 'Mercator', 'metainspector/', 'metaspinner/', 'metatagsdir/', 'MetaURI', 'MicroBaz', 'Microsoft_Internet_Explorer_5', 'miixpc/', 'Mindjet MindManager', 'Miniflux/', 'miniflux\\.net', 'Missouri College Browse', 'Mister Pix', 'Mizzu Labs', 'Mo College', 'moget/x\\.x', 'mogimogi', 'moiNAG', 'monitor', 'monkeyagent', 'MonTools\\.com', 'Morning Paper', 'Mrcgiguy', 'MSIE or Firefox mutant', 'msnptc/', 'msproxy/', 'Mulder', 'multiBlocker browser', 'multitext/', 'MuscatFerret', 'MusicWalker2', 'MVAClient', 'naofavicon4ie/', 'naparek\\.cz', 'netants/', 'Netcraft Web Server Survey', 'NetcraftSurveyAgent/', 'netlookout/', 'netluchs/', 'NetMechanic', 'netpumper/x\\.xx', 'NetSprint', 'netwu\\.com', 'neutrinoapi/', 'NewsGator', 'newt', 'nico/', 'Nmap Scripting Engine', 'NORAD National Defence Network', 'Norton-Safeweb', 'Notifixious', 'noyona_0_1', 'nsauditor/', 'nutch', 'Nymesis', 'ocelli/', 'Octopus', 'Octora Beta', 'ODP links', 'oegp', 'OliverPerry', 'omgili', 'Onet\\.pl', 'Oracle Application', 'Orbiter', 'OSSProxy', 'outbrain', 'ow\\.ly', 'ownCloud News/', 'ozelot/', 'Page Valet/', 'page2rss', 'Pagebull', 'PagmIEDownload', 'Panopta v', 'panscient', 'parasite/', 'parse', 'pavuk/', 'PayPal IPN', 'PBrowse', 'Pcore-HTTP', 'pd02_1', 'Peew', 'perl', 'Perman Surfer', 'PEval', 'phantom', 'photon/', 'php/\\d', 'Pingdom', 'Pingoscope', 'pingspot/', 'pinterest\\.com', 'Pita', 'Pizilla', 'Ploetz \\+ Zeller', 'Plukkie', 'pockey-gethtml/', 'pockey/x\\.x\\.x', 'Pockey7', 'Pogodak', 'Poirot', 'Pompos', 'popdexter/', 'Port Huron Labs', 'PostFavorites', 'PostPost', 'postrank', 'Powermarks', 'PR-CY.RU', 'pricepi\\.com', 'prlog\\.ru', 'pro-sitemaps\\.com', 'program', 'Project XP5', 'protopage/', 'proximic', 'PSurf15a', 'psycheclone', 'puf/', 'PureSight', 'PuxaRapido', 'python', 'Qango\\.com Web Directory', 'QuepasaCreep', 'Qwantify', 'QXW03018', 'rabaz', 'Radian6', 'RankSonicSiteAuditor/', 'rating', 'readability/', 'reader', 'realdownload/', 'reaper', 'ReGet', 'responsecodetest/', 'retrieve', 'rico/', 'Riddler', 'Rival IQ', 'Rivva', 'RMA/1\\.0', 'RoboPal', 'Robosourcer', 'robozilla/', 'rotondo/', 'rpt-httpclient/', 'RSurf15a', 'samualt9', 'saucenao/', 'SBIder', 'scan', 'scooter', 'ScoutAbout', 'scoutant/', 'ScoutJet', 'scoutmaster', 'scrape', 'Scrapy', 'Scrubby', 'search', 'Seeker\\.lookseek\\.com', 'seer', 'semaforo\\.net', 'semager/', 'semanticdiscovery', 'seo-nastroj\\.cz', 'SEOCentro', 'SEOstats', 'Seznam screenshot-generator', 'Shagseeker', 'ShopWiki', 'Siigle Orumcex', 'SimplyFast\\.info', 'Simpy', 'siphon', 'Site Server', 'Site24x7', 'SiteBar', 'SiteCondor', 'siteexplorer\\.info', 'Siteimprove', 'SiteRecon', 'SiteSnagger', 'sitesucker/', 'SiteUptime\\.com', 'SiteXpert', 'sitexy\\.com', 'skampy/', 'skimpy/', 'SkypeUriPreview', 'skywalker/', 'slarp/', 'slider\\.com', 'slurp', 'smartdownload/', 'smartwit\\.com', 'Snacktory', 'Snappy', 'sniff', 'sogou', 'sohu agent', 'somewhere', 'speeddownload/', 'speedy', 'speng', 'Sphere Scout', 'Sphider', 'spider', 'spinne/', 'spy', 'squidclam', 'Squider', 'Sqworm', 'SSurf15a', 'StackRambler', 'stamina/', 'StatusCake', 'suchbaer\\.de', 'summify', 'SuperCleaner', 'SurferF3', 'SurfMaster', 'suzuran', 'sweep', 'synapse', 'syncit/x\\.x', 'szukacz/', 'T-H-U-N-D-E-R-S-T-O-N-E', 'tags2dir\\.com/', 'Tagword', 'Talkro Web-Shot', 'targetblaster\\.com/', 'TargetSeek', 'Teleport Pro', 'teoma', 'Teradex Mapper', 'Theophrastus', 'thumb', 'TinEye', 'tkensaku/x\\.x\\(http://www\\.tkensaku\\.com/q\\.html\\)', 'tracker', 'truwoGPS', 'TSurf15a', 'tuezilla', 'tumblr/', 'Twingly Recon', 'Twotrees Reactive Filter', 'TygoProwler', 'Ultraseek', 'Under the Rainbow', 'unknownght\\.com', 'UofTDB_experiment', 'updated', 'url', 'user-agent', 'utility', 'utorrent/', 'Vagabondo', 'vakes/', 'vb wininet', 'venus/fedoraplanet', 'verifier', 'verify', 'Version: xxxx Type:xx', 'versus', 'verzamelgids/', 'viking', 'vkshare', 'voltron', 'vonna', 'Vortex', 'voyager-hc/', 'VYU2', 'W3C-mobileOK/', 'w3c-webcon/', 'W3C_Unicorn/', 'w3dt\\.net', 'Wappalyzer', 'warez', 'Watchfire WebXM', 'wavefire/', 'Waypath Scout', 'wbsrch\\.com', 'Web Snooper', 'web-bekannt', 'webbandit/', 'webbug/', 'Webclipping\\.com', 'webcollage', 'WebCompass', 'webcookies', 'webcorp/', 'webcraft', 'WebDataStats/', 'Webglimpse', 'webgobbler/', 'webinator', 'weblight/', 'Weblog Attitude Diffusion', 'webmastercoffee/', 'webminer/x\\.x', 'webmon ', 'WebPix', 'Website Explorer', 'Websnapr/', 'Websquash\\.com', 'webstat/', 'Webster v0\\.', 'webstripper/', 'webtrafficexpress/x\\.0', 'webtrends/', 'WebVac', 'webval/', 'Webverzeichnis\\.de', 'wf84', 'WFARC', 'wget', 'whatsapp', 'whatsmyip\\.org', 'whatsup/x\\.x', 'whatuseek_winona/', 'Whizbang', 'whoami', 'whoiam', 'Wildsoft Surfer', 'WinGet', 'WinHTTP', 'wish-project', 'WomlpeFactory', 'WordPress\\.com mShots', 'WorldLight', 'worqmada/', 'worth', 'wotbox', 'WoW Lemmings Kathune', 'WSN Links', 'wusage/x\\.0@boutell\\.com', 'wwlib/linux', 'www-mechanize/', 'www\\.ackerm\\.com', 'www\\.alertra\\.com', 'www\\.arianna\\.it', 'www\\.ba\\.be', 'www\\.de\\.com', 'www\\.evri\\.com/evrinid', 'www\\.gozilla\\.com', 'www\\.idealobserver\\.com', 'www\\.iltrovatore\\.it', 'www\\.iskanie\\.com', 'www\\.kosmix\\.com', 'www\\.megaproxy\\.com', 'www\\.moreover\\.com', 'www\\.mowser\\.com', 'www\\.nearsoftware\\.com', 'www\\.ssllabs\\.com', 'wwwc/', 'wwwoffle/', 'wwwster/', 'wxDownload Fast', 'Xenu Link Sleuth', "Xenu's Link Sleuth", 'xirq/', 'XML Sitemaps Generator', 'xrl/', 'Xylix', 'Y!J-ASR', 'y!j-srd/', 'y!oasis/test', 'yacy', 'yahoo', 'YandeG', 'yandex', 'yanga', 'yarienavoir\\.net/', 'yeti', 'Yoleo', 'Yoono', 'youtube-dl', 'Zao', 'Zearchit', 'zedzo\\.digest/', 'zeus', 'zgrab', 'Zippy', 'ZnajdzFoto/Image', 'ZyBorg', 'googlebot', 'Googlebot-Mobile', 'Googlebot-Image', 'bingbot', 'java', 'curl', 'Python-urllib', 'libwww', 'phpcrawl', 'msnbot', 'jyxobot', 'FAST-WebCrawler', 'FAST Enterprise Crawler', 'seekbot', 'gigablast', 'exabot', 'ngbot', 'ia_archiver', 'GingerCrawler', 'webcrawler', 'grub.org', 'UsineNouvelleCrawler', 'antibot', 'netresearchserver', 'bibnum.bnf', 'msrbot', 'yacybot', 'AISearchBot', 'tagoobot', 'MJ12bot', 'dotbot', 'woriobot', 'buzzbot', 'mlbot', 'yandexbot', 'purebot', 'Linguee Bot', 'Voyager', 'voilabot', 'baiduspider', 'citeseerxbot', 'spbot', 'twengabot', 'turnitinbot', 'scribdbot', 'sitebot', 'Adidxbot', 'blekkobot', 'dotbot', 'Mail.RU_Bot', 'discobot', 'europarchive.org', 'NerdByNature.Bot', 'sistrix crawler', 'ahrefsbot', 'domaincrawler', 'wbsearchbot', 'ccbot', 'edisterbot', 'seznambot', 'ec2linkfinder', 'gslfbot', 'aihitbot', 'intelium_bot', 'RetrevoPageAnalyzer', 'lb-spider', 'lssbot', 'careerbot', 'wocbot', 'DuckDuckBot', 'lssrocketcrawler', 'webcompanycrawler', 'acoonbot', 'openindexspider', 'gnam gnam spider', 'web-archive-net.com.bot', 'backlinkcrawler', 'content crawler spider', 'toplistbot', 'seokicks-robot', 'it2media-domain-crawler', 'ip-web-crawler.com', 'siteexplorer.info', 'elisabot', 'blexbot', 'arabot', 'WeSEE:Search', 'niki-bot', 'CrystalSemanticsBot', 'rogerbot', '360Spider', 'psbot', 'InterfaxScanBot', 'g00g1e.net', 'GrapeshotCrawler', 'urlappendbot', 'brainobot', 'fr-crawler', 'SimpleCrawler', 'Livelapbot', 'Twitterbot', 'cXensebot', 'smtbot', 'bnf.fr_bot', 'A6-Indexer', 'Facebot', 'Twitterbot', 'OrangeBot', 'memorybot', 'AdvBot', 'MegaIndex', 'SemanticScholarBot', 'nerdybot', 'xovibot', 'archive.org_bot', 'Applebot', 'TweetmemeBot', 'crawler4j', 'findxbot', 'SemrushBot', 'yoozBot', 'lipperhey', 'Domain Re-Animator Bot'];
    try {
        new RegExp('(?<! cu)bot').test('dangerbot');
        list.splice(list.lastIndexOf('bot'), 1);
        list.push('(?<! cu)bot')
    } catch (error) {}
    var regex = new RegExp('(' + list.join('|') + ')','i');
    function isbot(userAgent) {
        return regex.test(userAgent)
    }
    var PrivateWindow = {
        then: function then() {}
    };
    if ('Promise'in window && 'fetch'in window) {
        PrivateWindow = Promise.resolve(false)
    }
    function isPrivateWindow() {
        return PrivateWindow
    }
    function setTagsFn(tagsArray, keyType) {
        keyType = keyType || 'device';
        var key = getDeviceId();
        var contactKey = getContactKey();
        if (keyType === 'contact') {
            if (!contactKey) {
                return
            }
            key = contactKey
        } else if (keyType === 'contact_or_device') {
            key = contactKey || key
        }
        if (!Array.isArray(tagsArray)) {
            logError('setTags method parameters is missing or incorrect.');
            return
        }
        var invalid = false;
        for (var i = 0; i < tagsArray.length; i++) {
            if (!tagsArray[i].hasOwnProperty('tag')) {
                invalid = true;
                break
            }
            if (tagsArray[i].hasOwnProperty('changeTime')) {
                if (!isNaN(Date.parse(tagsArray[i].changeTime)) && !isIsoDate(tagsArray[i].changeTime)) {
                    tagsArray[i].changeTime = new Date(tagsArray[i].changeTime).toISOString()
                }
            }
            if (tagsArray[i].hasOwnProperty('removeTime')) {
                if (!isNaN(Date.parse(tagsArray[i].removeTime)) && !isIsoDate(tagsArray[i].removeTime)) {
                    tagsArray[i].removeTime = new Date(tagsArray[i].removeTime).toISOString()
                }
            }
        }
        if (invalid) {
            logError('setTags method parameters is missing or incorrect.');
            return
        }
        var setTagsObj = {
            accountName: 'dvl',
            key: key,
            tags: tagsArray
        };
        logInfo(setTagsObj);
        return fetch('https://dev-push.dengage.com/api/setTags', {
            method: 'POST',
            mode: 'cors',
            cache: 'no-cache',
            credentials: 'omit',
            headers: {
                'Content-Type': 'text/plain'
            },
            body: JSON.stringify(setTagsObj)
        }).catch((function(e) {
            logError(e.toString())
        }
        ))
    }
    function pageView(inputParams) {
        var params = deepCopy(inputParams);
        params.page_url = window.location.href;
        params.page_title = document.title;
        if (params.category_path) {
            storage.set('extra.last_cat', params.category_path)
        }
        sendDeviceEvent('page_view_events', params)
    }
    function sendCartEvents(inputParams, event_type) {
        var params = deepCopy(inputParams);
        delete params.cartItems;
        params.event_id = generateUUID();
        params.event_type = event_type;
        sendDeviceEvent('shopping_cart_events', params)
    }
    function addToCart(inputParams) {
        sendCartEvents(inputParams, 'add_to_cart');
        var tags = [{
            tag: 'cart_update_date',
            value: new Date
        }];
        if (Array.isArray(inputParams.cartItems) && inputParams.cartItems.length > 0) {
            tags.push({
                tag: 'cart_product_list',
                value: inputParams.cartItems.map((function(c) {
                    return c.product_id
                }
                )).join(',')
            })
        }
        setTagsFn(tags, 'contact')
    }
    function removeFromCart(inputParams) {
        sendCartEvents(inputParams, 'remove_from_cart');
        var tags = [{
            tag: 'cart_update_date',
            value: Array.isArray(inputParams.cartItems) && inputParams.cartItems.length > 0 ? new Date : ''
        }];
        if (Array.isArray(inputParams.cartItems)) {
            tags.push({
                tag: 'cart_product_list',
                value: inputParams.cartItems.map((function(c) {
                    return c.product_id
                }
                )).join(',')
            })
        }
        setTagsFn(tags, 'contact')
    }
    function viewCart(inputParams) {
        logInfo('viewCart event is removed. Use pageView event instead.')
    }
    function deleteCart(inputParams) {
        sendCartEvent(inputParams, 'delete_cart');
        setTagsFn([{
            tag: 'cart_update_date',
            value: ''
        }, {
            tag: 'cart_product_list',
            value: ''
        }], 'contact')
    }
    function beginCheckout(inputParams) {
        sendCartEvents(inputParams, 'begin_checkout');
        setTagsFn([{
            tag: 'last_begin_checkout_date',
            value: new Date
        }], 'contact')
    }
    function order(inputParams) {
        var params = deepCopy(inputParams);
        delete params.cartItems;
        params.event_type = 'order';
        sendDeviceEvent('order_events', params);
        setTagsFn([{
            tag: 'cart_update_date',
            value: ''
        }, {
            tag: 'cart_product_list',
            value: ''
        }, {
            tag: 'last_order_date',
            value: new Date
        }], 'contact');
        if (Array.isArray(inputParams.cartItems)) {
            var _iterator = _createForOfIteratorHelper(inputParams.cartItems), _step;
            try {
                for (_iterator.s(); !(_step = _iterator.n()).done; ) {
                    var product = _step.value;
                    product.order_id = params.order_id;
                    product.payment_method = params.payment_method;
                    product.event_type = params.event_type;
                    sendDeviceEvent('order_events_detail', product)
                }
            } catch (err) {
                _iterator.e(err)
            } finally {
                _iterator.f()
            }
        }
    }
    function cancelOrder(inputParams) {
        var params = deepCopy(inputParams);
        delete params.cartItems;
        params.event_type = 'cancel';
        params.total_amount = -params.total_amount;
        sendDeviceEvent('order_events', params);
        if (Array.isArray(inputParams.cartItems)) {
            var _iterator2 = _createForOfIteratorHelper(inputParams.cartItems), _step2;
            try {
                for (_iterator2.s(); !(_step2 = _iterator2.n()).done; ) {
                    var product = _step2.value;
                    product.order_id = params.order_id;
                    product.payment_method = params.payment_method;
                    product.event_type = params.event_type;
                    sendDeviceEvent('order_events_detail', product)
                }
            } catch (err) {
                _iterator2.e(err)
            } finally {
                _iterator2.f()
            }
        }
    }
    function search(inputParams) {
        var params = deepCopy(inputParams);
        sendDeviceEvent('search_events', params)
    }
    function sendWishlistEvents(inputParams, event_type) {
        var params = deepCopy(inputParams);
        delete params.items;
        params.event_id = generateUUID();
        params.event_type = event_type;
        params.list_name = params.list_name || 'favorites';
        sendDeviceEvent('wishlist_events', params)
    }
    function addToWishlist(inputParams) {
        sendWishlistEvents(inputParams, 'add')
    }
    function removeFromWishlist(inputParams) {
        sendWishlistEvents(inputParams, 'remove')
    }
    var ecommFunctions = Object.freeze({
        __proto__: null,
        pageView: pageView,
        addToCart: addToCart,
        removeFromCart: removeFromCart,
        viewCart: viewCart,
        deleteCart: deleteCart,
        beginCheckout: beginCheckout,
        order: order,
        cancelOrder: cancelOrder,
        search: search,
        addToWishlist: addToWishlist,
        removeFromWishlist: removeFromWishlist
    });
    function ouibounce(el, custom_config) {
        var config = custom_config || {}
          , aggressive = config.aggressive || false
          , sensitivity = setDefault(config.sensitivity, 20)
          , timer = setDefault(config.timer, 1e3)
          , delay = setDefault(config.delay, 0)
          , callback = config.callback || function() {}
          , cookieExpire = setDefaultCookieExpire(config.cookieExpire) || ''
          , cookieDomain = config.cookieDomain ? ';domain=' + config.cookieDomain : ''
          , cookieName = config.cookieName ? config.cookieName : 'viewedOuibounceModal'
          , sitewide = config.sitewide === true ? ';path=/' : ''
          , _delayTimer = null
          , _html = document.documentElement;
        function setDefault(_property, _default) {
            return typeof _property === 'undefined' ? _default : _property
        }
        function setDefaultCookieExpire(days) {
            var ms = days * 24 * 60 * 60 * 1e3;
            var date = new Date;
            date.setTime(date.getTime() + ms);
            return '; expires=' + date.toUTCString()
        }
        setTimeout(attachOuiBounce, timer);
        function attachOuiBounce() {
            if (isDisabled()) {
                return
            }
            _html.addEventListener('mouseleave', handleMouseleave);
            _html.addEventListener('mouseenter', handleMouseenter);
            _html.addEventListener('keydown', handleKeydown)
        }
        function handleMouseleave(e) {
            if (e.clientY > sensitivity) {
                return
            }
            _delayTimer = setTimeout(fire, delay)
        }
        function handleMouseenter() {
            if (_delayTimer) {
                clearTimeout(_delayTimer);
                _delayTimer = null
            }
        }
        var disableKeydown = false;
        function handleKeydown(e) {
            if (disableKeydown) {
                return
            } else if (!e.metaKey || e.keyCode !== 76) {
                return
            }
            disableKeydown = true;
            _delayTimer = setTimeout(fire, delay)
        }
        function checkCookieValue(cookieName, value) {
            return parseCookies()[cookieName] === value
        }
        function parseCookies() {
            var cookies = document.cookie.split('; ');
            var ret = {};
            for (var i = cookies.length - 1; i >= 0; i--) {
                var el = cookies[i].split('=');
                ret[el[0]] = el[1]
            }
            return ret
        }
        function isDisabled() {
            return checkCookieValue(cookieName, 'true') && !aggressive
        }
        function fire() {
            if (isDisabled()) {
                return
            }
            if (el) {
                el.style.display = 'block'
            }
            callback();
            disable()
        }
        function disable(custom_options) {
            var options = custom_options || {};
            if (typeof options.cookieExpire !== 'undefined') {
                cookieExpire = setDefaultCookieExpire(options.cookieExpire)
            }
            if (options.sitewide === true) {
                sitewide = ';path=/'
            }
            if (typeof options.cookieDomain !== 'undefined') {
                cookieDomain = ';domain=' + options.cookieDomain
            }
            if (typeof options.cookieName !== 'undefined') {
                cookieName = options.cookieName
            }
            document.cookie = cookieName + '=true' + cookieExpire + cookieDomain + sitewide;
            _html.removeEventListener('mouseleave', handleMouseleave);
            _html.removeEventListener('mouseenter', handleMouseenter);
            _html.removeEventListener('keydown', handleKeydown)
        }
        return {
            fire: fire,
            disable: disable,
            isDisabled: isDisabled
        }
    }
    var globalJsCode = '<script' + '>' + "\nfunction handleFormData(formEl){\n\n  var formData = {\n    // name: '',\n    // surname: '',\n    // email: '',\n    // email_permission: true,\n    // gsm: '',\n    // gsm_permission: true,\n    // birthday: null,\n    // tags: [],\n  };\n\n  function validateInput(element, isInvalidFunc) {\n    element.dataset.dnInvalid = element.value\n      ? isInvalidFunc(element.value, element)\n      : (element.dataset.dnRequired === 'true');\n  }\n\n  var inputTypeProcesses = {\n    TEXT: {\n      getValue: function (element) {\n        return element.value;\n      },\n      getIsInvalid: function (value) {\n        return value.length > 50;\n      },\n      getValidationMessage: function () {\n        return 'Please enter a text less than 50 characters'\n      }\n    },\n    EMAIL: {\n      getValue: function (element) {\n        return element.value ? element.value.trim() : '';\n      },\n      getIsInvalid: function (value) {\n        var atCharSplit = value.split('@')\n\n        if(atCharSplit.length !== 2) {\n          return true\n        }\n\n        function isEmpty(value) { return value === ''}\n\n        function hasConsecutiveChar(string, chars){\n          for(var i=0; i<string.length - 1; i++) {\n            if(chars.includes(string[i]) && string[i] === string[i + 1]) {\n              return true\n            }\n          }\n          return false\n        }\n\n        function startsOrEndsWith(string, chars) {\n          return chars.includes(string[0]) || chars.includes(string[string.length - 1])\n        }\n\n        if(atCharSplit.some(isEmpty)){\n          return true\n        }\n\n        var alphanumeric = \"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\"\n        var localDomainChars = '-.'\n        var recipientNameChars = \".!#$%&'*+-/=?^_`{|}~\"\n\n        var domainName = atCharSplit[1]\n\n        var domainDotSplit = domainName.split('.')\n\n        if(domainDotSplit.length === 1) {\n          return true\n        }\n\n        if(domainDotSplit.some(isEmpty)){\n          return true\n        }\n        \n        var topLevelDomain = domainDotSplit[domainDotSplit.length - 1]\n        \n        if(topLevelDomain.length < 2 || topLevelDomain.split('').some(function(char) { return !alphanumeric.includes(char)})) {\n          return true\n        }\n\n        var localDomain = domainName.substring(0, domainName.lastIndexOf('.'))\n\n        if(\n          startsOrEndsWith(localDomain, localDomainChars) ||\n          hasConsecutiveChar(localDomain, localDomainChars) ||\n          localDomain.split('').some(function(char) { return !(alphanumeric + localDomainChars).includes(char)})\n        ) {\n          return true\n        }\n\n        var receipentName = atCharSplit[0]\n\n        if(\n          hasConsecutiveChar(receipentName, recipientNameChars) ||\n          startsOrEndsWith(receipentName, recipientNameChars) ||\n          receipentName.split('').some(function(char) { return !(alphanumeric + recipientNameChars).includes(char)})\n        ) {\n          return true\n        }\n\n        return false;\n      },\n      getValidationMessage: function () {\n        return 'Please enter a valid email address'\n      }\n    },\n    GSM: {\n      getValue: function (element, data) {\n        var gsmPrefixSelect = formEl.querySelector('.gsm-prefix-select-btn');\n\n        if (gsmPrefixSelect) {\n          return '00' + gsmPrefixSelect.dataset.dnPhoneCode + element.value;\n        }\n\n        return element.value;\n      },\n      getIsInvalid: function (value) {\n        let numberLength = value.length;\n        \n        var gsmPrefixSelect = formEl.querySelector('.gsm-prefix-select-btn');\n        if (gsmPrefixSelect) {\n          numberLength = value.length + gsmPrefixSelect.dataset.dnPhoneCode.length;\n        }\n\n        return numberLength < 7 || numberLength > 15;\n      },\n      getValidationMessage: function () {\n        return 'Please enter a valid GSM number between 7 and 15 characters';\n      }\n    },\n    DATEPICKER: {\n      getValue: function (element) {\n        return element.value ? new Date(element.value).toISOString() : null;\n      },\n      getIsInvalid: function (value) {\n        return value ? new Date(value) >= new Date() : false;\n      },\n      getValidationMessage: function () {\n        return 'Please enter a birthday earlier than today'\n      }\n    },\n    TAGS: {\n      getValue: function (element) {\n        var checkedTagEls = element.querySelectorAll('input[type=\"checkbox\"]:checked');\n\n        var result = [];\n\n        checkedTagEls.forEach(function (checkedTagEl) {\n          result.push(checkedTagEl.value);\n        });\n\n        return result;\n      },\n      getIsInvalid: function (values) {\n        return (\n          Array.isArray(values) &&\n          !!values.length &&\n          values.every(function (value) {\n            return !isNaN(value);\n          })\n        );\n      },\n      getValidationMessage: function () {\n        return 'Field(s) must be valid'\n      }\n    },\n    RATING: {\n      getValue: function (element) {\n        var tagId = element.dataset.dnTagId\n        var tagName = element.dataset.dnTagName\n        var checkedTagEls = element.querySelectorAll('input[type=\"radio\"]:checked');\n\n        var result = [];\n        checkedTagEls.forEach(function (checkedTagEl) {\n          // result.push({ tag: tagId, name: tagName, value: checkedTagEl.value});\n          result.push({ tag: tagName, value: checkedTagEl.value});\n        });\n        return result;\n      },\n      getIsInvalid: function() {\n        return false\n      },\n      getValidationMessage: function() {\n        return ''\n      },\n    },\n    PERMISSION_CHECKBOX: {\n      getValue: function (element) {\n        return element.checked;\n      },\n      getIsInvalid: function (_, element) {\n        return !element.checked;\n      },\n      getValidationMessage: function () {\n        return 'Permission is required for subscription'\n      }\n    },\n  };\n\n  var isValid = true;\n  var inputEls = formEl.querySelectorAll('[data-dn-id]');\n  var messageEls = formEl.querySelectorAll('[data-dn-invalid-message-type]');\n  \n  messageEls.forEach(function (element) {\n    var inputType = element.dataset.dnInvalidMessageType || 'TEXT';\n    var input = inputTypeProcesses[inputType];\n\n    element.innerHTML = input.getValidationMessage();\n  })\n\n  inputEls.forEach(function (element) {\n    var propertyName = element.dataset.dnId;\n    var inputType = element.dataset.dnType || 'TEXT';\n    var input = inputTypeProcesses[inputType];\n\n    validateInput(element, input.getIsInvalid);\n    checkHeight();\n\n    if (element.dataset.dnHasListener === 'false') {\n      element.addEventListener('input', function (event) {\n        validateInput(event.target, input.getIsInvalid);\n        checkHeight();\n      });\n\n      element.dataset.dnHasListener = true;\n    }\n\n    if (element.dataset.dnInvalid === 'true') {\n      isValid = false;\n    }\n\n    formData[propertyName] = input.getValue(element);\n  });\n\n  if (!isValid) {\n    return;\n  }\n  \n  if (formData && 'mergedPermission' in formData) {\n    formData.emailPermission = formData.mergedPermission;\n    formData.gsmPermission = formData.mergedPermission;\n\n    delete formData.mergedPermission;\n  }\n\n  return formData \n}\n\nfunction startLoading() {\n  var loadingEl = document.querySelector('body > .loading-overlay');\n  if (loadingEl) {\n    loadingEl.dataset.dnIsLoading = true;\n  }\n}\n\nvar Dn = {\n  dismiss: function() {\n    window.parent.postMessage({action: 'dismiss'}, '*');\n  },\n  openUrl: function(url, newTab) {\n    window.parent.postMessage({action: 'openUrl', url: url, newTab: newTab}, '*');\n  },\n  sendClick: function(buttonId) {\n    window.parent.postMessage({action: 'sendClick', buttonId: buttonId}, '*');\n  },\n  close: function() {\n    window.parent.postMessage({action: 'close'}, '*');\n  },\n  setTags: function(tags) {\n    window.parent.postMessage({action: 'setTags', tags: tags}, '*');\n  },\n  copyText: function(text) {\n    window.parent.postMessage({action: 'copyText', text: text}, '*');\n  },\n  postQuestion: function() {\n    var formEl = document.querySelector('form.form[data-dn-form-id=\"question_form\"]');\n\n    if (!formEl) {\n      return;\n    }\n  \n    var inputWrapperEl = formEl.querySelector('.form-block');\n    var messageEl = inputWrapperEl.querySelector('div.form-message');\n    var tagId = inputWrapperEl.dataset.dnId;\n    var tagName = inputWrapperEl.dataset.dnName;\n    var inputType = inputWrapperEl.dataset.dnIsRadio === 'true' ? 'RADIO' : 'CHECKBOX';\n    var maxSelection = inputWrapperEl.dataset.dnMaxSelection;\n    var minSelection = inputWrapperEl.dataset.dnMinSelection;\n    var inputs = {\n      RADIO: {\n        type: 'radio',\n        message: 'Please select at least one option',\n        validate: function () {\n          var checkedEls = inputWrapperEl.querySelectorAll('input[type=\"' + this.type + '\"]:checked');\n  \n          inputWrapperEl.dataset.dnInvalid = checkedEls.length === 0;\n        },\n      },\n      CHECKBOX: {\n        type: 'checkbox',\n        message:\n          'Please select at least ' + minSelection + ' and at most ' + maxSelection + ' option(s)',\n        validate: function () {\n          var checkedEls = inputWrapperEl.querySelectorAll('input[type=\"' + this.type + '\"]:checked');\n  \n          inputWrapperEl.dataset.dnInvalid =\n            checkedEls.length < minSelection || checkedEls.length > maxSelection;\n        },\n      },\n    };\n    var input = inputs[inputType];\n  \n    function inputValidation(element) {\n      if (element.dataset.dnIsOtherActive === 'false') {\n        return;\n      }\n      var errors = {\n        TEXT: {\n          condition: element.value.length > 120,\n          description: 'The field may not be greater than 120 characters',\n        },\n        INTEGER: {\n          condition: parseInt(element.value) < -10000 || parseInt(element.value) > 10000,\n          description: 'The field should between -10000 and 10000',\n        },\n      };\n      var error = errors[element.dataset.dnValueType];\n      var isInvalid = !element.value || error.condition;\n  \n      inputWrapperEl.dataset.dnInvalid = isInvalid;\n  \n      if (isInvalid) {\n        var messageEl = inputWrapperEl.querySelector('div.form-message');\n\n        messageEl.innerHTML = !element.value ? 'This field is required' : error.description;\n      }\n    }\n  \n    var inputEls = inputWrapperEl.querySelectorAll('input[type=\"' + input.type + '\"]');\n    var otherInputEl = inputWrapperEl.querySelector('input[data-dn-id=\"otherInput\"]');\n  \n    messageEl.innerHTML = input.message;\n    input.validate();\n    checkHeight();\n\n    inputEls.forEach(function (element) {\n      if (element.dataset.dnHasListener === 'false') {\n        element.addEventListener('input', function () {\n          input.validate();\n          checkHeight();\n        });\n  \n        element.dataset.dnHasListener = true;\n      }\n    });\n  \n    if (otherInputEl) {\n      inputValidation(otherInputEl);\n    }\n  \n    if (otherInputEl && otherInputEl.dataset.dnHasListener === 'false') {\n      otherInputEl.addEventListener('input', function (event) {\n        inputValidation(event.target);\n        checkHeight();\n      });\n  \n      otherInputEl.dataset.dnHasListener = true;\n    }\n  \n    if (inputWrapperEl.dataset.dnInvalid === 'true') {\n      return;\n    }\n  \n    var checkedInputEls = inputWrapperEl.querySelectorAll('input[type=\"' + input.type + '\"]:checked');\n    var isOtherSelected = inputWrapperEl.querySelector('input[data-dn-id=\"otherRadio\"]:checked');\n    var tags = [];\n  \n    if (isOtherSelected) {\n      // tags.push({ tag: tagId, name: tagName, value: otherInputEl.value });\n      tags.push({ tag: tagName, value: otherInputEl.value });\n    } else {\n      checkedInputEls.forEach(function (element) {\n        // tags.push({ tag: tagId, name: tagName, value: element.value });\n        tags.push({ tag: tagName, value: element.value });\n      });\n    }\n  \n    Dn.setTags(tags);\n    Dn.close();\n  },\n  postSubscription: function() {\n    var formEl = document.querySelector('form.form[data-dn-form-id=\"subscription_form\"]');\n    \n    if(!formEl) {\n      return;\n    }\n\n    var formData = handleFormData(formEl)\n\n    if(!formData) { return; }\n\n    startLoading();\n\n    window.parent.postMessage({ action: 'postSubscription', form: formData }, '*');\n  },\n  postSubscriptionWithTags: function() {\n    var formEl = document.querySelector('form.form[data-dn-form-id=\"subscription_form\"]');\n    \n    if(!formEl) {\n      return;\n    }\n\n    var formData = handleFormData(formEl)\n\n    if(!formData) { return; }\n\n    var tags = formData.rating\n\n    delete formData.rating\n\n    startLoading();\n\n    window.parent.postMessage({ action: 'postSubscriptionWithTags', form: formData, tags: tags }, '*');\n  }\n};\n\nfunction getDocHeight() {\n    var body = document.body,\n        html = document.documentElement;\n    var height = Math.max(\n        // body.scrollHeight,\n        body.offsetHeight,\n        //html.clientHeight,\n        //html.scrollHeight,\n        html.offsetHeight,\n    );\n    return height;\n}\n\nvar oldHeight = 0;\nvar checkCount = 0;\nfunction checkHeightOld() {\n    var height = getDocHeight();\n    if (oldHeight != height) {\n        oldHeight = height;\n        window.parent.postMessage({action: 'height', value: height}, '*');\n    }\n    checkCount++;\n    setTimeout(checkHeight, checkCount > 20 ? 300 : 100);\n}\n// setTimeout(checkHeightOld, 100);\n\nfunction checkHeight() {\n  var height = getDocHeight();\n  if (oldHeight != height) {\n    oldHeight = height;\n    window.parent.postMessage({action: 'height', value: height}, '*');\n  }\n}\n\nfunction imageLoadChecker() {\n  var imgs = document.querySelectorAll('img')\n  for(var i=0; i<imgs.length; i++) {\n    var img = imgs[i]\n    img.addEventListener('load', checkHeight)\n    img.addEventListener('error', checkHeight)\n  }\n  checkHeight()\n}\nwindow.onload = function(event){\n  imageLoadChecker()\n}\n\nfunction addOtherRadioEventlistener() {\n  var otherRadioEl = document.querySelector('form.form[data-dn-form-id=\"question_form\"] input[data-dn-id=\"otherRadio\"]');\n  var radios = document.querySelectorAll('form.form[data-dn-form-id=\"question_form\"] input[type=\"radio\"]');\n  \n  if (otherRadioEl && radios) {\n    radios.forEach(function(radio) {\n      radio.addEventListener('input', function(event) {\n        var otherInputEl = document.querySelector('form.form[data-dn-form-id=\"question_form\"] input[data-dn-id=\"otherInput\"]');\n        \n        if (otherInputEl) {\n          otherInputEl.dataset.dnIsOtherActive = event.target.dataset.dnId === \"otherRadio\" ? 'true' : 'false';\n        }\n\n        checkHeight();\n      })\n    })\n  }\n}\n\nsetTimeout(addOtherRadioEventlistener, 100);\n\nfunction setCountryCodeList(codes, selectedCountry) {\n  var gsmPrefixSelect = document.querySelector('form.form[data-dn-form-id=\"subscription_form\"] .gsm-prefix-select');\n  var gsmPrefixSelectList = gsmPrefixSelect.querySelector('.gsm-prefix-select-list');\n  \n  while (gsmPrefixSelectList.firstChild) {\n    if (gsmPrefixSelectList.lastChild.id === 'searchInput') {\n      break;\n    };\n\n    gsmPrefixSelectList.removeChild(gsmPrefixSelectList.lastChild);\n  }\n\n  codes.forEach(data => {\n    let div = document.createElement(\"div\");\n\n    div.classList.add('option');\n\n    if (selectedCountry && selectedCountry.iso === data.iso) {\n      div.classList.add('selected');\n    }\n\n    div.innerText = data.iso + ' +' + data.phonecode;\n    div.dataset.dnPhoneCode = data.phonecode;\n    div.addEventListener('click', function(option) {\n      var gsmPrefixSelect = document.querySelector('form.form[data-dn-form-id=\"subscription_form\"] .gsm-prefix-select');\n      var gsmPrefixSelectBtn = gsmPrefixSelect.querySelector('.gsm-prefix-select-btn');\n      var gsmPrefixSelectList = gsmPrefixSelect.querySelector('.gsm-prefix-select-list');\n      var lastSelectedOption = gsmPrefixSelectList.querySelector('.selected');\n\n      option.target.classList.add('selected');\n\n      if (lastSelectedOption) {\n        lastSelectedOption.classList.remove('selected');\n      }\n\n      if (gsmPrefixSelectBtn) {\n        gsmPrefixSelectBtn.innerText = option.target.innerText;\n        gsmPrefixSelectBtn.dataset.dnPhoneCode = option.target.dataset.dnPhoneCode;\n        gsmPrefixSelectBtn.classList.remove('is-opened');\n      }\n\n      if (gsmPrefixSelectList) {\n        gsmPrefixSelectList.classList.remove('is-opened');\n      }\n    })\n\n    gsmPrefixSelectList.append(div);\n  })\n}\n\nfunction addGsmSelectEventListener() {\n  var gsmPrefixSelect = document.querySelector('form.form[data-dn-form-id=\"subscription_form\"] .gsm-prefix-select');\n\n  if (gsmPrefixSelect) {\n    var gsmPrefixSelectBtn = gsmPrefixSelect.querySelector('.gsm-prefix-select-btn');\n    var gsmPrefixSelectList = gsmPrefixSelect.querySelector('.gsm-prefix-select-list');\n  \n    fetch('https://f6db8103-830e-d147-3a40-afef0c991358.dengagecdn.com/area_codes.json')\n      .then((response) => {\n        return response.text();\n      })\n      .then(result => {\n        var parsedResult = JSON.parse(result);\n        var countryCodes = parsedResult.countries;\n\n        // get lang from timezone\n        var timezones = parsedResult.timezones;\n        var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;\n        var timezoneKey = timezones[timezone].c ? timezone : timezones[timezone].a;\n        var timezoneCountryCode = timezones[timezoneKey] && timezones[timezoneKey].c ? timezones[timezoneKey].c[0] : null;\n        var timezoneCountry = countryCodes.find(item => item.iso === timezoneCountryCode);\n\n        // get lang from browser\n        let navigatorLang = navigator.language || navigator.userLanguage;\n\n        if (navigatorLang.includes('-')) {\n          navigatorLang = navigatorLang.split('-')[1];\n        }\n\n        var browserLang = countryCodes.find(item => item.iso === navigatorLang.toUpperCase()) || { iso: 'TR', phonecode: 90 };\n\n        if (gsmPrefixSelectBtn) {\n          gsmPrefixSelectBtn.addEventListener('click', function(el) {\n            el.target.classList.toggle('is-opened');\n            el.target.nextElementSibling.classList.toggle('is-opened');\n          })\n\n          var hasNoTimezone = timezone === \"\" || !timezone || !timezoneCountry;\n          var countryObject = hasNoTimezone ? browserLang : timezoneCountry;\n\n          gsmPrefixSelectBtn.innerText =  countryObject.iso + ' +' + countryObject.phonecode;\n          gsmPrefixSelectBtn.dataset.dnPhoneCode = countryObject.phonecode;\n        }\n\n        // append search input\n        const inputEl = document.createElement(\"input\");\n        inputEl.id = \"searchInput\";\n        inputEl.name = \"searchInput\";\n        inputEl.type = \"text\";\n        inputEl.placeholder = \"Search\";\n        inputEl.maxlength = 2;\n        inputEl.style.padding = '4px';\n        inputEl.style.width = 'inherit';\n        inputEl.style.position = 'sticky';\n        inputEl.style.top = '0px';\n        inputEl.style.left = '0px';\n\n        inputEl.addEventListener(\"input\", function (e) {\n          if (e.target.value.length > 2) {\n            e.target.value = e.target.value.slice(0, 2);\n          }\n\n          if (!e.target.value) {\n            setCountryCodeList(countryCodes);\n          }\n\n          if (e.target.value.length > 2) {\n            e.target.value = e.target.value.slice(0, 2);\n          }\n\n          var testCodes = countryCodes.filter(item => item.iso.includes(e.target.value.toUpperCase()));\n          setCountryCodeList(testCodes);\n        });\n\n        gsmPrefixSelectList.append(inputEl);\n        setCountryCodeList(countryCodes, countryObject);\n      })\n      .catch((e) => {\n        var formBlock = document.querySelector('.form-block.has-select');\n        if (formBlock) {\n          formBlock.classList.remove('has-select');\n          gsmPrefixSelect.remove();\n        }\n\n        var formMessage = document.querySelector('.form-message.grid-span-2');\n        if (formMessage) {\n          formMessage.classList.remove('grid-span-2');\n        }\n      });\n  }\n}\n\nsetTimeout(addGsmSelectEventListener, 100);\n\nvar enableClicks = false;\nsetTimeout(function () {\n    enableClicks = true;\n}, 1500);\nsetTimeout(() => {\n  window.addEventListener('message', function(event) {\n    if (event.data.action === 'closeForm') {\n      var loadingEl = document.querySelector('body > .loading-overlay');\n      if (loadingEl) {\n        loadingEl.dataset.dnIsLoading = false;\n      }\n\n      if (event.data.status === 'success') {\n        var containerEl = document.querySelector('.container');\n        var submittedContentEl = document.querySelector('.submitted-content');\n        var submitDatasetKeys = ['dnIsEnabled', 'dnIsModalAutoCloseEnabled', 'dnModalCloseSeconds'];\n        var submittedContentDataset = {\n          dnIsEnabled: 'true',\n          dnIsModalAutoCloseEnabled: 'true',\n          dnModalCloseSeconds: 6,\n        }\n\n        if (submittedContentEl) {\n          submitDatasetKeys.forEach((key) => {\n            submittedContentDataset[key] = submittedContentEl.dataset[key]\n          });\n        }\n\n        if (submittedContentDataset.dnIsEnabled === 'true') {\n          if (containerEl) {\n            containerEl.dataset.dnIsSubmitted = true;\n            checkHeight();\n          }\n          \n          if (submittedContentDataset.dnIsModalAutoCloseEnabled === 'true') {\n            setTimeout(() => {\n              if (containerEl) {\n                containerEl.dataset.dnIsSubmitted = false\n              }\n              \n              Dn.close();\n            }, submittedContentDataset.dnModalCloseSeconds * 1000)\n          }\n        } else {\n          Dn.close();\n        }\n      }\n    }\n  }, false);\n}, 200);\n" + '<' + '/script' + '>' + '</head>';
    var globalCssCode = '<head><style' + '>' + "\nhtml, body, div, span, applet, object, iframe,\nh1, h2, h3, h4, h5, h6, p, blockquote, pre,\na, abbr, acronym, address, big, cite, code,\ndel, dfn, em, img, ins, kbd, q, s, samp,\nsmall, strike, strong, sub, sup, tt, var,\nb, u, i, center,\ndl, dt, dd, ol, ul, li,\nfieldset, form, label, legend,\ntable, caption, tbody, tfoot, thead, tr, th, td,\narticle, aside, canvas, details, embed,\nfigure, figcaption, footer, header, hgroup,\nmenu, nav, output, ruby, section, summary,\ntime, mark, audio, video {\n\tmargin: 0;\n\tpadding: 0;\n\tborder: 0;\n\tvertical-align: baseline;\n}\narticle, aside, details, figcaption, figure,\nfooter, header, hgroup, menu, nav, section {\n\tdisplay: block;\n}\nhtml {\n  overflow: hidden !important;\n}\nbody {\n\tline-height: 1;\n}\nol, ul {\n\tlist-style: none;\n}\nblockquote, q {\n\tquotes: none;\n}\nblockquote:before, blockquote:after,\nq:before, q:after {\n\tcontent: '';\n\tcontent: none;\n}\ntable {\n\tborder-collapse: collapse;\n\tborder-spacing: 0;\n}\n*,\n*::before,\n*::after {\n\tbox-sizing: border-box;\n}\n" + '</style' + '>';
    function getMessageHtmlAsUri(content) {
        var html = content.props.html.replace('</head>', globalJsCode).replace('<head>', globalCssCode);
        var uri = 'data:text/html,' + encodeURIComponent(html);
        return uri
    }
    function generateBannerHtml(content) {
        var messageHtml = getMessageHtmlAsUri(content);
        var html = "\n<div class=\"dn-iframe-container\">\n    <iframe src=\"".concat(messageHtml, "\" style=\"border: none; width: 100%; height: 0; display: block;\"></iframe>\n</div>\n\n<style>\nbody > .dengage-onsite-banner {\n    box-shadow: 0 3px 6px 0 rgba(0, 0, 0, 0.2) !important;\n    position: ").concat(content.props.isFixed ? 'fixed' : 'absolute', " !important;\n    width: 100% !important;\n    z-index: 100000000 !important;\n    left: 0 !important;\n    transform: translateY(0) !important;\n    transition: transform 0.5s ease-in-out !important;\n\n}\nbody > .dengage-onsite-banner.dn-top {\n    top: -200px !important;\n}\nbody > .dengage-onsite-banner.dn-bottom {\n    bottom: -200px !important;\n}\nbody > .dengage-onsite-banner.dn-top.dn-opened {\n    transform: translateY(200px) !important;\n}\nbody > .dengage-onsite-banner.dn-bottom.dn-opened {\n    transform: translateY(-200px) !important;\n}\n\n.dn-iframe-container {\n    width: 100% !important;\n    min-height: 0;\n}\n</style>\n");
        return html
    }
    function generateModalHtml(content) {
        var _window$_Dn_globaL_$u;
        var messageHtml = getMessageHtmlAsUri(content);
        var isMobile = ((_window$_Dn_globaL_$u = window._Dn_globaL_.ua) === null || _window$_Dn_globaL_$u === void 0 ? void 0 : _window$_Dn_globaL_$u.device.type) === 'mobile';
        var isPositionOld = content.props.position === 'MIDDLE';
        var calculatedWidth = window.innerWidth > content.props.maxWidth ? "".concat(content.props.maxWidth, "px") : '100vw';
        var toDeletedHeight = isMobile ? 20 : content.props.offset * 2 + 20;
        var positionClass = 'dn-onsite-' + (isPositionOld ? '' : 'new-') + 'modal';
        var html = "\n<div class=\"".concat(positionClass, "\">\n    <div class=\"dn-iframe-container\">\n        <iframe src=\"").concat(messageHtml, "\" style=\"border: none; width: 100%; height: 0;\"></iframe>\n    </div>\n    <div  class=\"dn-btn-popup-close\" style=\"").concat(content.props.isCloseButtonActive == false ? 'display:none;' : '', "\">\n        <svg width=\"32\" height=\"32\" viewBox=\"0 0 32 32\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n            <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M22.0303 11.0296C22.3232 10.7367 22.3232 10.2618 22.0303 9.96894C21.7374 9.67604 21.2626 9.67604 20.9697 9.96894L16 14.9386L11.0303 9.96894C10.7374 9.67604 10.2626 9.67604 9.96967 9.96894C9.67678 10.2618 9.67678 10.7367 9.96967 11.0296L14.9393 15.9993L9.96967 20.9689C9.67678 21.2618 9.67678 21.7367 9.96967 22.0296C10.2626 22.3225 10.7374 22.3225 11.0303 22.0296L16 17.0599L20.9697 22.0296C21.2626 22.3225 21.7374 22.3225 22.0303 22.0296C22.3232 21.7367 22.3232 21.2618 22.0303 20.9689L17.0607 15.9993L22.0303 11.0296Z\" fill=\"").concat(content.props.closeButtonColor, "\" fill-opacity=\"0.7\"/>\n        </svg>\n    </div>\n</div>\n\n<style>\nbody > .dengage-onsite-overlay {\n    display: block !important;\n    position: fixed !important;\n    z-index: 100000000 !important;\n    left: 0 !important;\n    top: 0 !important;\n    width: 100% !important;\n    height: 100% !important;\n    overflow: hidden !important;\n    padding: 0 !important;\n    margin: 0 !important;\n    background-color: rgba(0,0,0,0.3) !important;\n    line-height: 100vh !important;\n    text-align: center !important;\n}\n\n.dengage-onsite-new-overlay {\n  display: flex !important;\n  position: fixed !important;\n  z-index: 100000000 !important;\n  left: 0 !important;\n  top: 0 !important;\n  width: 100% !important;\n  height: 100% !important;\n  overflow: hidden !important;\n  padding: 0 !important;\n  margin: 0 !important;\n  background-color: rgba(0,0,0,0.3) !important;\n}\n\n.dn-onsite-modal {\n    margin: 0 auto !important;\n    display: inline-block !important;\n    vertical-align: middle !important;\n    width: calc(100vw - 20px) !important;\n    max-width: ").concat(content.props.maxWidth, "px !important;\n    max-height: calc(100vh - ").concat(toDeletedHeight, "px) !important;\n    height: auto  !important;\n    line-height: normal !important;\n    overflow: auto;\n}\n\n.dn-onsite-new-modal {\n  margin: 0 !important;\n  display: inline-block !important;\n  vertical-align: middle !important;\n  width: calc(100vw - 20px) !important;\n  max-width: ").concat(calculatedWidth, " !important;\n  max-height: calc(100vh - ").concat(toDeletedHeight, "px) !important;\n  height: auto !important;\n  line-height: normal !important;\n  overflow: auto;\n}\n\n.dn-justify-start {\n  justify-content: flex-start !important; \n}\n.dn-justify-center {\n  justify-content: center !important; \n}\n.dn-justify-end {\n  justify-content: flex-end !important; \n}\n.dn-align-start {\n  align-items: flex-start !important; \n}\n.dn-align-center {\n  align-items: center !important; \n}\n.dn-align-end {\n  align-items: flex-end !important; \n}\n\n.dengage-onsite-offset {\n  padding: ").concat(content.props.offset, "px !important;\n}\n\n.dengage-onsite-is-mobile {\n  justify-content: center !important;\n  padding: 0px !important;\n}\n\n.dn-iframe-container {\n    display: flex;\n    width: 100% !important;\n    min-height: 0 !important;\n    overflow: hidden !important;\n    border-radius: ").concat(content.props.cardRadius, "px !important;\n    height: auto  !important;\n    line-height: normal !important;\n    transition: opacity 0.5s ease-in-out;\n    opacity: 0 !important;\n}\n\n.dn-iframe-container.dn-opened {\n  opacity: 1 !important;\n}\n\n.dn-btn-popup-close {\n    position: relative;\n    color: #aaaaaa !important;\n    float: right !important;\n    height: 26px;\n}\n.dn-btn-popup-close:hover,\n.dn-btn-popup-close:focus {\n    color: #000 !important;\n    text-decoration: none !important;\n    cursor: pointer !important;\n}\n.dn-btn-popup-close:hover {\n    cursor: pointer !important;\n}\n</style>\n");
        return html
    }
    function convertLegacyMessage(legacyMessage) {
        var msg = legacyMessage.message_json;
        var whenToDisplay = msg.displayCondition.whenToDisplay;
        var noPageFilter = ['HOME_PAGE', 'ANY_PAGE'].includes(whenToDisplay);
        var newMessage = {
            groupId: '',
            publicId: legacyMessage.smsg_id,
            startDate: (new Date).toJSON(),
            endDate: msg.expireDate,
            priority: msg.priority == 1 ? 'High' : msg.priority == 2 ? 'Medium' : 'Low',
            status: 'ACTIVE',
            isRealtime: false,
            messageDetails: msg.messageDetails,
            content: {
                contentType: msg.content.type,
                contentId: msg.content.publicId || msg.content.contentId || msg.content.id || '',
                props: msg.content.props
            },
            triggerSettings: {
                triggerBy: msg.displayTiming.triggerBy,
                delay: msg.displayTiming.delay,
                showEveryXMinutes: msg.displayTiming.showEveryXMinutes,
                maxShowCount: 5,
                eventName: '',
                scrollPercentage: 0,
                doNotShowAfterClick: true
            },
            displayCondition: {
                whereToDisplay: whenToDisplay == 'HOME_PAGE' ? ['/^(/$|/?[^#]*#?/?$|/#?/?$)/'] : [],
                onsitePlatform: 'All',
                ruleSet: {
                    pageUrlFilters: (noPageFilter ? [] : msg.displayCondition.pageUrlFilters) || [],
                    pageUrlFiltersLogicOperator: msg.displayCondition.pageUrlFiltersLogicOperator,
                    screenNameFilters: (noPageFilter ? [] : msg.displayCondition.screenNameFilters) || [],
                    screenNameFiltersLogicOperator: msg.displayCondition.screenNameFiltersLogicOperator,
                    logicOperator: 'OR',
                    rules: []
                }
            }
        };
        return newMessage
    }
    function getDisplayTimeFromLegacyMessage(legacyMessage) {
        var result = 0;
        if (legacyMessage.next_display_time) {
            result = legacyMessage.next_display_time - legacyMessage.message_json.displayTiming.showEveryXMinutes * 6e4
        }
        return result
    }
    function sortMessages(messages) {
        return messages.sort(messageCompare)
    }
    function messageCompare(a, b) {
        var a_priority = a.priority == 'High' ? 1 : a.priority == 'Medium' ? 2 : 3;
        var b_priority = b.priority == 'High' ? 1 : b.priority == 'Medium' ? 2 : 3;
        var a_has_rule = hasRule(a);
        var b_has_rule = hasRule(b);
        var a_has_visitor_rule = hasVisitorInfoRule(a);
        var b_has_visitor_rule = hasVisitorInfoRule(b);
        var a_end_date = new Date(a.endDate).getTime();
        var b_end_date = new Date(b.endDate).getTime();
        if (a_priority - b_priority !== 0) {
            return a_priority - b_priority
        }
        if (a_has_visitor_rule - b_has_visitor_rule !== 0) {
            return b_has_visitor_rule - a_has_visitor_rule
        }
        if (a_has_rule - b_has_rule !== 0) {
            return b_has_rule - a_has_rule
        }
        return a_end_date - b_end_date
    }
    function hasRule(msg) {
        if (msg.displayCondition && msg.displayCondition.ruleSet) {
            var _ruleSet$pageUrlFilte, _ruleSet$screenNameFi, _ruleSet$rules;
            var ruleSet = msg.displayCondition.ruleSet;
            var hasPageRule = ((_ruleSet$pageUrlFilte = ruleSet.pageUrlFilters) === null || _ruleSet$pageUrlFilte === void 0 ? void 0 : _ruleSet$pageUrlFilte.length) > 0;
            var hasScreenRule = ((_ruleSet$screenNameFi = ruleSet.screenNameFilters) === null || _ruleSet$screenNameFi === void 0 ? void 0 : _ruleSet$screenNameFi.length) > 0;
            var hasRule = ((_ruleSet$rules = ruleSet.rules) === null || _ruleSet$rules === void 0 ? void 0 : _ruleSet$rules.length) > 0;
            return hasPageRule || hasScreenRule || hasRule
        }
    }
    function hasVisitorInfoRule(message) {
        var _message$displayCondi;
        var ruleSet = message === null || message === void 0 ? void 0 : (_message$displayCondi = message.displayCondition) === null || _message$displayCondi === void 0 ? void 0 : _message$displayCondi.ruleSet;
        return ruleSet && Array.isArray(ruleSet.rules) && ruleSet.rules.some((function(rule) {
            return Array.isArray(rule.criterions) && rule.criterions.some((function(criterion) {
                return criterion.valueSource === 'SERVER_SIDE'
            }
            ))
        }
        ))
    }
    function isInlineTargetValid(inlineTarget, messagePublicId) {
        var warningPrefix = 'Onsite Displayer: Inline message not injected Message(' + messagePublicId + ') target ';
        if (!inlineTarget) {
            logWarning(warningPrefix + 'is empty');
            return false
        }
        var selector = inlineTarget.selector || '';
        if (!selector) {
            logWarning(warningPrefix + 'selector is empty');
            return false
        }
        var type = inlineTarget.type || '';
        if (!type) {
            logWarning(warningPrefix + 'type is empty');
            return false
        }
        var validTypes = ['Fill', 'Start', 'End', 'Before', 'After'];
        if (!validTypes.includes(type)) {
            logWarning(warningPrefix + 'type is not one of "' + validTypes.join('", "') + '"', 'type: ', type);
            return false
        }
        if (!document.querySelector(selector)) {
            logWarning(warningPrefix + 'selector cannot found results', 'selector: ', selector);
            return false
        }
        return true
    }
    function isTypeformSubmittedByUserGroup(typeformId, uniqifyColumnName, uniqifyColumnLegacyValue) {
        var hasUniqifyColumnValue = uniqifyColumnLegacyValue && !uniqifyColumnLegacyValue.startsWith('{%=') && !uniqifyColumnLegacyValue.endsWith('%}');
        return Promise.resolve(hasUniqifyColumnValue ? uniqifyColumnLegacyValue : fetchVisitorInfo().then((function() {
            var visitorInfoAttrs = storage.get('visitor_info.attrs');
            return visitorInfoAttrs ? visitorInfoAttrs[uniqifyColumnName] : null
        }
        ))).then((function(uniqifyColumnValue) {
            if (!uniqifyColumnValue) {
                return ''
            }
            return fetch("https://dev-push.dengage.com/targetapi/onsite/public/survey/checkSurvey?AccountId=90db7e2a-5839-53cd-605f-9d3ffc328e21&SurveyId=".concat(typeformId, "&Company=").concat(uniqifyColumnValue)).then((function(response) {
                if (response.status === 200) {
                    return ''
                } else if (response.status === 404) {
                    return uniqifyColumnValue
                }
                return ''
            }
            )).catch((function(error) {
                return ''
            }
            ))
        }
        ))
    }
    var isInitialized$1 = false;
    var isMessagesReady = false;
    function start$2() {
        isInitialized$1 = true;
        var localMessages = localStorage.getItem('dengage_onsite_messages');
        if (localMessages) {
            localMessages = JSON.parse(localMessages);
            if (localMessages.length > 0) {
                saveLegacyMessages(localMessages).then((function() {
                    isMessagesReady = true;
                    localStorage.removeItem('dengage_onsite_messages')
                }
                ))
            } else {
                isMessagesReady = true;
                localStorage.removeItem('dengage_onsite_messages')
            }
        } else {
            isMessagesReady = true
        }
    }
    function saveLegacyMessages(newMessages) {
        return waitUntil((function() {
            return isInitialized$1
        }
        ), 1e3).then((function() {
            var ck = getContactKey();
            for (var i = 0; i < newMessages.length; i++) {
                var msg = newMessages[i];
                saveLegacyMessage({
                    id: msg.smsg_id,
                    contactKey: ck,
                    messageObj: convertLegacyMessage(msg)
                });
                if (msg.next_display_time) {
                    saveDisplayInfo({
                        id: msg.smsg_id,
                        contactKey: ck,
                        isRealtime: false,
                        lastDisplayTime: getDisplayTimeFromLegacyMessage(msg),
                        displayCount: 1
                    })
                }
            }
            return new Promise((function(resolve) {
                setTimeout(resolve, 1e3)
            }
            ))
        }
        ))
    }
    function getAllLegacyMessages() {
        return getAll$1('legacy_onsite.messages').then((function(messages) {
            return messages.map((function(m) {
                return m.messageObj
            }
            ))
        }
        ))
    }
    function getAllDisplayInfos() {
        return getAll$1('onsite_display_infos')
    }
    function getStoryVisitData(id) {
        return getById('story_set_visits', id)
    }
    function saveLegacyMessage(message) {
        return waitUntil((function() {
            return isInitialized$1 && isMessagesReady
        }
        ), 5e3).then((function() {
            var items = deepCopy(storage.get('legacy_onsite.messages')) || [];
            var ck = getContactKey();
            var updated = false;
            for (var i = 0; i < items.length; i++) {
                if (items[i].contactKey == ck && items[i].id == message.id) {
                    items[i].messageObj = message.messageObj;
                    updated = true;
                    break
                }
            }
            if (updated == false) {
                items.push(message)
            }
            storage.set('legacy_onsite.messages', items)
        }
        ))
    }
    function saveDisplayInfo(displayInfo) {
        return waitUntil((function() {
            return isInitialized$1 && isMessagesReady
        }
        ), 5e3).then((function() {
            var items = deepCopy(storage.get('onsite_display_infos')) || [];
            var ck = getContactKey();
            var value = {
                id: displayInfo.id,
                contactKey: getContactKey(),
                isRealtime: displayInfo.isRealtime || false,
                lastDisplayTime: displayInfo.lastDisplayTime,
                displayCount: displayInfo.displayCount || 1,
                isClicked: displayInfo.isClicked || false
            };
            var updated = false;
            for (var i = 0; i < items.length; i++) {
                if (items[i].contactKey == ck && items[i].id == displayInfo.id) {
                    Object.assign(items[i], value);
                    updated = true;
                    break
                }
            }
            if (updated == false) {
                items.push(value)
            }
            storage.set('onsite_display_infos', items)
        }
        ))
    }
    function saveStoryVisit(id, data) {
        return waitUntil((function() {
            return isInitialized$1 && isMessagesReady
        }
        ), 5e3).then((function() {
            var storySetVisits = deepCopy(storage.get('story_set_visits')) || {};
            storySetVisits[id] = data;
            storage.set('story_set_visits', storySetVisits)
        }
        ))
    }
    function deleteLegacyMessage(id) {
        return waitUntil((function() {
            return isInitialized$1 && isMessagesReady
        }
        ), 5e3).then((function() {
            var items = deepCopy(storage.get('legacy_onsite.messages')) || [];
            var ck = getContactKey();
            for (var i = 0; i < items.length; i++) {
                if (items[i].contactKey == ck && items[i].id == id) {
                    items.splice(i, 1);
                    break
                }
            }
            storage.set('legacy_onsite.messages', items)
        }
        ))
    }
    function getAll$1(storeName) {
        return waitUntil((function() {
            return isInitialized$1 && isMessagesReady
        }
        ), 5e3).then((function() {
            var items = storage.get(storeName);
            var ck = getContactKey();
            if (items) {
                return items.filter((function(i) {
                    return i.contactKey == ck
                }
                ))
            }
            return []
        }
        )).catch((function() {
            return []
        }
        ))
    }
    function getById(storeName, id) {
        return waitUntil((function() {
            return isInitialized$1 && isMessagesReady
        }
        ), 5e3).then((function() {
            var items = storage.get(storeName);
            var ck = getContactKey();
            if (Array.isArray(items)) {
                return items.find((function(i) {
                    return i.id == id && i.contactKey == ck
                }
                ))
            } else if (_typeof(items) === 'object') {
                return items[id] || null
            }
            return null
        }
        )).catch((function() {
            return null
        }
        ))
    }
    function StorySetRenderer(storySet, targetQuery, targetType, storyDisplayCallback, storyClickCallback) {
        var _this = this;
        _this.storySet = sortCovers(storySet);
        _this.headerTarget = document.querySelector(targetQuery);
        _this.headerCoverNodes = [];
        _this.coverNodes = [];
        _this.activeCoverIndex = 0;
        _this.activeStoryIndex = 0;
        _this.coverActiveStoryIndexes = [];
        _this.activeCubeProgressBar = null;
        _this.activeCarouselProgressBar = null;
        _this.storyTimer = null;
        _this.timerIsActive = false;
        _this.overlayIsOpen = false;
        _this.mobileOverlay = null;
        _this.cubeContainer = null;
        _this.cube = null;
        _this.cubeSurfaces = [];
        _this.desktopOverlay = null;
        _this.carouselWrapper = null;
        _this.carouselPrevButton = null;
        _this.carouselNextButton = null;
        _this.carouselOffset = 0;
        _this.carouselSlideWidth = 540;
        if (!_this.headerTarget) {
            console.warn('no valid target with ' + targetQuery);
            return
        }
        function windowWidth() {
            return window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
        }
        function windowHeight() {
            return window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
        }
        function activeCover() {
            return _this.storySet.covers[_this.activeCoverIndex]
        }
        function activeStory() {
            return activeCover().stories[_this.activeStoryIndex]
        }
        function coverCount() {
            return _this.storySet.covers.length || 0
        }
        function coverStoryCount(coverIndex) {
            return _this.storySet.covers[coverIndex].stories.length || 0
        }
        function visitedCovers() {
            return _this.storySet.covers.reduce((function(result, cover) {
                if (cover.isVisited) {
                    result.push(cover.id)
                }
                return result
            }
            ), [])
        }
        function activeHeaderCoverCoordinates(index) {
            var rect = _this.headerCoverNodes[index].getBoundingClientRect();
            return rect.x + 31 + 'px ' + (rect.y + 31) + 'px'
        }
        function mobileCloseButtonCoordinates() {
            var rect = _this.mobileOverlay.querySelector('.dnst-cube-current .dnst-banner-close').getBoundingClientRect();
            return {
                x: [rect.x - 5, rect.x + rect.width + 5],
                y: [rect.y - 5, rect.y + rect.height + 5]
            }
        }
        function mobileStoryLinkCoordinates() {
            var storyLink = _this.mobileOverlay.querySelector('.dnst-cube-current .dnst-story_active .dnst-cta');
            if (!storyLink) {
                return false
            }
            var rect = storyLink.getBoundingClientRect();
            return {
                x: [rect.x - 5, rect.x + rect.width + 5],
                y: [rect.y - 5, rect.y + rect.height + 5]
            }
        }
        function desktopStoryLinkCoordinates() {
            var storyLink = _this.desktopOverlay.querySelector('.dnst-banner_active .dnst-story_active .dnst-cta');
            if (!storyLink) {
                return false
            }
            var rect = storyLink.getBoundingClientRect();
            return {
                x: [rect.x - 5, rect.x + rect.width + 5],
                y: [rect.y - 5, rect.y + rect.height + 5]
            }
        }
        function desktopStoryPausePlayCoordinates() {
            var rect = _this.desktopOverlay.querySelector('.dnst-banner_active .dnst-banner-play:not(.dnst-banner-play_hidden), .dnst-banner_active .dnst-banner-pause:not(.dnst-banner-pause_hidden)').getBoundingClientRect();
            return {
                x: [rect.x - 2, rect.x + rect.width + 2],
                y: [rect.y - 2, rect.y + rect.height + 2]
            }
        }
        function activeCoverStoryNodes() {
            return toArray(_this.coverNodes[_this.activeCoverIndex].querySelectorAll('.dnst-story'))
        }
        function activeCoverProgressNodes() {
            return toArray(_this.coverNodes[_this.activeCoverIndex].querySelectorAll('.dnst-story-progress-fg'))
        }
        function isLastStory() {
            return _this.activeCoverIndex === coverCount() - 1 && _this.activeStoryIndex === coverStoryCount(_this.activeCoverIndex) - 1
        }
        function isFirstStory() {
            return _this.activeCoverIndex === 0 && _this.activeStoryIndex === 0
        }
        function Style(styling) {
            var headerTitle = styling.headerTitle || {};
            var headerCover = styling.headerCover || {};
            var story = styling.story || {};
            return createNode('style', {
                innerHTML: "\n      .dnst-header *,\n      .dnst-mobile-overlay * ,\n      .dnst-desktop-overlay * {\n        box-sizing: border-box;\n      }\n\n      .dnst-header button,\n      .dnst-mobile-overlay button,\n      .dnst-desktop-overlay button {\n        border: none;\n        background-color: transparent;\n        cursor: pointer;\n        padding: 0;\n      }\n\n      .dnst-header-theme {\n        --dnst-header-cover-size: ".concat(headerCover.size, "px;\n        --dnst-header-cover-gap: ").concat(headerCover.gap, "px;\n\n        --dnst-header-cover-name-size: ").concat(headerCover.fontSize, "px;\n        --dnst-header-cover-name-weight: ").concat(headerCover.fontWeight, ";\n        --dnst-header-cover-name-color: ").concat(headerCover.textColor, ";\n        \n        --dnst-header-cover-border-radius: ").concat(headerCover.borderRadius, ";\n        --dnst-header-cover-border-width: ").concat(headerCover.borderWidth, "px;\n        --dnst-header-cover-border-filler-width: calc(var(--dnst-header-cover-border-width) * 4 / 7);\n        --dnst-header-cover-border-line-width: calc(var(--dnst-header-cover-border-width) * 3 / 7);\n        \n        --dnst-header-cover-filler-gradient: ").concat(generateGradientValue(headerCover.fillerColors, headerCover.fillerAngle), ";\n        --dnst-header-cover-line-color: ").concat(headerCover.passiveColor, ";\n      }\n      .dnst-header {\n        width: 100%;\n        font-family: ").concat(styling.fontFamily, ";\n      }\n      \n      .dnst-title {\n        color: ").concat(headerTitle.textColor, ";\n        font-size: ").concat(headerTitle.fontSize, ";\n        font-weight: ").concat(headerTitle.fontWeight, ";\n        text-align: ").concat(headerTitle.textAlign, ";\n        margin-bottom: calc(var(--dnst-header-cover-gap) * 0.5);\n      }\n      .dnst-header-covers {\n        display: flex;\n        overflow-y: auto;\n        /* TODO: sliding effect */\n      }\n      .dnst-header-covers > *:not(:last-child) {\n        margin-right: var(--dnst-header-cover-gap);\n      }\n      .dnst-header-cover {\n        display: flex;\n        flex-direction: column;\n      }\n      .dnst-header-cover-img-container {\n        position: relative;\n        width: var(--dnst-header-cover-size);\n        height: var(--dnst-header-cover-size);\n        margin-bottom: calc(var(--dnst-header-cover-gap) * 0.5);\n        padding: var(--dnst-header-cover-border-filler-width);\n        border-radius: calc(var(--dnst-header-cover-border-radius));\n      }\n      .dnst-header-cover-img-container:before {\n        content: '';\n        position: absolute;\n        top: 0;\n        left: 0;\n        width: 100%;\n        height: 100%;\n        border-radius: calc(var(--dnst-header-cover-border-radius));\n        background-image: var(--dnst-header-cover-filler-gradient);\n        background-color: ").concat(headerCover.fillerColors[0], ";\n        background-position: 0% 0%;\n        background-size: 300% 300%;\n        z-index: -1;\n      }\n      .dnst-header-cover-img {\n        border: var(--dnst-header-cover-border-line-width) solid var(--dnst-header-cover-line-color);\n        width: 100%;\n        height: 100%;\n        object-fit: contain;\n        background-color: var(--dnst-header-cover-line-color);\n        border-radius: ").concat(headerCover.borderRadius === '50%' ? 'var(--dnst-header-cover-border-radius)' : 'calc(var(--dnst-header-cover-border-radius) - var(--dnst-header-cover-border-filler-width))', ";\n      }\n      .dnst-header-cover-name {\n        font-size: var(--dnst-header-cover-name-size);\n        font-weight: var(--dnst-header-cover-name-weight);\n        color: var(--dnst-header-cover-name-color);\n        text-align: center;\n      }\n      .dnst-header-cover_visited .dnst-header-cover-img-container {\n        background: #ffffff00;\n        border: var(--dnst-header-cover-border-line-width) solid var(--dnst-header-cover-line-color);\n      }\n      .dnst-header-cover_visited .dnst-header-cover-img-container:before {\n        display: none;\n      }\n      .dnst-header-cover_visited .dnst-header-cover-img {\n        border-width: 0;\n        padding: var(--dnst-header-cover-filler-width);\n        border-radius: ").concat(headerCover.borderRadius === '50%' ? 'var(--dnst-header-cover-border-radius)' : 'calc(var(--dnst-header-cover-border-radius) - var(--dnst-header-cover-border-border-width))', ";\n      }\n\n      .dnst-overlay-theme {\n        --dnst-mobile-overlay-background-color: ").concat(styling.mobileOverlayColor, ";\n        --dnst-desktop-overlay-background-color: ").concat(styling.desktopOverlayColor || '#1a1a1a', ";\n        \n        --dnst-cta-offset: ").concat(story.ctaOffset || 20, "px;\n\n        --dnst-cover-size: ").concat(headerCover.size * .5, "px;\n        --dnst-cover-gap: ").concat(headerCover.gap * .5, "px;\n\n        --dnst-cover-border-radius: ").concat(headerCover.borderRadius, ";\n        --dnst-cover-border-width: ").concat(headerCover.borderWidth, "px;\n        --dnst-cover-border-filler-width: calc(var(--dnst-cover-border-width) * 4 / 7);\n        --dnst-cover-border-line-width: calc(var(--dnst-cover-border-width) * 3 / 7);\n        \n        --dnst-cover-border-filler-gradient: ").concat(generateGradientValue(headerCover.fillerColors, headerCover.fillerAngle), ";\n        --dnst-cover-border-line-color: ").concat(headerCover.passiveColor, ";\n\n        --dnst-close-size: calc(0.5 * var(--dnst-cover-size));\n\n        --dnst-carousel-button-size: calc(0.6 * var(--dnst-cover-size));\n        --dnst-carousel-button-bg-color: #fff;\n        --dnst-carousel-button-fg-color: #1a1a1a;\n\n        --dnst-carousel-close-button-size: calc(1.25 * var(--dnst-cover-size));\n        --dnst-carousel-close-button-offset: 16px;\n\n\n        font-family: ").concat(styling.fontFamily, ";\n      }\n      .dnst-mobile-overlay {\n        display: none;\n        position: fixed;\n        background-color: var(--dnst-mobile-overlay-background-color);\n        top: 0;\n        left: 0;\n        width: 100vw;\n        height: var(--dnst-window-height, 100vh);\n        transform: scale(0);\n        transition: transform 0.2s linear, border-radius 0.2s linear;\n        border-radius: 50vw;\n        overflow: hidden;\n        z-index: 2047483647;\n      }\n      .dnst-mobile-overlay.dnst-mobile-overlay_active {\n        display: unset;\n      }\n      .dnst-mobile-overlay.dnst-mobile-overlay_grew {\n        transform: scale(1);\n        border-radius: 5px;\n      }\n      .dnst-mobile-overlay.dnst-mobile-overlay_shrinked {\n        transform: scale(0) !important;\n        border-radius: 50vw;\n      }\n\n      .dnst-cube-container {\n        perspective: 1000vw;\n        perspective-origin: 50% 50%;\n        width: 100%;\n        height: 100%;\n        transform: scale(0.95);\n      }\n      .dnst-cube {\n        position: relative;\n        width: 100%;\n        height: 100%;\n        transform-style: preserve-3d;\n        transform: rotateY(0deg);\n      }\n      .dnst-cube-surface {\n        width: 100%;\n        height: 100%;\n        position: absolute;\n        backface-visibility: hidden;\n        border-radius: 8px;\n      }\n      .dnst-cube-prev {\n        transform: rotateY(-90deg) translateZ(50vw);\n      }\n      .dnst-cube-current {\n        transform: rotateY(0deg) translateZ(50vw);\n      }\n      .dnst-cube-next {\n        transform: rotateY(90deg) translateZ(50vw);\n      }\n      .dnst-cube-prev .dnst-banner,\n      .dnst-cube-next .dnst-banner {\n        background-image: linear-gradient( 180deg, rgba(38, 38, 38, .6) 0%, rgba(38, 38, 38, 0) 100%, rgba(0, 0, 0, 1) );\n      }\n      .dnst-cube-prev .dnst-story-container,\n      .dnst-cube-next .dnst-story-container {\n        z-index: -1;\n      }\n\n      .dnst-desktop-overlay {\n        display: none;\n        position: fixed;\n        background-color: var(--dnst-desktop-overlay-background-color);\n        top: 0;\n        left: 0;\n        width: 100vw;\n        height: var(--dnst-window-height, 100vh);\n        overflow: hidden;\n        z-index: 2047483647;\n      }\n      .dnst-desktop-overlay_active {\n        display: unset;\n      }\n\n      .dnst-carousel-container {\n        position: relative;\n        width: 100%;\n        height: 100%;\n        display: flex;\n        justify-content: center;\n        align-items: center;\n      }\n      .dnst-carousel-wrapper {\n        display: flex;\n        flex-direction: column;\n        white-space: nowrap;\n        flex-wrap: wrap;\n        overflow: visible;\n        width: var(--dnst-carousel-active-slide-width, 540px);\n        height: var(--dnst-carousel-active-slide-height, 960px);\n      }\n\n      .dnst-carousel-close {\n        position: absolute;\n        top: var(--dnst-carousel-close-button-offset);\n        right: var(--dnst-carousel-close-button-offset);\n        width: var(--dnst-carousel-close-button-size);\n        height: var(--dnst-carousel-close-button-size);\n        z-index: 1;\n      }\n      .dnst-carousel-close svg path:nth-child(1) {\n        fill: var(--dnst-carousel-button-bg-color);\n        width: 100%;\n        height: 100%;\n      }\n\n      .dnst-carousel-next,\n      .dnst-carousel-prev {\n        position: absolute;\n        width: var(--dnst-carousel-button-size);\n        height: var(--dnst-carousel-button-size);\n        border-radius: 50%;\n        background-color: var(--dnst-carousel-button-bg-color) !important;\n        color: var(--dnst-carousel-button-fg-color);\n        z-index: 1;\n        display: flex;\n        justify-content: center;\n        align-items: center;\n        top: calc(50% - (var(--dnst-carousel-button-size) * 0.5));\n        opacity: .2;\n        transition: opacity 0.2s ease-in-out;\n      }\n      .dnst-carousel-next:hover,\n      .dnst-carousel-prev:hover {\n        opacity: 1;\n      }\n      .dnst-carousel-next.dnst-carousel-arrow_hidden,\n      .dnst-carousel-prev.dnst-carousel-arrow_hidden {\n        display: none !important;\n      }\n      .dnst-carousel-next svg,\n      .dnst-carousel-prev svg {\n        color: var(--dnst-carousel-button-fg-color);\n        width: 100%;\n        height: 100%;\n        margin-left: -3px;\n      }\n\n      .dnst-carousel-prev {\n        left: calc(50% - (var(--dnst-carousel-active-slide-width) * 0.5 ) - (var(--dnst-carousel-button-size) * 1.5));\n      }\n      .dnst-carousel-next {\n        transform-origin: center;\n        transform: rotate(180deg);\n        right: calc(50% - (var(--dnst-carousel-active-slide-width) * 0.5 ) - (var(--dnst-carousel-button-size) * 1.5));\n      }\n\n      .dnst-banner {\n        position: relative;\n        width: 100%;\n        height: 100%;\n        flex-grow: 1;\n        border-radius: 8px;\n        transition: background-image 0.2s ease;\n      }\n      .dnst-carousel-wrapper .dnst-banner {\n        transform: scale(0.4);\n        transition: transform 0.2s ease;\n        transform-origin: center;\n        border-radius: 8px;\n      }\n      \n      .dnst-carousel-wrapper .dnst-banner_active {\n        transform: scale(1);\n      }\n      \n      .dnst-banner-header {\n        position: absolute;\n        top: 0;\n        left: 0;\n        width: 100%;\n        z-index: 1;\n        display: flex;\n        flex-direction: column;\n        padding-bottom: 5%;\n        border-radius: 8px 8px 0 0;\n        background-image: linear-gradient(180deg, rgba(38, 38, 38, .8) 0%, rgba(38, 38, 38, 0) 100%);\n      }\n\n      .dnst-story-progress-container {\n        display: flex;\n        padding: 6px;\n        gap: 2px;\n        border-radius: 8px 8px 0 0;\n      }\n      .dnst-desktop-overlay .dnst-story-progress-container {\n        padding: 20px 16px 12px;\n        gap: 2px;\n      }\n      .dnst-story-progress-bg {\n        position: relative;\n        background-color: rgba(0, 0, 0, 0.3);\n        height: 3px;\n        border-radius: 1px;\n        flex: 1;\n      }\n      .dnst-story-progress-fg {\n        position: absolute;\n        top: 0;\n        left: 0;\n        height: 3px;\n        border-radius: 1px;\n        width: 0;\n        background-color: #fff;\n      }\n      @keyframes progress-bar-loading {\n        0% {\n          width: 0;\n        }\n        100% {\n          width: 100%\n        }\n      }\n      .dnst-story-progress-fg_active {\n        animation: progress-bar-loading linear 10s 1 paused;\n      }\n      .dnst-story-progress-fg_seen {\n        width: 100%\n      }\n\n      .dnst-banner-cover {\n        display: flex;\n        align-items: center;\n        padding: 0 6px;\n      }\n      .dnst-desktop-overlay .dnst-banner-cover {\n        padding: 0 16px;\n        gap: 2px;\n      }\n      .dnst-banner-cover-img-container {\n        width: var(--dnst-cover-size);\n        height: var(--dnst-cover-size);\n        margin-right: var(--dnst-cover-gap);\n        border-radius: 50%;\n      }\n      .dnst-banner-cover-img {\n        width: 100%;\n        height: 100%;\n        border-radius: 50%;\n      }\n      .dnst-banner-cover-name {\n        flex: 1;\n        color: #fff;\n      }\n      .dnst-banner-pause,\n      .dnst-banner-play {\n        width: calc( 0.5 * var(--dnst-cover-size));\n        height: calc( 0.5 * var(--dnst-cover-size));\n        color: #fff;\n      }\n      .dnst-banner-pause_hidden,\n      .dnst-banner-play_hidden {\n        display: none;\n      }\n      .dnst-banner-pause svg,\n      .dnst-banner-play svg {\n        width: 100%;\n        height: 100%;\n      }\n      .dnst-banner-close {\n        position: relative;\n        width: calc( 0.5 * var(--dnst-cover-size));\n        height: calc( 0.5 * var(--dnst-cover-size));\n      }\n      .dnst-banner-close svg {\n        fill: #fff;\n      }\n      .dnst-desktop-overlay .dnst-banner-close {\n        display: none !important;\n      }\n      .dnst-mobile-overlay .dnst-banner-pause,\n      .dnst-mobile-overlay .dnst-banner-play {\n        display: none !important;\n      }\n      \n      .dnst-story-container {\n        position: absolute;\n        top: 0;\n        left: 0;\n        width: 100%;\n        height: 100%;\n        border-radius: 8px;\n      }\n      \n      .dnst-story-banner-img-container {\n        display: flex;\n        justify-content: center;\n        align-items: center;\n        width: 100%;\n        height: 100%;\n        border-radius: 8px;\n      }\n      .dnst-story-banner-img {\n        max-width: 100%;\n        max-height: 100%;\n        border-radius: 8px;\n      }\n\n      .dnst-story {\n        display: none;\n        width: 100%;\n        height: 100%;\n      }\n      .dnst-story_active {\n        display: unset;\n      }\n\n      .dnst-cta-container {\n        position: absolute;\n        left: 0;\n        bottom: 0;\n        width: 100%;\n        padding: 10% var(--dnst-cta-offset) var(--dnst-cta-offset);\n        border-radius: 0 0 8px 8px;\n        display: flex;\n        justify-content: center;\n        align-items: center;\n        background-image: linear-gradient( 180deg, rgba(38, 38, 38, 0) 0%, rgba(38, 38, 38, .6) 100% )\n      }\n      \n      .dnst-cta {\n        padding: 8px 12px;\n        border-radius: 8px;\n        text-align: center;\n        cursor: pointer;\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-story-progress-container,\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-play,\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-pause,\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-cta {\n        display: none !important;\n      }\n\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-header {\n        height: 100%;\n      }\n\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover {\n        width: 100%;\n        height: 100%;\n        justify-content: center;\n        align-items: center;\n        flex-direction: column;\n      }\n\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover-img-container {\n        width: calc(var(--dnst-cover-size) * 5);\n        height: calc(var(--dnst-cover-size) * 5);\n        margin-bottom: calc(var(--dnst-cover-gap) * 2.5);\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover-img-container {\n        position: relative;\n        padding: calc(var(--dnst-cover-border-filler-width) * 2.5);\n        border-radius: calc(var(--dnst-cover-border-radius) * 2.5);\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover-img-container:before {\n        content: '';\n        position: absolute;\n        top: 0;\n        left: 0;\n        width: 100%;\n        height: 100%;\n        border-radius: calc(var(--dnst-cover-border-radius) * 2.5);\n        background-image: var(--dnst-cover-border-filler-gradient);\n        background-position: 0% 0%;\n        background-size: 300% 300%;\n        z-index: -1;\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover-img {\n        border: calc(var(--dnst-cover-border-line-width) * 2.5) solid var(--dnst-cover-border-line-color);\n        width: 100%;\n        height: 100%;\n        object-fit: contain;\n        background-color: var(--dnst-cover-border-line-color);\n        border-radius: calc((var(--dnst-cover-border-radius) - var(--dnst-cover-border-filler-width)) * 2.5);\n      }\n\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover_visited .dnst-banner-cover-img-container {\n        background: #ffffff00;\n        border: var(--dnst-cover-border-line-width) solid var(--dnst-cover-line-color);\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover_visited .dnst-banner-cover-img-container:before {\n        display: none;\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover_visited .dnst-banner-cover-img {\n        border-width: 0;\n        padding: var(--dnst-cover-border-filler-width);\n        border-radius: calc((var(--dnst-cover-border-radius) - var(--dnst-cover-border-width)) * 2.5);\n      }\n\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-banner-cover-name {\n        flex: 0;\n        font-size: 40px;\n        color: #fff;\n      }\n      .dnst-desktop-overlay .dnst-banner:not(.dnst-banner_active) .dnst-story-container {\n        background-image: linear-gradient( 180deg, rgba(38, 38, 38, .6) 0%, rgba(38, 38, 38, 0) 100%, rgba(0, 0, 0, 1) );\n      }\n\n\n      @media screen and (max-width: 481px) {\n        .dnst-desktop-overlay {\n          display: none !important;\n        }\n      }\n      @media screen and (min-width: 480px) {\n        .dnst-mobile-overlay {\n          display: none !important;\n        }\n      }\n      ")
            })
        }
        function Header(storySetId, title) {
            return createNode('div', {
                className: 'dnst-header dnst-header-theme',
                dataset: {
                    dnStorySetId: storySetId
                },
                innerHTML: "\n        ".concat(title ? '<div class="dnst-title">' + title + '</div>' : '', "\n        <div class=\"dnst-header-covers\"></div>\n        ")
            })
        }
        function HeaderCover(data, coverIndex) {
            return createNode('div', {
                className: 'dnst-header-cover' + (data.isVisited && ' dnst-header-cover_visited' || ''),
                dataset: {
                    dnstCoverIndex: coverIndex,
                    dnstCoverId: data.id
                },
                innerHTML: "\n        <div class=\"dnst-header-cover-img-container\">\n          <img class=\"dnst-header-cover-img\" src=\"".concat(data.imgUrl, "\" alt=\"\">\n        </div>\n        <div class=\"dnst-header-cover-name\">").concat(data.name, "</div>\n        ")
            }, [{
                event: 'click',
                callback: function callback(event) {
                    openOverlay(coverIndex)
                }
            }])
        }
        function MobileOverlay(storySetId) {
            return createNode('div', {
                className: 'dnst-mobile-overlay dnst-overlay-theme',
                dataset: {
                    dnStorySetId: storySetId
                },
                innerHTML: "\n        <div class=\"dnst-cube-container\">\n          <div class=\"dnst-cube\">\n            <div class=\"dnst-cube-surface dnst-cube-prev\"></div>\n            <div class=\"dnst-cube-surface dnst-cube-current\"></div>\n            <div class=\"dnst-cube-surface dnst-cube-next\"></div>\n          </div>\n        </div>\n        "
            }, [{
                event: 'touchstart',
                callback: handleDragStart,
                options: {
                    passive: false
                }
            }, {
                event: 'mousedown',
                callback: handleDragStart,
                options: {
                    passive: false
                }
            }, {
                event: 'touchmove',
                callback: handleDragMove,
                options: {
                    passive: false
                }
            }, {
                event: 'mousemove',
                callback: handleDragMove,
                options: {
                    passive: false
                }
            }, {
                event: 'touchend',
                callback: handleDragEnd,
                options: {
                    passive: false
                }
            }, {
                event: 'touchcancel',
                callback: handleDragEnd,
                options: {
                    passive: false
                }
            }, {
                event: 'mouseup',
                callback: handleDragEnd,
                options: {
                    passive: false
                }
            }, {
                event: 'scroll',
                callback: preventDefault,
                options: {
                    passive: false
                }
            }])
        }
        function DesktopOverlay(storySetId) {
            return createNode('div', {
                className: 'dnst-desktop-overlay dnst-overlay-theme',
                dataset: {
                    dnStorySetId: storySetId
                },
                innerHTML: "\n        <div class=\"dnst-carousel-container\">\n          <button type=\"button\" class=\"dnst-carousel-close\">\n            <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 48 48\">\n              <path d=\"M38 12.83l-2.83-2.83-11.17 11.17-11.17-11.17-2.83 2.83 11.17 11.17-11.17 11.17 2.83 2.83 11.17-11.17 11.17 11.17 2.83-2.83-11.17-11.17z\"/>\n              <path d=\"M0 0h48v48h-48z\" fill=\"none\"/>\n            </svg>\n          </button>\n          <button type=\"button\" class=\"dnst-carousel-prev\">\n            <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">\n              <polyline points=\"15 18 9 12 15 6\"/>\n            </svg>\n          </button>\n          <button type=\"button\" class=\"dnst-carousel-next\">\n            <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">\n              <polyline points=\"15 18 9 12 15 6\"/>\n            </svg>\n          </button>\n          <div class=\"dnst-carousel-wrapper\">\n          </div>\n        </div>\n        "
            })
        }
        function Cover(data, coverIndex) {
            var coverNode = createNode('div', {
                className: 'dnst-banner',
                dataset: {
                    dnstCoverId: data.id
                },
                innerHTML: "\n        <div class=\"dnst-banner-header\">\n          <div class=\"dnst-story-progress-container\">\n          </div>\n          <div class=\"dnst-banner-cover".concat(data.isVisited && ' dnst-banner-cover_visited' || '', "\" data-dnst-cover-index=\"").concat(coverIndex, "\">\n            <div class=\"dnst-banner-cover-img-container\">\n              <img class=\"dnst-banner-cover-img\" src=\"").concat(data.imgUrl, "\" alt=\"\">\n            </div>\n            <div class=\"dnst-banner-cover-name\">").concat(data.name, "</div>\n            <button type=\"button\" class=\"dnst-banner-pause\">\n              <svg  xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 20 20\">\n                <g fill=\"currentColor\"><title>pause</title>\n                <rect width=\"6\" height=\"16\" x=\"3\" y=\"2\" rx=\"1\" ry=\"1\"/>\n                <rect width=\"6\" height=\"16\" x=\"11\" y=\"2\" rx=\"1\" ry=\"1\"/>\n                </g>\n              </svg>\n            </button>\n            <button type=\"button\" class=\"dnst-banner-play dnst-banner-play_hidden\">\n              <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"60\" height=\"67\" viewBox=\"0 0 60 67\">\n                <g>\n                  <path fill=\"currentColor\" stroke=\"none\" d=\"M 5.976074 66.314453 C 6.822388 66.314453 7.628052 66.167969 8.393066 65.875 C 9.158081 65.582031 9.947388 65.191406 10.76123 64.703125 L 54.706543 39.410156 C 56.496948 38.36853 57.733887 37.448853 58.41748 36.651367 C 59.101074 35.853882 59.442871 34.901733 59.442871 33.794922 C 59.442871 32.68811 59.101074 31.735962 58.41748 30.938477 C 57.733887 30.140991 56.496948 29.221313 54.706543 28.179688 L 10.76123 2.886719 C 9.947388 2.398438 9.158081 2.007813 8.393066 1.714844 C 7.628052 1.421875 6.822388 1.275391 5.976074 1.275391 C 4.446167 1.275391 3.233521 1.820679 2.338379 2.911133 C 1.443237 4.001587 0.995605 5.458374 0.995605 7.28125 L 0.995605 60.308594 C 0.995605 62.13147 1.443237 63.588257 2.338379 64.678711 C 3.233521 65.769165 4.446167 66.314453 5.976074 66.314453 Z\"/>\n                </g>\n              </svg>\n            </button>\n            <button type=\"button\" class=\"dnst-banner-close\">\n              <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 48 48\">\n                <path d=\"M38 12.83l-2.83-2.83-11.17 11.17-11.17-11.17-2.83 2.83 11.17 11.17-11.17 11.17 2.83 2.83 11.17-11.17 11.17 11.17 2.83-2.83-11.17-11.17z\"/>\n                <path d=\"M0 0h48v48h-48z\" fill=\"none\"/>\n              </svg>\n            </button>\n          </div>\n        </div>\n        <div class=\"dnst-story-container\">\n        </div>\n        ")
            });
            var progressContainer = coverNode.querySelector('.dnst-story-progress-container');
            var storyContainer = coverNode.querySelector('.dnst-story-container');
            var playButton = coverNode.querySelector('.dnst-banner-play');
            playButton.addEventListener('click', (function() {
                togglePlayPauseButtons(true)
            }
            ));
            var pauseButton = coverNode.querySelector('.dnst-banner-pause');
            pauseButton.addEventListener('click', (function() {
                togglePlayPauseButtons(false)
            }
            ));
            for (var i = 0; i < data.stories.length; i++) {
                insertNode(progressContainer, ProgressBar(i));
                insertNode(storyContainer, StoryBanner(data.stories[i], i))
            }
            return coverNode
        }
        function StoryBanner(data, storyIndex) {
            var cta = data.cta;
            var ctaHtml = cta && cta.link && "\n    <div class=\"dnst-cta-container\">\n      <div\n        href=\"".concat(cta.link, "\"\n        target=\"_blank\"\n        class=\"dnst-cta\"\n        style=\"background-color:").concat(cta.bgColor, ";color:").concat(cta.textColor, ";\"\n      >\n        ").concat(cta.label, "\n      </div>\n    </div>\n    ") || '';
            var bgStyle = data.bgColors.length > 1 ? "background-image:".concat(generateGradientValue(data.bgColors), ";") : '';
            return createNode('div', {
                className: 'dnst-story' + (storyIndex === 0 && ' dnst-story_active' || ''),
                dataset: {
                    dnstStoryIndex: storyIndex
                },
                innerHTML: "\n        <div class=\"dnst-story-banner-img-container\" style=\"".concat(bgStyle, "background-color: ").concat(data.bgColors[0], "\">\n          <img class=\"dnst-story-banner-img\" src=\"").concat(data.mediaUrl, "\"  alt=\"\">\n        </div>\n        ").concat(ctaHtml, "\n        ")
            })
        }
        function ProgressBar(storyIndex) {
            return createNode('div', {
                className: 'dnst-story-progress-bg',
                innerHTML: "<div class=\"dnst-story-progress-fg\" data-dnst-progress-index=\"".concat(storyIndex, "\"></div>")
            })
        }
        function sortCovers(storySet) {
            storySet = JSON.parse(JSON.stringify(storySet));
            storySet.covers = storySet.covers.map((function(cover, coverIndex) {
                cover.originalOrder = coverIndex;
                return cover
            }
            )).sort((function(a, b) {
                var visitedCompare = a.isVisited - b.isVisited;
                if (visitedCompare !== 0) {
                    return visitedCompare
                }
                return a.originalOrder - b.originalOrder
            }
            ));
            return storySet
        }
        function create(storySet) {
            var storySetId = storySet.id;
            var header = Header(storySetId, storySet.title);
            var headerCoverContainer = header.querySelector('.dnst-header-covers');
            _this.mobileOverlay = MobileOverlay(storySetId);
            _this.cubeContainer = _this.mobileOverlay.querySelector('.dnst-cube-container');
            _this.cube = _this.mobileOverlay.querySelector('.dnst-cube');
            _this.cubeSurfaces.push(_this.cube.querySelector('.dnst-cube-prev'));
            _this.cubeSurfaces.push(_this.cube.querySelector('.dnst-cube-current'));
            _this.cubeSurfaces.push(_this.cube.querySelector('.dnst-cube-next'));
            _this.desktopOverlay = DesktopOverlay(storySetId);
            _this.carouselWrapper = _this.desktopOverlay.querySelector('.dnst-carousel-wrapper');
            for (var i = 0; i < coverCount(); i++) {
                var coverData = storySet.covers[i];
                var headerCoverNode = HeaderCover(coverData, i);
                insertNode(headerCoverContainer, headerCoverNode);
                _this.headerCoverNodes.push(headerCoverNode);
                var coverNode = Cover(coverData, i);
                _this.coverActiveStoryIndexes.push(0);
                _this.coverNodes.push(coverNode);
                var carouselCoverNode = coverNode.cloneNode(true);
                carouselCoverNode.addEventListener('mousedown', handleCarouselSlideMousedown);
                carouselCoverNode.addEventListener('touchstart', handleCarouselSlideMousedown);
                carouselCoverNode.addEventListener('touchend', handleCarouselSlideMouseup);
                carouselCoverNode.addEventListener('touchcancel', handleCarouselSlideMouseup);
                carouselCoverNode.addEventListener('mouseup', handleCarouselSlideMouseup);
                insertNode(_this.carouselWrapper, carouselCoverNode)
            }
            insertNode(document.head, Style(storySet.styling));
            insertNode(_this.headerTarget, header, targetType);
            insertNode(document.body, _this.mobileOverlay);
            insertNode(document.body, _this.desktopOverlay);
            setActiveCarouselSlide(0);
            setCubeSurfaces(0);
            setRootCssVariables();
            window.addEventListener('resize', (function() {
                setRootCssVariables();
                changeCarouselPosition(_this.activeCoverIndex)
            }
            ), false);
            var carouselCloseButton = _this.desktopOverlay.querySelector('.dnst-carousel-close');
            carouselCloseButton.addEventListener('click', (function() {
                closeOverlay(_this.activeCoverIndex)
            }
            ));
            _this.carouselPrevButton = _this.desktopOverlay.querySelector('.dnst-carousel-prev');
            _this.carouselPrevButton.addEventListener('click', (function() {
                carouselNavigationClicked(false)
            }
            ));
            _this.carouselNextButton = _this.desktopOverlay.querySelector('.dnst-carousel-next');
            _this.carouselNextButton.addEventListener('click', (function() {
                carouselNavigationClicked(true)
            }
            ));
            window.addEventListener('keyup', (function(event) {
                if (!_this.overlayIsOpen) {
                    return
                }
                event.stopPropagation();
                event.preventDefault();
                var keyCode = event.code;
                switch (keyCode) {
                case 'ArrowLeft':
                    carouselNavigationClicked(false);
                    break;
                case 'ArrowRight':
                    carouselNavigationClicked(true);
                    break;
                case 'Space':
                    if (_this.timerIsActive) {
                        pauseTimer()
                    } else {
                        resumeTimer()
                    }
                    break;
                case 'Escape':
                    closeOverlay(_this.activeCoverIndex);
                    break
                }
            }
            ))
        }
        function openOverlay(coverIndex) {
            setActiveCover(coverIndex);
            animateMobileOverlay(true, coverIndex);
            toggleDesktopOverlay(true);
            _this.overlayIsOpen = true
        }
        function closeOverlay(coverIndex) {
            animateMobileOverlay(false, coverIndex);
            toggleDesktopOverlay(false);
            pauseTimer();
            _this.overlayIsOpen = false
        }
        function setActiveCover(nextActiveCoverIndex, startingStoryIndex) {
            var lastActiveCoverIndex = _this.activeCoverIndex;
            if (_this.overlayIsOpen) {
                if (lastActiveCoverIndex === nextActiveCoverIndex) {
                    return
                }
                if (nextActiveCoverIndex >= coverCount() || nextActiveCoverIndex <= -1) {
                    closeOverlay(lastActiveCoverIndex);
                    return
                }
            }
            _this.activeCoverIndex = nextActiveCoverIndex;
            _this.storySet.covers[_this.activeCoverIndex].isVisited = true;
            saveStoryVisit(_this.storySet.id, visitedCovers());
            var headerCoverContainers = document.querySelectorAll(".dnst-header-cover[data-dnst-cover-index=\"".concat(_this.activeCoverIndex, "\"]"));
            for (var i = 0; i < headerCoverContainers.length; i++) {
                headerCoverContainers[i].classList.add('dnst-header-cover_visited')
            }
            var bannerCoverContainers = document.querySelectorAll(".dnst-banner-cover[data-dnst-cover-index=\"".concat(_this.activeCoverIndex, "\"]"));
            for (var i = 0; i < bannerCoverContainers.length; i++) {
                bannerCoverContainers[i].classList.add('dnst-banner-cover_visited')
            }
            _this.carouselPrevButton.classList[isFirstStory() ? 'add' : 'remove']('dnst-carousel-arrow_hidden');
            _this.carouselNextButton.classList[isLastStory() ? 'add' : 'remove']('dnst-carousel-arrow_hidden');
            var changeValue = nextActiveCoverIndex - lastActiveCoverIndex;
            var startingStoryIndex = _this.coverActiveStoryIndexes[nextActiveCoverIndex];
            saveStoryVisit();
            setActiveCarouselSlide(nextActiveCoverIndex);
            if (!changeValue) {
                rotateCube(0);
                setActiveStory(startingStoryIndex)
            } else {
                toggleCubeTransition(true);
                rotateCube(changeValue * -90);
                setTimeout((function() {
                    setCubeSurfaces(nextActiveCoverIndex);
                    setActiveStory(startingStoryIndex);
                    toggleCubeTransition(false);
                    rotateCube(0);
                    isRotating = false
                }
                ), rotationDuration)
            }
        }
        function setActiveStory(activeStoryIndex) {
            var storyCount = coverStoryCount(_this.activeCoverIndex);
            if (activeStoryIndex >= storyCount) {
                setActiveCover(_this.activeCoverIndex + 1);
                return
            }
            if (activeStoryIndex <= -1) {
                setActiveCover(_this.activeCoverIndex - 1);
                return
            }
            _this.activeStoryIndex = activeStoryIndex;
            _this.coverActiveStoryIndexes[_this.activeCoverIndex] = activeStoryIndex;
            _this.onStoryDisplay(activeCover(), activeStory());
            _this.carouselPrevButton.classList[isFirstStory() ? 'add' : 'remove']('dnst-carousel-arrow_hidden');
            _this.carouselNextButton.classList[isLastStory() ? 'add' : 'remove']('dnst-carousel-arrow_hidden');
            var allStoryProgressBars = document.querySelectorAll('.dnst-story-progress-fg');
            for (var i = 0; i < allStoryProgressBars.length; i++) {
                allStoryProgressBars[i].classList.remove('dnst-story-progress-fg_active')
            }
            var storyNodes = activeCoverStoryNodes().concat(toArray(_this.cubeSurfaces[1].querySelectorAll('.dnst-story'))).concat(toArray(_this.carouselWrapper.querySelectorAll('.dnst-banner_active .dnst-story')));
            var progressNodes = activeCoverProgressNodes().concat(toArray(_this.cubeSurfaces[1].querySelectorAll('.dnst-story-progress-fg'))).concat(toArray(_this.carouselWrapper.querySelectorAll('.dnst-banner_active .dnst-story-progress-fg')));
            for (var i = 0; i < storyNodes.length; i++) {
                var storyNode = storyNodes[i];
                var progressNode = progressNodes[i];
                var storyNodeIndex = parseInt(storyNode.dataset.dnstStoryIndex);
                var progressNodeIndex = parseInt(progressNode.dataset.dnstProgressIndex);
                if (storyNodeIndex < activeStoryIndex) {
                    storyNode.classList.remove('dnst-story_active')
                } else if (storyNodeIndex === activeStoryIndex) {
                    storyNode.classList.add('dnst-story_active')
                } else {
                    storyNode.classList.remove('dnst-story_active')
                }
                if (progressNodeIndex < activeStoryIndex) {
                    progressNode.classList.remove('dnst-story-progress-fg_active');
                    progressNode.classList.add('dnst-story-progress-fg_seen')
                } else if (progressNodeIndex === activeStoryIndex) {
                    progressNode.classList.remove('dnst-story-progress-fg_seen');
                    progressNode.classList.remove('dnst-story-progress-fg_active');
                    progressNode.classList.add('dnst-story-progress-fg_active')
                } else {
                    progressNode.classList.remove('dnst-story-progress-fg_active');
                    progressNode.classList.remove('dnst-story-progress-fg_seen')
                }
            }
            startTimer((function() {
                setActiveStory(activeStoryIndex + 1)
            }
            ))
        }
        function toggleProgressBarAnimation(isRunning) {
            var activeProgressBars = document.querySelectorAll('.dnst-story-progress-fg_active');
            for (var i = 0; i < activeProgressBars.length; i++) {
                activeProgressBars[i].style.animationPlayState = isRunning ? 'running' : 'paused'
            }
        }
        function togglePlayPauseButtons(isPlay) {
            var playButton = _this.desktopOverlay.querySelector('.dnst-banner_active .dnst-banner-play');
            var pauseButton = _this.desktopOverlay.querySelector('.dnst-banner_active .dnst-banner-pause');
            if (playButton) {
                playButton.classList[isPlay ? 'add' : 'remove']('dnst-banner-play_hidden')
            }
            if (pauseButton) {
                pauseButton.classList[isPlay ? 'remove' : 'add']('dnst-banner-pause_hidden')
            }
        }
        function startTimer(timerFunc) {
            _this.timerIsActive = true;
            if (_this.storyTimer) {
                _this.storyTimer.pause()
            }
            _this.storyTimer = new Timer(timerFunc,1e4);
            toggleProgressBarAnimation(true);
            togglePlayPauseButtons(true)
        }
        function pauseTimer() {
            _this.timerIsActive = false;
            if (_this.storyTimer) {
                _this.storyTimer.pause()
            }
            toggleProgressBarAnimation(false);
            togglePlayPauseButtons(false)
        }
        function resumeTimer() {
            _this.timerIsActive = true;
            if (_this.storyTimer) {
                _this.storyTimer.resume()
            }
            toggleProgressBarAnimation(true);
            togglePlayPauseButtons(true)
        }
        function linkClick(story) {
            _this.onStoryClick(activeCover(), story);
            window.open(story.cta.link, story.cta.target)
        }
        function animateMobileOverlay(isOpen, originIndex) {
            _this.mobileOverlay.style.transformOrigin = activeHeaderCoverCoordinates(originIndex);
            if (isOpen) {
                _this.mobileOverlay.classList.add('dnst-mobile-overlay_active');
                setTimeout((function() {
                    _this.mobileOverlay.classList.add('dnst-mobile-overlay_grew')
                }
                ), 1)
            } else {
                _this.mobileOverlay.classList.add('dnst-mobile-overlay_shrinked');
                setTimeout((function() {
                    _this.mobileOverlay.classList.remove('dnst-mobile-overlay_grew');
                    _this.mobileOverlay.classList.remove('dnst-mobile-overlay_active');
                    _this.mobileOverlay.classList.remove('dnst-mobile-overlay_shrinked')
                }
                ), 200)
            }
        }
        function setCubeSurfaces(coverIndex) {
            var coverIndexes = [coverIndex - 1, coverIndex, coverIndex + 1];
            for (var i = 0; i < _this.cubeSurfaces.length; i++) {
                var cubeSurface = _this.cubeSurfaces[i];
                cubeSurface.innerHTML = '';
                var cover = _this.coverNodes[coverIndexes[i]];
                if (cover) {
                    insertNode(cubeSurface, cover.cloneNode(true))
                }
            }
        }
        var cubeTransitionIsActive = false
          , rotationValue = 0
          , rotationDuration = 200
          , isRotating = false;
        function toggleCubeTransition(isActive) {
            if (cubeTransitionIsActive === isActive) {
                return
            }
            cubeTransitionIsActive = isActive;
            var transitionValue = (isActive ? rotationDuration : 0) + "ms transform ease";
            _this.cubeContainer.style.transition = transitionValue;
            _this.cube.style.transition = transitionValue
        }
        function rotateCube(value) {
            rotationValue = value;
            _this.cube.style.transform = "rotateY(" + value + "deg)";
            _this.cubeContainer.style.transform = "scale(" + (.925 + Math.abs(Math.abs(value) - 45) / 45 * .025) + ")"
        }
        function resetCube() {
            toggleCubeTransition(true);
            rotateCube(0);
            setTimeout((function() {
                toggleCubeTransition(false);
                resumeTimer()
            }
            ), rotationDuration)
        }
        var isDragging = false
          , isMoving = false
          , touchstartX = 0
          , touchstartY = 0
          , touchstartT = 0
          , toucmoveX = 0;
        function handleDragStart(event) {
            event.preventDefault();
            event.stopPropagation();
            if (isRotating) {
                return
            }
            isDragging = true;
            touchstartX = event.clientX || event.touches[0].clientX;
            touchstartY = event.clientY || event.touches[0].clientY;
            touchstartT = performance.now();
            pauseTimer()
        }
        function handleDragMove(event) {
            event.preventDefault();
            event.stopPropagation();
            if (!isDragging || isRotating) {
                return
            }
            isMoving = true;
            toggleCubeTransition(false);
            toucmoveX = event.clientX || event.touches[0].clientX;
            var movingDeltaX = touchstartX - toucmoveX;
            var movingRotationValue = -90 * movingDeltaX / windowWidth();
            if (_this.activeCoverIndex === 0 && movingDeltaX < 0 || _this.activeCoverIndex === coverCount() - 1 && movingDeltaX > 0) {
                rotateCube(Math.min(10, Math.max(movingRotationValue, -10)));
                return
            }
            if (Math.abs(movingDeltaX) <= windowWidth()) {
                rotateCube(movingRotationValue)
            } else {
                setActiveCover(_this.activeCoverIndex + Math.sign(movingDeltaX));
                isDragging = false;
                isMoving = false
            }
        }
        function handleDragEnd(event) {
            event.preventDefault();
            event.stopPropagation();
            if (!isDragging || isRotating) {
                return
            }
            var touchendX = event.clientX || event.changedTouches[0].clientX;
            var deltaX = touchstartX - touchendX;
            var touchendY = event.clientY || event.changedTouches[0].clientY;
            var deltaY = touchstartY - touchendY;
            var deltaT = performance.now() - touchstartT;
            if (isMoving) {
                if (Math.abs(rotationValue) > 9) {
                    setActiveCover(_this.activeCoverIndex + Math.sign(deltaX))
                } else {
                    resetCube()
                }
                isMoving = false
            } else if (Math.abs(deltaY) < 5 && Math.abs(deltaX) < 5 && deltaT < 350) {
                handleMobileClick(event)
            } else {
                resetCube()
            }
            isDragging = false
        }
        function handleMobileClick(event) {
            if (!_this.overlayIsOpen || isRotating) {
                return
            }
            var clickX = event.clientX || event.changedTouches[0].clientX;
            var clickY = event.clientY || event.changedTouches[0].clientY;
            var closeButtonCoordinates = mobileCloseButtonCoordinates();
            if (clickX > closeButtonCoordinates.x[0] && clickX < closeButtonCoordinates.x[1] && clickY > closeButtonCoordinates.y[0] && clickY < closeButtonCoordinates.y[1]) {
                closeOverlay(_this.activeCoverIndex);
                return
            }
            var linkCoordinates = mobileStoryLinkCoordinates();
            if (linkCoordinates && clickX > linkCoordinates.x[0] && clickX < linkCoordinates.x[1] && clickY > linkCoordinates.y[0] && clickY < linkCoordinates.y[1]) {
                linkClick(activeStory());
                closeOverlay(_this.activeCoverIndex);
                return
            }
            setActiveStory(_this.activeStoryIndex + (clickX > windowWidth() * .2 ? 1 : -1))
        }
        function toggleDesktopOverlay(isOpen) {
            _this.desktopOverlay.classList[isOpen ? 'add' : 'remove']('dnst-desktop-overlay_active')
        }
        function carouselNavigationClicked(isNext) {
            pauseTimer();
            setActiveStory(_this.activeStoryIndex + (isNext ? 1 : -1))
        }
        var isMousedown = false
          , isNonClick = false
          , mousedownX = 0
          , mousedownY = 0
          , mouseupX = 0
          , mouseupY = 0
          , mousedownT = 0;
        function handleCarouselSlideMousedown(event) {
            mousedownX = event.clientX || event.touches[0].clientX;
            mousedownY = event.clientY || event.touches[0].clientY;
            mousedownT = performance.now();
            event.preventDefault();
            event.stopPropagation();
            isMousedown = true;
            var pausePlayCoordinates = desktopStoryPausePlayCoordinates();
            var linkCoordinates = desktopStoryLinkCoordinates();
            if (!(mousedownX > pausePlayCoordinates.x[0] && mousedownX < pausePlayCoordinates.x[1] && mousedownY > pausePlayCoordinates.y[0] && mousedownY < pausePlayCoordinates.y[1]) && !(linkCoordinates && mousedownX > linkCoordinates.x[0] && mousedownX < linkCoordinates.x[1] && mousedownY > linkCoordinates.y[0] && mousedownY < linkCoordinates.y[1])) {
                isNonClick = true;
                pauseTimer()
            }
        }
        function handleCarouselSlideMouseup(event) {
            event.preventDefault();
            event.stopPropagation();
            if (!isMousedown) {
                return
            }
            isMousedown = false;
            mouseupX = event.clientX || event.changedTouches[0].clientX;
            var deltaX = mouseupX - mousedownX;
            mouseupY = event.clientY || event.changedTouches[0].clientY;
            var deltaY = mouseupY - mousedownY;
            var mouseupT = performance.now();
            if (Math.abs(deltaX) < 5 && Math.abs(deltaY) < 5 && mouseupT - mousedownT < 350) {
                handleMouseClick(event)
            }
            if (isNonClick) {
                resumeTimer();
                isNonClick = false
            }
        }
        function handleMouseClick(event) {
            if (!_this.overlayIsOpen) {
                return
            }
            var clickX = event.clientX || event.changedTouches[0].clientX;
            var clickY = event.clientY || event.changedTouches[0].clientY;
            var linkCoordinates = desktopStoryLinkCoordinates();
            if (linkCoordinates && clickX > linkCoordinates.x[0] && clickX < linkCoordinates.x[1] && clickY > linkCoordinates.y[0] && clickY < linkCoordinates.y[1]) {
                linkClick(activeStory());
                closeOverlay(_this.activeCoverIndex);
                return
            }
            var pausePlayCoordinates = desktopStoryPausePlayCoordinates();
            if (clickX > pausePlayCoordinates.x[0] && clickX < pausePlayCoordinates.x[1] && clickY > pausePlayCoordinates.y[0] && clickY < pausePlayCoordinates.y[1]) {
                if (_this.timerIsActive) {
                    pauseTimer()
                } else {
                    resumeTimer()
                }
                return
            }
        }
        function setActiveCarouselSlide(coverIndex) {
            var slideNodes = _this.carouselWrapper.querySelectorAll('.dnst-banner');
            for (var i = 0; i < slideNodes.length; i++) {
                var slideNode = slideNodes[i];
                slideNode.classList[i === coverIndex ? 'add' : 'remove']('dnst-banner_active')
            }
            changeCarouselPosition(coverIndex)
        }
        function changeCarouselPosition(coverIndex) {
            _this.carouselOffset = _this.carouselSlideWidth * coverIndex * -1;
            _this.carouselWrapper.style.transform = "translateX(".concat(_this.carouselSlideWidth * coverIndex * -1, "px)")
        }
        function setRootCssVariables() {
            var root = document.documentElement
              , maxWidth = windowWidth() * .55
              , maxHeight = windowHeight() * .95
              , aspectRatio = .5625
              , evaluatedMaxHeight = Math.min(maxWidth / aspectRatio, maxHeight)
              , slideHeight = evaluatedMaxHeight
              , slideWidth = slideHeight * aspectRatio;
            _this.carouselSlideWidth = slideWidth;
            root.style.setProperty('--dnst-carousel-active-slide-width', slideWidth + 'px');
            root.style.setProperty('--dnst-carousel-active-slide-height', slideHeight + 'px');
            root.style.setProperty('--dnst-window-height', windowHeight() + 'px')
        }
        _this.initialize = function() {
            create(_this.storySet)
        }
        ;
        _this.open = function(coverIndex) {
            coverIndex = coverIndex != null && coverIndex || _this.activeCoverIndex;
            openOverlay(coverIndex)
        }
        ;
        _this.close = function() {
            closeOverlay(_this.activeCoverIndex)
        }
        ;
        _this.onStoryClick = function(cover, story) {
            if (storyClickCallback) {
                storyClickCallback(cover, story)
            }
        }
        ;
        _this.onStoryDisplay = function(cover, story) {
            if (storyDisplayCallback) {
                storyDisplayCallback(cover, story)
            }
        }
    }
    function isObject(value) {
        return value !== null && _typeof(value) === 'object'
    }
    function createNode(tag, props, listeners) {
        var node = document.createElement(tag);
        if (isObject(props)) {
            assignNodeProps(node, props)
        }
        if (Array.isArray(listeners)) {
            addEventListeners(node, listeners)
        }
        return node
    }
    function assignNodeProps(node, object) {
        var entries = Object.entries(object);
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            var key = entry[0];
            var value = entry[1];
            if (isObject(value)) {
                assignNodeProps(node[key], value)
            } else {
                node[key] = value
            }
        }
    }
    function addEventListeners(node, listeners) {
        for (var i = 0; i < listeners.length; i++) {
            addEventListenerToNode(node, listeners[i])
        }
    }
    function addEventListenerToNode(node, listener) {
        if (!listener || !listener.event && !listener.callback) {
            return
        }
        node.addEventListener(listener.event, listener.callback, listener.options || undefined)
    }
    function preventDefault(event) {
        event.stopPropagation();
        event.preventDefault()
    }
    function insertNode(target, node, position) {
        position = (position || 'End').toLowerCase();
        var parent = null;
        var reference = null;
        switch (position) {
        case 'fill':
            parent = target;
            parent.innerHTML = '';
            break;
        case 'start':
            parent = target;
            reference = targetNode.childNodes[0] || null;
            break;
        case 'end':
            parent = target;
            break;
        case 'before':
            parent = target.parentNode;
            reference = target;
            break;
        case 'after':
            parent = target.parentNode;
            reference = target.nextElementSibling || null;
            break
        }
        parent.insertBefore(node, reference)
    }
    function generateGradientValue(colors, angle) {
        return "linear-gradient(".concat(angle || 180, "deg").concat(colors.reduce((function(result, color, colorIndex) {
            return result + ', ' + color + ' ' + colorIndex * (100 / colors.length + 1) + '%'
        }
        ), ''), ", ").concat(colors[0], ")")
    }
    function toArray(arrayLike) {
        return Array.prototype.slice.call(arrayLike)
    }
    function Timer(callback, delay) {
        var timerId, start, remaining = delay;
        this.pause = function() {
            window.clearTimeout(timerId);
            remaining -= performance.now() - start
        }
        ;
        this.resume = function() {
            start = performance.now();
            window.clearTimeout(timerId);
            timerId = window.setTimeout(callback, remaining)
        }
        ;
        this.resume()
    }
    function showOnsiteMessage(message) {
        logInfo('Onsite Displayer: Display process started for Message(' + message.publicId + ')', 'message: ', message);
        if (!message) {
            logWarning('Onsite Displayer: Message not displayed. Message(' + message.publicId + ') data is empty');
            return null
        }
        var dismissCallback = null
          , clickCallback = null
          , subDisplayCallback = null
          , container = null
          , iframeElement = null;
        function iframeMessageReceived(event) {
            if (!iframeElement || event.source !== iframeElement.contentWindow) {
                return
            }
            var eventData = event.data || {};
            var action = eventData.action;
            if (!action) {
                return
            }
            switch (action) {
            case 'dismiss':
                closeMessage();
                break;
            case 'openUrl':
                window.open(eventData.url, eventData.newTab ? '_blank' : '_self');
                break;
            case 'sendClick':
                if (clickCallback) {
                    clickCallback(message, eventData.buttonId)
                }
                break;
            case 'close':
                closeMessage();
                break;
            case 'setTags':
                setTagsFn(eventData.tags, 'contact_or_device');
                clickCallback(message, 'primaryButton');
                break;
            case 'copyText':
                var copyText = eventData.text;
                if (navigator.clipboard) {
                    navigator.clipboard.writeText(copyText)
                } else {
                    var textArea = document.createElement("textarea");
                    textArea.value = copyText;
                    textArea.style.top = "-9999px";
                    textArea.style.left = "-9999px";
                    textArea.style.position = "fixed";
                    document.body.appendChild(textArea);
                    textArea.focus();
                    textArea.select();
                    try {
                        document.execCommand('copy')
                    } catch (error) {
                        logError(error)
                    }
                    document.body.removeChild(textArea)
                }
                break;
            case 'height':
                iframeElement.style.height = eventData.value + 'px';
                break;
            case 'postSubscription':
                var contactKey = getContactKey() || 'sf_' + generateUUID();
                postSubscription(eventData.form, contactKey).then((function(response) {
                    if (response.status === 200) {
                        iframeElement.contentWindow.postMessage({
                            action: 'closeForm',
                            status: 'success'
                        }, '*');
                        setContactKey(contactKey, true);
                        clickCallback(message, 'primaryButton')
                    } else {
                        throw response
                    }
                }
                )).catch((function(error) {
                    logError(error);
                    iframeElement.contentWindow.postMessage({
                        action: 'closeForm',
                        status: 'error'
                    }, '*')
                }
                ));
                break;
            case 'postSubscriptionWithTags':
                var contactKey = getContactKey() || 'sf_' + generateUUID();
                postSubscription(eventData.form, contactKey).then((function(response) {
                    if (response.status === 200) {
                        setContactKey(contactKey, true);
                        return
                    } else {
                        throw response
                    }
                }
                )).then((function() {
                    return setTagsFn(eventData.tags, 'contact_or_device')
                }
                )).then((function() {
                    iframeElement.contentWindow.postMessage({
                        action: 'closeForm',
                        status: 'success'
                    }, '*');
                    clickCallback(message, 'primaryButton')
                }
                )).catch((function(error) {
                    logError(error);
                    iframeElement.contentWindow.postMessage({
                        action: 'closeForm',
                        status: 'error'
                    }, '*')
                }
                ));
                break
            }
        }
        function closeMessage() {
            if (container) {
                container.classList.remove('dn-opened')
            }
            setTimeout((function() {
                if (document && document.body && document.body.removeChild && container) {
                    document.body.removeChild(container)
                }
                window.removeEventListener('message', iframeMessageReceived)
            }
            ), 10);
            if (!dismissCallback) {
                return
            }
            dismissCallback(message)
        }
        function clickHandler(event, buttonId) {
            if (event && event.stopPropagation) {
                event.stopPropagation()
            }
            if (clickCallback) {
                clickCallback(message, buttonId || 'primaryButton')
            }
        }
        return loadHtmlIfNecessary(message).then((function(content) {
            if (!content || !content.type && !content.contentType || !content.props || !content.props.html) {
                logWarning('Onsite Displayer: Message not displayed. Message(' + message.publicId + ') "content" is empty or invalid.', '"content": ', content);
                return null
            }
            message.content = content;
            var contentType = content.props.html.includes('data-tf-type') ? 'TYPEFORM' : content.contentType;
            if (contentType === 'TYPEFORM') {
                var parser = new DOMParser;
                var messageDoc = parser.parseFromString(content.props.html, 'text/html');
                if (!messageDoc || !messageDoc.body || !messageDoc.body.dataset || !messageDoc.body.dataset.tfId) {
                    logWarning('Onsite Displayer: Message not displayed. Typeform Message(' + message.publicId + ') html is invalid', 'html: ', content.props.html);
                    return null
                }
                var typeformData = messageDoc.body.dataset;
                var uniqifyEnabled = typeformData.tfUniqify === 'true';
                var uniqifyColumnName = typeformData.tfUniqifyColumnName;
                var uniqifyColumnLegacyValue = typeformData.tfUniqifyColumnValue;
                var uniqifyHiddenKey = typeformData.tfUniqifyHiddenKey;
                var tfId = typeformData.tfId;
                return Promise.resolve(uniqifyEnabled ? isTypeformSubmittedByUserGroup(tfId, uniqifyColumnName, uniqifyColumnLegacyValue) : true).then((function(uniqifyColumnValue) {
                    if (!uniqifyColumnValue) {
                        logWarning('Onsite Displayer: Message not displayed. Uniqified Typeform Message(' + message.publicId + ') has no "uniqifyColumnValue"');
                        return null
                    }
                    var tfCss = document.createElement('link');
                    tfCss.href = 'https://embed.typeform.com/next/css/popup.css';
                    tfCss.rel = 'stylesheet';
                    document.head.appendChild(tfCss);
                    var tfSdk = document.createElement('script');
                    tfSdk.src = 'https://embed.typeform.com/next/embed.js';
                    var loadTimeout = null;
                    return new Promise((function(resolve, reject) {
                        tfSdk.onload = function() {
                            var tfSize = parseInt(typeformData.tfSize);
                            var hiddenValues = {
                                dn_contact_key: getContactKey(),
                                dn_device_id: getDeviceId(),
                                dn_send_id: !message.isRealtime ? message.publicId.split('-')[1] : '',
                                dn_campaign_id: message.isRealtime ? message.publicId : '',
                                dn_channel: (message.isRealtime ? 'realtime' : '') + 'onsite',
                                dn_uniqify: uniqifyEnabled,
                                dn_integration_key: 'dPfs6p5b_p_l_K_p_l__p_l_Y8VhrU2Wl91zleK2npa6cHKyW63dele1dg1G8vRtwZkmRAPmJcPgEQqUSIlB_p_l_674Du7Pb0qg1P3KcPIP3ZPlx9_s_l_lfKmDy57YLwa_p_l_yWHfmVuQLWCqgrKUQ8xYSN3AC4BMvMRyJ1Z8JQ_e_q__e_q_'
                            };
                            if (uniqifyEnabled) {
                                hiddenValues[uniqifyHiddenKey] = uniqifyColumnValue
                            }
                            tf.createPopup(tfId, {
                                open: 'load',
                                size: isNaN(tfSize) ? 75 : tfSize,
                                hideHeaders: typeformData.tfHideHeaders === 'true',
                                hidden: hiddenValues,
                                enableSandbox: (window.location.search + window.location.hash).includes('dn_content_preview'),
                                onClose: closeMessage,
                                onSubmit: clickHandler,
                                onReady: resolve
                            });
                            loadTimeout = setTimeout((function() {
                                reject()
                            }
                            ), 1e4)
                        }
                        ;
                        document.head.appendChild(tfSdk)
                    }
                    )).then((function() {
                        clearTimeout(loadTimeout);
                        return {
                            onDismissPopup: function onDismissPopup(callback) {
                                dismissCallback = callback
                            },
                            onClickMessage: function onClickMessage(callback) {
                                clickCallback = callback
                            }
                        }
                    }
                    )).catch((function() {
                        return null
                    }
                    ))
                }
                ))
            } else if (contentType === 'HTML_INLINE') {
                var parser = new DOMParser;
                var messageDoc = parser.parseFromString(content.props.html, 'text/html');
                var storySetScriptNode = messageDoc.querySelector('.dn-inline-story-data');
                var storySetJson = storySetScriptNode && storySetScriptNode.innerHTML || '';
                if (storySetJson) {
                    var injectedStory = document.querySelector('[data-dn-story-set-id="' + message.publicId + '"]');
                    if (injectedStory) {
                        logWarning('Onsite Displayer: Story rendering aborted, message(' + message.publicId + ') already rendered');
                        return null
                    }
                    storySetJson = storySetJson.replace(/True/gm, 'true').replace(/False/gm, 'false');
                    var storySet = {};
                    var storyVisitData = [];
                    try {
                        storySet = JSON.parse(storySetJson);
                        storySet.id = message.publicId
                    } catch (error) {
                        logError('Onsite Displayer: Story message(' + message.publicId + ') json has an error.', 'json: ', storySetJson, 'error: ', error);
                        return null
                    }
                    getStoryVisitData(message.publicId).then((function(visitData) {
                        storyVisitData = visitData || [];
                        storySet.covers = storySet.covers.map((function(cover, coverIndex) {
                            cover.id = cover.id != null && cover.id || coverIndex;
                            cover.isVisited = storyVisitData.includes(cover.id);
                            return cover
                        }
                        ));
                        window._Dn_globaL_.storySets[message.publicId] = storySet;
                        var storyRenderer = new StorySetRenderer(storySet,message.inlineTarget.selector,message.inlineTarget.type,(function(cover, story) {
                            if (subDisplayCallback) {
                                subDisplayCallback(message, {
                                    stPrId: cover.id,
                                    stPrName: cover.name,
                                    stId: story.id,
                                    stName: story.name
                                })
                            }
                        }
                        ),(function(cover, story) {
                            if (clickCallback) {
                                clickCallback(message, {
                                    stPrId: cover.id,
                                    stPrName: cover.name,
                                    stId: story.id,
                                    stName: story.name
                                })
                            }
                        }
                        ));
                        storyRenderer.initialize();
                        logInfo('Onsite Displayer: Story message(' + message.publicId + ') injected')
                    }
                    ))
                } else {
                    var styleNode = messageDoc.querySelector('.dn-inline-style');
                    var styling = styleNode && styleNode.innerHTML || '';
                    if (styling) {
                        var styleNodeClone = styleNode.cloneNode(true);
                        styleNodeClone.dataset.dnInlineId = message.publicId;
                        document.head.appendChild(styleNodeClone)
                    }
                    var htmlNode = messageDoc.querySelector('.dn-inline-html');
                    var html = htmlNode && htmlNode.innerHTML || '';
                    if (html) {
                        if (isInlineTargetValid(message.inlineTarget, message.publicId)) {
                            var targetNodes = document.querySelectorAll(message.inlineTarget.selector);
                            var succesfulInjections = 0;
                            for (var i = 0; i < targetNodes.length; i++) {
                                var targetNode = targetNodes[i];
                                var actionNode = null;
                                var referenceNode = null;
                                switch (message.inlineTarget.type) {
                                case 'Fill':
                                    actionNode = targetNode;
                                    actionNode.innerHTML = '';
                                    break;
                                case 'Start':
                                    actionNode = targetNode;
                                    referenceNode = targetNode.childNodes[0] || null;
                                    break;
                                case 'End':
                                    actionNode = targetNode;
                                    break;
                                case 'Before':
                                    actionNode = targetNode.parentNode;
                                    referenceNode = targetNode;
                                    break;
                                case 'After':
                                    actionNode = targetNode.parentNode;
                                    referenceNode = targetNode.nextElementSibling || null;
                                    break
                                }
                                var invalidTargetWarningPrefix = 'Onsite Displayer: Inline message not injected. Message(' + message.publicId + ') target ';
                                if (actionNode === document.documentElement) {
                                    logWarning(invalidTargetWarningPrefix + 'is inside "html" tag')
                                } else if (actionNode === document.head) {
                                    logWarning(invalidTargetWarningPrefix + 'is inside "head" tag')
                                } else if (actionNode.querySelector('[data-dn-inline-id="' + message.publicId + '"]')) {
                                    logWarning(invalidTargetWarningPrefix + 'was injected already')
                                } else {
                                    var htmlNodeClone = htmlNode.cloneNode(true);
                                    var injectedLinks = htmlNodeClone.querySelectorAll('a[href]');
                                    for (var j = 0; j < injectedLinks.length; j++) {
                                        injectedLinks[j].addEventListener('click', (function(event) {
                                            clickHandler(event, this.href)
                                        }
                                        ))
                                    }
                                    if (htmlNodeClone.tagName === 'A' && htmlNodeClone.href) {
                                        htmlNodeClone.addEventListener('click', (function(event) {
                                            clickHandler(event, this.href)
                                        }
                                        ))
                                    }
                                    htmlNodeClone.dataset.dnInlineId = message.publicId;
                                    htmlNodeClone.dataset.dnInlineIndex = succesfulInjections;
                                    var injectedElement = actionNode.insertBefore(htmlNodeClone, referenceNode);
                                    succesfulInjections++;
                                    logInfo('Onsite Displayer: Inline Message(' + message.publicId + ') html node is injected.', 'injectedElement: ', injectedElement)
                                }
                            }
                            if (succesfulInjections) {
                                logInfo('Onsite Displayer: Inline Message(' + message.publicId + ') html node is injected to ' + succesfulInjections + ' of ' + targetNodes.length + ' target(s)')
                            } else {
                                logWarning('Onsite Displayer: Inline message not injected. Message(' + message.publicId + ') cannot be injected to target(s).')
                            }
                        }
                    }
                    var scriptNode = messageDoc.querySelector('.dn-inline-script');
                    var script = scriptNode && scriptNode.innerHTML || '';
                    if (script) {
                        var scriptFunction = Function(script);
                        window._Dn_globaL_.inlineScripts[message.publicId] = {
                            code: scriptFunction,
                            isRun: false,
                            hasError: null
                        };
                        try {
                            window._Dn_globaL_.inlineScripts[message.publicId].isRun = true;
                            scriptFunction();
                            window._Dn_globaL_.inlineScripts[message.publicId].hasError = false
                        } catch (error) {
                            window._Dn_globaL_.inlineScripts[message.publicId].hasError = true;
                            logError('Onsite Displayer: Inline message(' + message.publicId + ') script has an error:', 'script: ', scriptFunction, 'error: ', error);
                            return null
                        }
                    }
                    if (!styling && !html && !script) {
                        logWarning('Onsite Displayer: Inline message not injected. message(' + message.publicId + ') has no injection data');
                        return null
                    }
                }
            } else {
                var position = content.props.position;
                if (position === 'MIDDLE') {
                    position = 'MIDDLE_CENTER'
                }
                container = document.createElement('div');
                var isBanner = ['TOP', 'BOTTOM'].includes(position);
                if (isBanner) {
                    container.className = 'dengage-onsite-banner dn-' + position.toLowerCase(),
                    container.innerHTML = generateBannerHtml(content)
                } else {
                    var _window$_Dn_globaL_$u;
                    var hasSpecificPosition = position.includes('_');
                    var mobileClass = ((_window$_Dn_globaL_$u = window._Dn_globaL_.ua) === null || _window$_Dn_globaL_$u === void 0 ? void 0 : _window$_Dn_globaL_$u.device.type) === 'mobile' ? ' dengage-onsite-is-mobile' : '';
                    container.className = 'dengage-onsite-' + (hasSpecificPosition ? 'new-' : '') + 'overlay' + mobileClass;
                    if (hasSpecificPosition) {
                        var positionClasses = {
                            TOP: 'dn-align-start',
                            MIDDLE: 'dn-align-center',
                            BOTTOM: 'dn-align-end',
                            LEFT: 'dn-justify-start',
                            CENTER: 'dn-justify-center',
                            RIGHT: 'dn-justify-end'
                        };
                        var splittedPosition = position.split('_');
                        var offsetClass = position !== 'MIDDLE_CENTER' ? ' dengage-onsite-offset' : '';
                        container.className += ' ' + positionClasses[splittedPosition[0]];
                        container.className += ' ' + positionClasses[splittedPosition[1]];
                        container.className += offsetClass
                    }
                    container.innerHTML = generateModalHtml(content);
                    if (content.props.dismissOnClickOutside) {
                        setTimeout((function() {
                            container.addEventListener('click', closeMessage)
                        }
                        ), 1500)
                    }
                    if (content.props.isCloseButtonActive) {
                        var closeBtn = container.getElementsByClassName('dn-btn-popup-close')[0];
                        closeBtn.addEventListener('click', closeMessage)
                    }
                }
                iframeElement = container.querySelector('iframe');
                iframeElement.addEventListener('load', (function() {
                    var animatedEl = isBanner ? container : container.querySelector('.dn-iframe-container');
                    animatedEl.classList.add('dn-opened')
                }
                ));
                document.body.appendChild(container);
                window.addEventListener('message', iframeMessageReceived, false)
            }
            return {
                onDismissPopup: function onDismissPopup(callback) {
                    dismissCallback = callback
                },
                onClickMessage: function onClickMessage(callback) {
                    clickCallback = callback
                },
                onSubDisplay: function onSubDisplay(callback) {
                    subDisplayCallback = callback
                }
            }
        }
        ))
    }
    function loadHtmlIfNecessary(message) {
        var messageId = message.publicId;
        if (message.content) {
            return Promise.resolve(message.content)
        }
        var url = new URL('https://dev-push.dengage.com/targetapi/onsite/public/90db7e2a-5839-53cd-605f-9d3ffc328e21');
        var data = {
            campaignId: messageId,
            culture: navigator.language,
            deviceId: getDeviceId()
        };
        var contactKey = getContactKey();
        if (contactKey) {
            data.contactKey = contactKey
        }
        url.search = new URLSearchParams(data).toString();
        var responseStatus = '';
        return fetch(url).then((function(response) {
            if (response.status >= 400) {
                responseStatus = response.status + ' ' + response.statusText;
                throw response.json()
            }
            return response.json()
        }
        )).then((function(contentResponse) {
            return contentResponse.content
        }
        )).catch((function(error) {
            var errorText = responseStatus;
            if (error && error.errCode && error.errMsg) {
                errorText = error.errCode + ': ' + error.errMsg
            }
            logError('Content of message(' + messageId + ') fetch is failed', 'error: ' + errorText);
            return null
        }
        ))
    }
    function postSubscription(formData, contactKey) {
        var userPermission = getUserPermission();
        var deviceId = getDeviceId();
        var payload = {
            integrationKey: 'dPfs6p5b_p_l_K_p_l__p_l_Y8VhrU2Wl91zleK2npa6cHKyW63dele1dg1G8vRtwZkmRAPmJcPgEQqUSIlB_p_l_674Du7Pb0qg1P3KcPIP3ZPlx9_s_l_lfKmDy57YLwa_p_l_yWHfmVuQLWCqgrKUQ8xYSN3AC4BMvMRyJ1Z8JQ_e_q__e_q_',
            token: getToken(),
            contactKey: contactKey,
            permission: userPermission == null || userPermission == 'true' ? true : false,
            udid: deviceId,
            advertisingId: '',
            carrierId: null,
            appVersion: null,
            sdkVersion: '1.5.1',
            trackingPermission: getTrackingPermission(),
            webSubscription: getWebSubscription(),
            tokenType: getTokenType(),
            timezone: getTimezone(),
            language: navigator.language || navigator.userLanguage,
            country: getCountry(),
            email: formData.email || null,
            emailPermission: formData.emailPermission || null,
            gsm: formData.gsm || null,
            gsmPermission: formData.gsmPermission || null,
            name: formData.name || null,
            surname: formData.surname || null,
            birthDate: formData.birthDate || null,
            tags: formData.tags || [],
            source: 'subscription_form'
        };
        payload = Object.assign(payload, formData);
        return fetch('https://dev-push.dengage.com/api/web/subscription', {
            method: 'POST',
            mode: 'cors',
            cache: 'no-cache',
            credentials: 'omit',
            headers: {
                'Content-Type': 'text/plain'
            },
            body: JSON.stringify(payload)
        })
    }
    function sendOnsiteEvent(message, type, details) {
        if (message.isRealtime) {
            if (type != 'DISMISS') {
                return sendRealtimeEvent(message, type, details)
            }
            return Promise.resolve()
        } else {
            return sendLegacyEvent(message, type, details)
        }
    }
    var ongoingRealtimeOnsiteEventDataList = [];
    function sendRealtimeEvent(message, type, details) {
        var deviceId = getDeviceId();
        var contactKey = getContactKey();
        var url = new URL('https://dev-push.dengage.com/api/realtime-onsite/event');
        var data = {
            acc: '90db7e2a-5839-53cd-605f-9d3ffc328e21',
            did: deviceId,
            camp: message.publicId,
            content: message.content.publicId,
            event: type == 'CLICK' ? 'CL' : 'DS',
            sid: storage.get('session.id')
        };
        if (contactKey) {
            data.ckey = contactKey
        }
        if (details != null) {
            if (_typeof(details) === 'object') {
                data.event = type == 'CLICK' ? 'SC' : 'SD';
                data.stPrId = details.stPrId;
                data.stPrName = details.stPrName;
                data.stId = details.stId;
                data.stName = details.stName
            } else {
                data.btn = details
            }
        }
        url.search = new URLSearchParams(data).toString();
        if (ongoingRealtimeOnsiteEventDataList.some((function(ongoingData) {
            return isEqual(ongoingData, data)
        }
        ))) {
            logInfo('already sent same realtime onsite event, request cancelled, data:', data);
            return Promise.resolve()
        }
        var currentDataIndex = ongoingRealtimeOnsiteEventDataList.length;
        ongoingRealtimeOnsiteEventDataList.push(data);
        return fetch(url).catch((function(e) {
            logError(e.toString())
        }
        )).finally((function() {
            setTimeout((function() {
                ongoingRealtimeOnsiteEventDataList.splice(currentDataIndex, 1)
            }
            ), 1e3)
        }
        ))
    }
    var ongoingLegacyOnsiteEventDataList = [];
    function sendLegacyEvent(message, type, button) {
        if (!message.messageDetails) {
            return Promise.reject()
        }
        var deviceId = getDeviceId();
        var contactKey = getContactKey();
        var url = new URL('https://dev-push.dengage.com/api/onsite/' + (type == 'DISMISS' ? 'setAsDismissed' : type == 'DISPLAY' ? 'setAsDisplayed' : 'setAsClicked'));
        var data = {
            acc: '90db7e2a-5839-53cd-605f-9d3ffc328e21',
            cdkey: contactKey || deviceId,
            type: contactKey ? 'c' : 'd',
            did: deviceId,
            message_details: message.messageDetails,
            button_id: button
        };
        url.search = new URLSearchParams(data).toString();
        if (ongoingLegacyOnsiteEventDataList.some((function(ongoingData) {
            return isEqual(ongoingData, data)
        }
        ))) {
            logInfo('already sent same legacy onsite event, request cancelled, data:', data);
            return Promise.resolve()
        }
        var currentDataIndex = ongoingLegacyOnsiteEventDataList.length;
        ongoingLegacyOnsiteEventDataList.push(data);
        return fetch(url, {
            method: 'POST',
            mode: 'cors',
            cache: 'no-cache',
            credentials: 'omit',
            headers: {
                'Content-Type': 'text/plain'
            }
        }).catch((function(e) {
            logError(e.toString())
        }
        )).finally((function() {
            setTimeout((function() {
                ongoingLegacyOnsiteEventDataList.splice(currentDataIndex, 1)
            }
            ), 1e3)
        }
        ))
    }
    var messages = [];
    var displayInfos = [];
    var isMessagesLoaded = false;
    var isLoading = false;
    function getAll() {
        return waitForLoading().then((function() {
            return messages
        }
        ))
    }
    function getDisplayInfo(id) {
        return waitForLoading().then((function() {
            return displayInfos.find((function(m) {
                return m.id == id
            }
            ))
        }
        ))
    }
    function setMessageAsDisplayed(id) {
        return waitForLoading().then((function() {
            var msg = messages.find((function(m) {
                return m.publicId == id
            }
            ));
            var current = displayInfos.find((function(m) {
                return m.id == id
            }
            ));
            if (current) {
                current.lastDisplayTime = (new Date).getTime();
                current.displayCount += 1
            } else {
                current = {
                    id: id,
                    isRealtime: msg.isRealtime,
                    lastDisplayTime: (new Date).getTime(),
                    displayCount: 1,
                    isClicked: false
                };
                displayInfos.push(current)
            }
            return saveDisplayInfo(current)
        }
        ))
    }
    function setMessageAsDismissed(id) {
        return waitForLoading().then((function() {
            var msg = messages.find((function(m) {
                return m.publicId == id
            }
            ));
            var current = displayInfos.find((function(m) {
                return m.id == id
            }
            ));
            if (current) {
                current.lastDisplayTime = (new Date).getTime()
            } else {
                logError('dismissed message not found');
                current = {
                    id: id,
                    isRealtime: msg.isRealtime,
                    lastDisplayTime: (new Date).getTime(),
                    displayCount: 1,
                    isClicked: false
                };
                displayInfos.push(current)
            }
            return saveDisplayInfo(current)
        }
        ))
    }
    function setMessageAsClicked(id) {
        return waitForLoading().then((function() {
            var msg = messages.find((function(m) {
                return m.publicId == id
            }
            ));
            var current = displayInfos.find((function(m) {
                return m.id == id
            }
            ));
            if (current) {
                current.lastDisplayTime = (new Date).getTime();
                current.isClicked = true
            } else {
                logError('clicked message not found');
                current = {
                    id: id,
                    isRealtime: msg.isRealtime,
                    lastDisplayTime: (new Date).getTime(),
                    displayCount: 1,
                    isClicked: true
                };
                displayInfos.push(current)
            }
            return saveDisplayInfo(current)
        }
        ))
    }
    function deleteMsg(id) {
        return waitForLoading().then((function() {
            var deleteIndex = messages.findIndex((function(message) {
                return message.publicId == id
            }
            ));
            if (deleteIndex == -1) {
                return
            }
            var message = messages[deleteIndex];
            if (message && !message.isRealtime) {
                deleteLegacyMessage(id)
            }
            messages.splice(deleteIndex, 1)
        }
        ))
    }
    function waitForLoading() {
        if (isMessagesLoaded) {
            return Promise.resolve()
        } else {
            if (isLoading == false) {
                load()
            }
            return waitUntil((function() {
                return isMessagesLoaded
            }
            ))
        }
    }
    function load() {
        isLoading = true;
        var realtimeMessagesPromise = Promise.resolve([]);
        var legacyMessagesPromise = Promise.resolve([]);
        var displayInfosPromise = getAllDisplayInfos();
        if (isDnRealtimeOnsiteEnabled()) {
            realtimeMessagesPromise = loadRealtimeMessages()
        }
        if (isDnLegacyOnsiteEnabled()) {
            legacyMessagesPromise = loadLegacyMessages()
        }
        return Promise.all([realtimeMessagesPromise, legacyMessagesPromise, displayInfosPromise]).then((function(_ref) {
            var _ref2 = _slicedToArray(_ref, 3)
              , realtimeMessages = _ref2[0]
              , legacyMessages = _ref2[1]
              , _displayInfos = _ref2[2];
            var allMesssages = realtimeMessages.concat(legacyMessages);
            var now = new Date;
            for (var i = 0; i < allMesssages.length; i++) {
                var message = allMesssages[i];
                if (DateParse(message.startDate) <= now && DateParse(message.endDate) > now) {
                    messages.push(message)
                }
                if (!message.isRealtime && DateParse(message.endDate) <= now) {
                    deleteLegacyMessage(message.id)
                }
            }
            messages = sortMessages(messages);
            displayInfos = _displayInfos;
            isMessagesLoaded = true;
            isLoading = false
        }
        ))
    }
    function loadRealtimeMessages() {
        var domain = _Dn_globaL_.domain;
        if (domain == 'dev-pub.dengage.com') {
            domain = 'dev.lib.dengage.com'
        }
        var URL = isDebugMode() ? 'https://dev-push.dengage.com/targetapi/onsite/public/p/push/10/f6db8103-830e-d147-3a40-afef0c991358/dengage_onsite_debug.js' : 'https://' + domain + '/p/push/10/f6db8103-830e-d147-3a40-afef0c991358/dengage_onsite.js';
        return new Promise((function(resolve, reject) {
            loadScript(URL);
            window.__dn_set_messages__ = function(messages) {
                window.__dn_set_messages__ = null;
                messages.forEach((function(m) {
                    m.isRealtime = true;
                    m.messageDetails = ''
                }
                ));
                resolve(messages)
            }
        }
        ))
    }
    function loadLegacyMessages() {
        var backendPromise = checkGetMessageIntervalReached() ? getLegacyMessagesFromBackend() : Promise.resolve([]);
        return backendPromise.then((function(messages) {
            if (messages.length > 0) {
                var lastMessageCreated = storage.getInt('legacy_onsite.last_msg_created');
                messages = messages.filter((function(m) {
                    return new Date(m.created).valueOf() > lastMessageCreated
                }
                ));
                for (var i = 0; i < messages.length; i++) {
                    var createVal = new Date(messages[i].created).valueOf();
                    if (createVal > lastMessageCreated) {
                        lastMessageCreated = createVal
                    }
                }
                storage.set('legacy_onsite.last_msg_created', lastMessageCreated);
                return saveLegacyMessages(messages)
            }
        }
        )).then((function() {
            return getAllLegacyMessages()
        }
        ))
    }
    function getLegacyMessagesFromBackend() {
        var deviceId = getDeviceId();
        var contactKey = getContactKey();
        var url = new URL('https://dev-push.dengage.com/api/onsite/getMessages');
        var reqParams = {
            acc: '90db7e2a-5839-53cd-605f-9d3ffc328e21',
            cdkey: contactKey || deviceId,
            type: contactKey ? 'c' : 'd',
            did: deviceId,
            appid: 'f6db8103-830e-d147-3a40-afef0c991358'
        };
        url.search = new URLSearchParams(reqParams).toString();
        var request = fetch(url, {
            cache: 'no-cache',
            headers: {
                'Content-Type': 'text/plain'
            }
        }).then((function(response) {
            storage.set('legacy_onsite.get_message_t', (new Date).getTime());
            return response.json()
        }
        )).then((function(data) {
            data.forEach((function(d) {
                if (typeof d.message_json == 'string') {
                    d.message_json = JSON.parse(d.message_json)
                }
            }
            ));
            logInfo('Onsite Legacy Messages backend response ', data);
            return data
        }
        )).catch((function(e) {
            logError('Onsite getMessage Error', e.message);
            return []
        }
        ));
        return request
    }
    function getOnsiteMsgFetchInterval() {
        var minutes = '5';
        if (isDebugMode()) {
            return 0
        }
        return parseInt(minutes)
    }
    function checkGetMessageIntervalReached() {
        var messageGetTimeStamp = storage.get('legacy_onsite.get_message_t');
        if (!messageGetTimeStamp) {
            return true
        }
        var currentdate = new Date;
        var messageIntervalTimeStamp = new Date(parseInt(messageGetTimeStamp));
        var diffMs = currentdate.getTime() - messageIntervalTimeStamp.getTime();
        var diffMins = diffMs / 6e4;
        if (diffMins >= getOnsiteMsgFetchInterval()) {
            return true
        }
        return false
    }
    var f = /\[object (Boolean|Number|String|Function|Array|Date|RegExp|Arguments)\]/;
    function g(a) {
        return null == a ? String(a) : (a = f.exec(Object.prototype.toString.call(Object(a)))) ? a[1].toLowerCase() : 'object'
    }
    function m(a, b) {
        return Object.prototype.hasOwnProperty.call(Object(a), b)
    }
    function n(a) {
        if (!a || 'object' != g(a) || a.nodeType || a == a.window)
            return !1;
        try {
            if (a.constructor && !m(a, 'constructor') && !m(a.constructor.prototype, 'isPrototypeOf'))
                return !1
        } catch (c) {
            return !1
        }
        for (var b in a) {}
        return void 0 === b || m(a, b)
    }
    function p(a, b) {
        var c = {}
          , d = c;
        a = a.split('.');
        for (var e = 0; e < a.length - 1; e++) {
            d = d[a[e]] = {}
        }
        d[a[a.length - 1]] = b;
        return c
    }
    function q(a, b) {
        var c = !a._clear, d;
        for (d in a) {
            if (m(a, d)) {
                var e = a[d];
                'array' === g(e) && c ? ('array' === g(b[d]) || (b[d] = []),
                q(e, b[d])) : n(e) && c ? (n(b[d]) || (b[d] = {}),
                q(e, b[d])) : b[d] = e
            }
        }
        delete b._clear
    }
    function r(a, b, c) {
        b = void 0 === b ? {} : b;
        'function' === typeof b ? b = {
            listener: b,
            listenToPast: void 0 === c ? !1 : c,
            processNow: !0,
            commandProcessors: {}
        } : b = {
            listener: b.listener || function() {}
            ,
            listenToPast: b.listenToPast || !1,
            processNow: void 0 === b.processNow ? !0 : b.processNow,
            commandProcessors: b.commandProcessors || {}
        };
        this.a = a;
        this.l = b.listener;
        this.j = b.listenToPast;
        this.g = this.i = !1;
        this.c = {};
        this.f = [];
        this.b = b.commandProcessors;
        this.h = u(this);
        var d = this.a.push
          , e = this;
        this.a.push = function() {
            var k = [].slice.call(arguments, 0)
              , l = d.apply(e.a, k);
            v(e, k);
            return l
        }
        ;
        b.processNow && this.process()
    }
    r.prototype.process = function() {
        this.registerProcessor('set', (function() {
            var c = {};
            1 === arguments.length && 'object' === g(arguments[0]) ? c = arguments[0] : 2 === arguments.length && 'string' === g(arguments[0]) && (c = p(arguments[0], arguments[1]));
            return c
        }
        ));
        this.i = !0;
        for (var a = this.a.length, b = 0; b < a; b++) {
            v(this, [this.a[b]], !this.j)
        }
    }
    ;
    r.prototype.get = function(a) {
        var b = this.c;
        a = a.split('.');
        for (var c = 0; c < a.length; c++) {
            if (void 0 === b[a[c]])
                return;
            b = b[a[c]]
        }
        return b
    }
    ;
    r.prototype.flatten = function() {
        this.a.splice(0, this.a.length);
        this.a[0] = {};
        q(this.c, this.a[0])
    }
    ;
    r.prototype.registerProcessor = function(a, b) {
        a in this.b || (this.b[a] = []);
        this.b[a].push(b)
    }
    ;
    function v(a, b, c) {
        c = void 0 === c ? !1 : c;
        if (a.i && (a.f.push.apply(a.f, b),
        !a.g))
            for (; 0 < a.f.length; ) {
                b = a.f.shift();
                if ('array' === g(b))
                    a: {
                        var d = a.c;
                        g(b[0]);
                        for (var e = b[0].split('.'), k = e.pop(), l = b.slice(1), h = 0; h < e.length; h++) {
                            if (void 0 === d[e[h]])
                                break a;
                            d = d[e[h]]
                        }
                        try {
                            d[k].apply(d, l)
                        } catch (w) {}
                    }
                else if ('arguments' === g(b)) {
                    e = a;
                    k = [];
                    l = b[0];
                    if (e.b[l])
                        for (d = e.b[l].length,
                        h = 0; h < d; h++) {
                            k.push(e.b[l][h].apply(e.h, [].slice.call(b, 1)))
                        }
                    a.f.push.apply(a.f, k)
                } else if ('function' == typeof b)
                    try {
                        b.call(a.h)
                    } catch (w) {}
                else if (n(b))
                    for (var t in b) {
                        q(p(t, b[t]), a.c)
                    }
                else
                    continue;
                c || (a.g = !0,
                a.l(a.c, b),
                a.g = !1)
            }
    }
    r.prototype.registerProcessor = r.prototype.registerProcessor;
    r.prototype.flatten = r.prototype.flatten;
    r.prototype.get = r.prototype.get;
    r.prototype.process = r.prototype.process;
    function u(a) {
        return {
            set: function set(b, c) {
                q(p(b, c), a.c)
            },
            get: function get(b) {
                return a.get(b)
            }
        }
    }
    var DataLayerHelper = r;
    function checkMessage(message, trigger) {
        return getDisplayInfo(message.publicId).then((function(displayInfo) {
            if (checkMessageTimesAndClick(message, displayInfo) && checkTrigger(message, trigger)) {
                return checkConditions(message)
            } else {
                return false
            }
        }
        ))
    }
    function checkMessageTimesAndClick(msg, displayInfo) {
        if (!displayInfo || !displayInfo.lastDisplayTime) {
            return true
        }
        var showEveryXMinutes = msg.triggerSettings.showEveryXMinutes
          , lastDisplayTime = displayInfo.lastDisplayTime
          , now = (new Date).getTime()
          , maxShowCount = msg.triggerSettings.maxShowCount
          , displayCount = displayInfo.displayCount
          , dontShowAfterClick = msg.triggerSettings.dontShowAfterClick
          , doNotShowAfterClick = msg.triggerSettings.doNotShowAfterClick
          , isClicked = displayInfo.isClicked;
        dontShowAfterClick = dontShowAfterClick != null ? dontShowAfterClick : doNotShowAfterClick != null ? doNotShowAfterClick : true;
        if ((showEveryXMinutes < 0 ? true : lastDisplayTime + showEveryXMinutes * 6e4 <= now) && (maxShowCount < 0 ? true : maxShowCount > displayCount) && (dontShowAfterClick ? !isClicked : true)) {
            return true
        }
        return false
    }
    function checkTrigger(msg, trigger) {
        if (msg.triggerSettings.triggerBy != trigger.triggerBy) {
            return false
        }
        if (trigger.triggerBy == 'NAVIGATION') {
            if (msg.triggerSettings.delay != trigger.delay) {
                return false
            }
        } else if (trigger.triggerBy == 'ON_SCROLL') {
            if (msg.triggerSettings.scrollPercentage != trigger.scrollPercentage) {
                return false
            }
        } else if (trigger.triggerBy == 'DENGAGE_EVENT' || trigger.triggerBy == 'DATA_LAYER_EVENT') {
            if (msg.triggerSettings.eventName != trigger.eventName) {
                return false
            }
        }
        return true
    }
    function checkConditions(message) {
        var displayCondition = message.displayCondition
          , whereToDisplay = displayCondition.whereToDisplay
          , whereToDisplayLogicOperator = displayCondition.whereToDisplayLogicOperator
          , _location = window.location
          , path = _location.pathname + _location.search + _location.hash;
        if (whereToDisplay && whereToDisplay.length) {
            var checkFunction = whereToDisplayLogicOperator === 'AND' ? 'every' : 'some';
            var isPathMatched = whereToDisplay[checkFunction]((function(regexString) {
                var isNegative = false;
                if (regexString.startsWith('-')) {
                    isNegative = true;
                    regexString = regexString.slice(1)
                }
                var regexMatches = path.match(new RegExp(regexString.slice(1, -1),'i'));
                return isNegative ? !regexMatches : !!regexMatches
            }
            ));
            if (isPathMatched == false) {
                return Promise.resolve(false)
            }
        }
        var deviceType = window._Dn_globaL_.ua.device.type
          , onsitePlatform = displayCondition.onsitePlatform;
        if (onsitePlatform == 'Mobile' && deviceType != 'mobile') {
            return Promise.resolve(false)
        }
        if (onsitePlatform == 'Web' && deviceType == 'mobile') {
            return Promise.resolve(false)
        }
        var isRealtime = message.isRealtime
          , ruleSet = displayCondition.ruleSet;
        if (!isRealtime) {
            var screenNameFilters = ruleSet.screenNameFilters
              , screenNameFiltersLogicOperator = ruleSet.screenNameFiltersLogicOperator
              , pageUrlFilters = ruleSet.pageUrlFilters
              , pageUrlFiltersLogicOperator = ruleSet.pageUrlFiltersLogicOperator;
            return Promise.resolve(validateFilters(screenNameFilters || [], '', false, screenNameFiltersLogicOperator === 'AND') && validateFilters(pageUrlFilters || [], path, true, pageUrlFiltersLogicOperator === 'AND'))
        }
        return checkRuleSet(ruleSet)
    }
    function checkRuleSet(ruleSet) {
        var ps = ruleSet.rules.map((function(r) {
            return checkRule(r)
        }
        ));
        return Promise.all(ps).then((function(results) {
            if (!results.length) {
                return true
            }
            if (ruleSet.logicOperator == 'AND') {
                return results.every((function(r) {
                    return r
                }
                ))
            } else {
                return results.some((function(r) {
                    return r
                }
                ))
            }
        }
        ))
    }
    function checkRule(rule) {
        var ps = rule.criterions.map((function(c) {
            return checkCriterion(c)
        }
        ));
        return Promise.all(ps).then((function(results) {
            if (rule.logicOperatorBetweenCriterions == 'AND') {
                return results.every((function(r) {
                    return r
                }
                ))
            } else {
                return results.some((function(r) {
                    return r
                }
                ))
            }
        }
        ))
    }
    function checkCriterion(crit) {
        return getData(crit.valueSource, crit.parameter, crit.values).then((function(data) {
            if (crit.parameter == 'dn.last_visit_ts') {
                var value = Date.now();
                value -= parseInt(crit.values[0]) * (24 * 60 * 60 * 1e3);
                crit.values[0] = value
            }
            return checkValue(data, crit.comparison, crit.values, crit.dataType)
        }
        ))
    }
    var dlHepler = null;
    function getData(source, paramName, values) {
        var _appSettings$siteVari;
        var result = null;
        var cartParameterMap = {
            'dn.cart_amount': 'basketAmount',
            'dn.cart_items': 'basketCount'
        };
        var basketInfo = (_appSettings$siteVari = appSettings.siteVariable) === null || _appSettings$siteVari === void 0 ? void 0 : _appSettings$siteVari.basketInfo;
        if (['dn.cart_amount', 'dn.cart_items'].includes(paramName) && basketInfo) {
            source = basketInfo[cartParameterMap[paramName]].source;
            paramName = basketInfo[cartParameterMap[paramName]].value
        }
        var sinfo = storage.get('session');
        var ua = window._Dn_globaL_.ua;
        if (dlHepler == null) {
            dlHepler = new DataLayerHelper(window.dataLayer)
        }
        var sourceAndParametersMap = {
            BROWSER: {
                'dn.device_name': function dnDevice_name() {
                    return ua.device.vendor + ' ' + ua.device.model
                },
                'dn.browser': function dnBrowser() {
                    return ua.browser.name
                },
                'dn.browser_ver': function dnBrowser_ver() {
                    return ua.browser.version
                },
                'dn.os': function dnOs() {
                    return ua.os.name
                },
                'dn.os_ver': function dnOs_ver() {
                    return ua.os.version
                },
                'dn.wp_enabled': function dnWp_enabled() {
                    return pushClient.detected()
                },
                'dn.sc_height': function dnSc_height() {
                    return window.screen.height
                },
                'dn.sc_width': function dnSc_width() {
                    return window.screen.width
                },
                'dn.lang': function dnLang() {
                    return (navigator.language || navigator.userLanguage || navigator.browserLanguage || 'en').split('-')[0]
                },
                'dn.tz': function dnTz() {
                    return getTimezone()
                },
                'dn.ismobile': function dnIsmobile() {
                    return ua.device.type == 'mobile'
                },
                'dn.ad_blocker': function dnAd_blocker() {
                    return false
                },
                'dn.device_cat': function dnDevice_cat() {
                    return ua.device.type[0].toUpperCase()
                },
                'dn.wp_perm': function dnWp_perm() {
                    return pushClient.getPermission()
                },
                'dn.hour': function dnHour() {
                    return [(new Date).getHours()]
                },
                'dn.week_day': function dnWeek_day() {
                    return [(new Date).getDay() % 7]
                },
                'dn.month': function dnMonth() {
                    return [(new Date).getMonth() % 12]
                }
            },
            SESSION: {
                'dn.last_visit_ts': function dnLast_visit_ts() {
                    return storage.get('extra.last_visit') || Date.now()
                },
                'dn.traffic_source': function dnTraffic_source() {
                    return getTrafficSource(sinfo)
                },
                'dn.referrer': function dnReferrer() {
                    return sinfo.referrer || ''
                },
                'dn.landing_url': function dnLanding_url() {
                    return sinfo.entry
                },
                'dn.first_visit': function dnFirst_visit() {
                    return sinfo.first
                },
                'dn.visit_duration': function dnVisit_duration() {
                    return (Date.now() - new Date(sinfo.date).getTime()) / 6e4
                },
                'dn.visit_count': function dnVisit_count() {
                    var _jsonParse;
                    return getTotalVisitCount((_jsonParse = jsonParse(values[0])) === null || _jsonParse === void 0 ? void 0 : _jsonParse.timeAmount)
                },
                'dn.anonym': function dnAnonym() {
                    return !getContactKey()
                },
                'dn.pviv': function dnPviv() {
                    return sinfo.pviv
                },
                'dn.utm_camp': function dnUtm_camp() {
                    return sinfo.campaign
                },
                'dn.utm_m': function dnUtm_m() {
                    return sinfo.medium
                },
                'dn.utm_s': function dnUtm_s() {
                    return sinfo.source
                },
                'dn.utm_cnt': function dnUtm_cnt() {
                    return sinfo.content
                },
                'dn.utm_t': function dnUtm_t() {
                    return sinfo.term
                },
                'dn.cart_amount': function dnCart_amount() {
                    return ''
                },
                'dn.cart_items': function dnCart_items() {
                    return ''
                },
                'dn.cat_path': function dnCat_path() {
                    return storage.get('extra.last_cat') || ''
                }
            },
            DATA_LAYER: _defineProperty({}, paramName, (function() {
                return dlHepler.get(paramName)
            }
            )),
            LOCAL_STORAGE: _defineProperty({}, paramName, (function() {
                return localStorage.getItem(paramName) || ''
            }
            )),
            COOKIE: _defineProperty({}, paramName, (function() {
                return getCookie(paramName) || ''
            }
            )),
            QUERYSTRING: _defineProperty({}, paramName, (function() {
                return getQueryStringParameter(paramName) || ''
            }
            )),
            SERVER_SIDE: {
                'dn.segment': function dnSegment() {
                    return storage.get('visitor_info.segments') || []
                },
                'dn.tag': function dnTag() {
                    return storage.get('visitor_info.tags') || []
                },
                'dn.master_contact.birth_date': function dnMaster_contactBirth_date() {
                    var visitorBirthDate = storage.get('visitor_info.attrs') ? storage.get('visitor_info.attrs')['dn.master_contact.birth_date'] : null;
                    if (!visitorBirthDate)
                        return null;
                    visitorBirthDate = new Date(visitorBirthDate);
                    visitorBirthDate.setYear((new Date).getUTCFullYear());
                    return Math.floor((visitorBirthDate - new Date) / (24 * 60 * 60 * 1e3))
                }
            }
        };
        if (!sourceAndParametersMap.SERVER_SIDE.hasOwnProperty(paramName)) {
            sourceAndParametersMap.SERVER_SIDE[paramName] = function() {
                return storage.get('visitor_info.attrs') ? storage.get('visitor_info.attrs')[paramName] : null
            }
        }
        return Promise.resolve(source === 'SERVER_SIDE' ? fetchVisitorInfo() : null).then((function() {
            var _sourceAndParametersM, _sourceAndParametersM2;
            result = (_sourceAndParametersM = sourceAndParametersMap[source]) === null || _sourceAndParametersM === void 0 ? void 0 : (_sourceAndParametersM2 = _sourceAndParametersM[paramName]) === null || _sourceAndParametersM2 === void 0 ? void 0 : _sourceAndParametersM2.call(_sourceAndParametersM);
            if (result == null) {
                logError('unknown onsite parameter', paramName)
            }
            if (typeof result === 'boolean') {
                result = String(result)
            }
            return Promise.resolve(result || '')
        }
        ))
    }
    function getTrafficSource(c) {
        var result = 'direct';
        if (c.type == 'organic') {
            result = 'organic_search';
            if (c.medium == 'cpc') {
                result = 'paid_search'
            }
        }
        if (c.type == 'utm') {
            result = 'campaign'
        }
        if (c.type == 'referral') {
            result = 'referral';
            if (c.medium == 'social') {
                result = 'social'
            }
        }
        return result
    }
    var validateFiltersOperators = {
        EQUALS: function EQUALS(filterValues, currentValue) {
            return filterValues[0] == currentValue
        },
        NOT_EQUALS: function NOT_EQUALS(filterValues, currentValue) {
            return filterValues[0] != currentValue
        },
        LIKE: function LIKE(filterValues, currentValue) {
            return currentValue.includes(filterValues[0])
        },
        NOT_LIKE: function NOT_LIKE(filterValues, currentValue) {
            return !currentValue.includes(filterValues[0])
        },
        STARTS_WITH: function STARTS_WITH(filterValues, currentValue) {
            return currentValue.startsWith(filterValues[0])
        },
        NOT_STARTS_WITH: function NOT_STARTS_WITH(filterValues, currentValue) {
            return !currentValue.startsWith(filterValues[0])
        },
        ENDS_WITH: function ENDS_WITH(filterValues, currentValue) {
            return currentValue.endsWith(filterValues[0])
        },
        NOT_ENDS_WITH: function NOT_ENDS_WITH(filterValues, currentValue) {
            return !currentValue.endsWith(filterValues[0])
        },
        IN: function IN(filterValues, currentValue) {
            return filterValues.includes(currentValue)
        },
        NOT_IN: function NOT_IN(filterValues, currentValue) {
            return !filterValues.includes(currentValue)
        },
        GREATER_THAN: function GREATER_THAN(filterValues, currentValue) {
            return currentValue > filterValues[0]
        },
        GREATER_EQUAL: function GREATER_EQUAL(filterValues, currentValue) {
            return currentValue >= filterValues[0]
        },
        LESS_THAN: function LESS_THAN(filterValues, currentValue) {
            return currentValue < filterValues[0]
        },
        LESS_EQUAL: function LESS_EQUAL(filterValues, currentValue) {
            return currentValue <= filterValues[0]
        }
    };
    function validateFilters(filters, currentValue, isURLFilter, isAnd) {
        if (!filters.length) {
            return true
        }
        return filters[isAnd ? 'every' : 'some']((function(filter) {
            var operator = filter.operator
              , filterValues = filter.value;
            if (isURLFilter) {
                filterValues = filterValues.map((function(urlFilterValue) {
                    try {
                        var url = new URL(urlFilterValue);
                        return url.pathname + url.search + url.hash
                    } catch (error) {
                        return urlFilterValue
                    }
                }
                ))
            }
            return validateFiltersOperators[operator](filterValues, currentValue)
        }
        ))
    }
    function checkValue(currentValue, operator, filterValues, dataType) {
        if (dataType == 'BOOL') {
            currentValue += '';
            filterValues[0] += ''
        }
        if (dataType == 'INT') {
            currentValue = parseInt(currentValue) || 0;
            for (var i = 0; i < filterValues.length; i++) {
                filterValues[i] = parseInt(filterValues[i]) || 0
            }
        }
        if (dataType == 'VISITCOUNTPASTXDAYS') {
            filterValues[0] = (JSON.parse(filterValues[0]) || {}).count
        }
        if (dataType == 'TEXT') {
            currentValue = (currentValue + '').toLowerCase();
            for (var _i = 0; _i < filterValues.length; _i++) {
                filterValues[_i] = (filterValues[_i] + '').toLowerCase()
            }
        }
        if (dataType == 'BIRTH') {
            currentValue = parseInt(currentValue) || 0;
            filterValues[0] = parseInt(filterValues[0]) || 0;
            if (filterValues[0] === 0) {
                return currentValue === filterValues[0]
            } else if (filterValues[0] < 0) {
                return currentValue > filterValues[0]
            } else {
                return currentValue < filterValues[0]
            }
        }
        switch (operator) {
        case 'EQUALS':
            {
                if (filterValues[0] == currentValue)
                    return true
            }
            break;
        case 'NOT_EQUALS':
            {
                if (filterValues[0] != currentValue)
                    return true
            }
            break;
        case 'LIKE':
            {
                if (currentValue.includes(filterValues[0]))
                    return true
            }
            break;
        case 'NOT_LIKE':
            {
                if (!currentValue.includes(filterValues[0]))
                    return true
            }
            break;
        case 'STARTS_WITH':
            {
                if (currentValue.startsWith(filterValues[0]))
                    return true
            }
            break;
        case 'NOT_STARTS_WITH':
            {
                if (!currentValue.startsWith(filterValues[0]))
                    return true
            }
            break;
        case 'ENDS_WITH':
            {
                if (currentValue.endsWith(filterValues[0]))
                    return true
            }
            break;
        case 'NOT_ENDS_WITH':
            {
                if (!currentValue.endsWith(filterValues[0]))
                    return true
            }
            break;
        case 'IN':
            if (Array.isArray(currentValue) && filterValues.some((function(filterValue) {
                return currentValue.includes(filterValue)
            }
            ))) {
                return true
            }
            if (filterValues.includes(currentValue)) {
                return true
            }
            break;
        case 'NOT_IN':
            if (Array.isArray(currentValue) && !filterValues.some((function(filterValue) {
                return currentValue.includes(filterValue)
            }
            ))) {
                return true
            }
            if (!filterValues.includes(currentValue)) {
                return true
            }
            break;
        case 'GREATER_THAN':
            {
                if (currentValue > filterValues[0])
                    return true
            }
            break;
        case 'GREATER_EQUAL':
            {
                if (currentValue >= filterValues[0])
                    return true
            }
            break;
        case 'LESS_THAN':
            {
                if (currentValue < filterValues[0])
                    return true
            }
            break;
        case 'LESS_EQUAL':
            {
                if (currentValue <= filterValues[0])
                    return true
            }
            break
        }
        return false
    }
    function registerInlineTargetListener() {
        window.addEventListener('message', (function(event) {
            if (!event.data || !event.data._dn_inline_target_selector) {
                return
            }
            var eventData = event.data;
            var message = eventData.message;
            if (message !== 'start') {
                return
            }
            if (!window._Dn_globaL_.inlineTargetSelector) {
                window._Dn_globaL_.inlineTargetSelector = new InlineTargetSelector(eventData.keyword,event.source)
            }
            window._Dn_globaL_.inlineTargetSelector.initialize().then((function(details) {
                event.source.postMessage({
                    message: 'dnInlineTargetSelectorActive',
                    details: details
                }, '*')
            }
            )).catch((function(errorDetails) {
                event.source.postMessage({
                    message: 'dnInlineTargetSelectorError',
                    details: errorDetails
                }, '*')
            }
            ))
        }
        ))
    }
    function InlineTargetSelector(keyword, adminPanelWindow) {
        this.keyword = keyword;
        this.adminPanelWindow = adminPanelWindow;
        this.targetableNodes = [];
        this.selectedQuery = '';
        this.selectorOverlayEl = null;
        this.initializeTime = null;
        this.statusMessageCount = 0;
        this.processTargetCount = 0;
        this.maxProcessTargetTryCount = 5;
        var _this = this;
        var targets = [];
        var highlightNodes = [];
        var confirmButton = null;
        var retryButton = null;
        var refreshButton = null;
        this.initialize = function() {
            return new Promise((function(resolve, reject) {
                if (!keyword) {
                    reject({
                        text: 'inlineTargetSelector.noKeyword'
                    })
                }
                if (_this.initializeTime) {
                    resolve(activeStatusMessage());
                    return
                }
                try {
                    createOverlay(keyword);
                    _this.initializeTime = new Date;
                    resolve(activeStatusMessage())
                } catch (error) {
                    console.error(error);
                    reject({
                        text: 'inlineTargetSelector.unhandledError',
                        description: error.toString()
                    })
                }
            }
            ))
        }
        ;
        this.selectedQueryResultCount = function() {
            return document.querySelectorAll(_this.selectedQuery).length
        }
        ;
        function createOverlay() {
            _this.selectorOverlayEl = document.createElement('div');
            _this.selectorOverlayEl.className = 'dnitgs-overlay';
            _this.selectorOverlayEl.innerHTML = selectorOverlayHtml;
            var collapseToggleButton = _this.selectorOverlayEl.querySelector('#dnitgs-targets-toggle');
            collapseToggleButton.addEventListener('click', (function() {
                _this.selectorOverlayEl.classList.toggle('dnitgs-overlay_collapsed')
            }
            ));
            confirmButton = _this.selectorOverlayEl.querySelector('#dnitgs-confirm-button');
            confirmButton.addEventListener('click', (function() {
                console.log({
                    message: 'dnInlineTargetConfirmed',
                    query: _this.selectedQuery
                });
                _this.processTargetCount = _this.maxProcessTargetTryCount - 1;
                if (!_this.adminPanelWindow) {
                    return
                }
                _this.adminPanelWindow.postMessage({
                    message: 'dnInlineTargetConfirmed',
                    details: {
                        query: _this.selectedQuery,
                        targetCount: _this.selectedQueryResultCount()
                    }
                }, '*')
            }
            ));
            retryButton = _this.selectorOverlayEl.querySelector('#dnitgs-retry-button');
            retryButton.addEventListener('click', (function() {
                _this.processTargetCount = _this.maxProcessTargetTryCount - 1;
                processTargets(_this.keyword)
            }
            ));
            refreshButton = _this.selectorOverlayEl.querySelector('#dnitgs-refresh-button');
            refreshButton.addEventListener('click', (function() {
                _this.processTargetCount = _this.maxProcessTargetTryCount - 1;
                processTargets(_this.keyword)
            }
            ));
            processTargets(_this.keyword);
            var selectorOverlayStyleEl = document.createElement('style');
            selectorOverlayStyleEl.innerHTML = selectorOverlayStyle;
            document.head.appendChild(selectorOverlayStyleEl);
            document.body.appendChild(_this.selectorOverlayEl);
            setTimeout((function() {
                sendHealthStatus()
            }
            ), 5e3)
        }
        function processTargets(keyword) {
            _this.targetableNodes = Array.prototype.slice.call(document.querySelectorAll('[class*=' + keyword + ']:not([class*=dnitgs]), [id*=' + keyword + ']:not([class*=dnitgs])'));
            var targetableNodeCount = _this.targetableNodes.length;
            _this.processTargetCount++;
            toggleNoTargetableNodeInfo(!targetableNodeCount);
            targets = optimizedTargets(_this.targetableNodes);
            highlightNodes = optimizedHighlightedNodes(targets);
            addHighlights(highlightNodes);
            var listEl = _this.selectorOverlayEl.querySelector('#dnitgs-targets');
            addTargets(listEl, targets);
            console.log('tries: ', _this.processTargetCount);
            if (_this.processTargetCount <= _this.maxProcessTargetTryCount) {
                refreshButton.classList.add('dnitgs-button_disabled', 'dnitgs-searching');
                refreshButton.setAttribute('disabled', 'disabled');
                refreshButton.setAttribute('title', 'Searching...');
                setTimeout((function() {
                    processTargets(keyword)
                }
                ), 1e3)
            } else {
                refreshButton.classList.remove('dnitgs-button_disabled', 'dnitgs-searching');
                refreshButton.removeAttribute('disabled');
                refreshButton.setAttribute('title', 'Search Again')
            }
        }
        function optimizedTargets(targetableNodes) {
            var optimizedTargets = [];
            targetableNodesLoop: for (var i = 0; i < targetableNodes.length; i++) {
                var targetableNode = targetableNodes[i];
                if (!targetableNode.id && !targetableNode.className) {
                    continue targetableNodesLoop
                }
                var queryObject = {
                    tag: targetableNode.tagName.toLowerCase(),
                    id: targetableNode.id && '#' + targetableNode.id || '',
                    class: targetableNode.className && '.' + targetableNode.className.split(' ').join('.') || ''
                };
                var idQuery = queryObject.id;
                var taglessQuery = idQuery + queryObject.class;
                var fullQuery = queryObject.tag + taglessQuery;
                var queryTypes = [{
                    tag: '',
                    class: '',
                    query: idQuery,
                    results: idQuery ? document.querySelectorAll(idQuery) : []
                }, {
                    tag: '',
                    query: taglessQuery,
                    results: document.querySelectorAll(taglessQuery)
                }, {
                    query: fullQuery,
                    results: document.querySelectorAll(fullQuery)
                }];
                var optimizedResultCount = 0;
                var optimizedResult = null;
                queryResultsLoop: for (var j = 0; j < queryTypes.length; j++) {
                    var queryType = queryTypes[j];
                    var resultCount = queryType.results.length;
                    if (resultCount === 0) {
                        continue queryResultsLoop
                    }
                    if (resultCount === 1) {
                        optimizedResult = queryType;
                        break queryResultsLoop
                    }
                    if (optimizedResultCount === 0 || resultCount < optimizedResultCount) {
                        optimizedResult = queryType;
                        optimizedResultCount = resultCount;
                        continue queryResultsLoop
                    }
                }
                var optimizedTarget = Object.assign({}, queryObject, optimizedResult);
                if (!optimizedTarget || optimizedTargets.some((function(previousTarget) {
                    return previousTarget.query === optimizedTarget.query
                }
                ))) {
                    continue targetableNodesLoop
                }
                optimizedTargets.push(optimizedTarget)
            }
            return optimizedTargets
        }
        function optimizedHighlightedNodes(targets) {
            for (var i = 0; i < targets.length; i++) {
                var target = targets[i];
                for (var j = 0; j < target.results.length; j++) {
                    var resultNode = target.results[j];
                    var sameResult = highlightNodes.find((function(previousResult) {
                        return previousResult.node === resultNode
                    }
                    ));
                    if (sameResult) {
                        sameResult.queries.push(target.query)
                    } else {
                        highlightNodes.push({
                            node: resultNode,
                            queries: [target.query]
                        })
                    }
                }
            }
            return highlightNodes
        }
        function toggleNoTargetableNodeInfo(hasNoTargets) {
            var noResultContainer = _this.selectorOverlayEl.querySelector('#dnitgs-no-results');
            var hasResultsContainer = _this.selectorOverlayEl.querySelector('#dnitgs-has-results');
            var keywordEl = noResultContainer.querySelector('#dnitgs-keyword');
            keywordEl.innerText = _this.keyword;
            var retryingTextEl = noResultContainer.querySelector('#dnitgs-retrying');
            var retryButton = noResultContainer.querySelector('#dnitgs-retry-button');
            if (hasNoTargets) {
                noResultContainer.classList.remove('dnitgs-hidden');
                hasResultsContainer.classList.add('dnitgs-hidden')
            } else {
                noResultContainer.classList.add('dnitgs-hidden');
                hasResultsContainer.classList.remove('dnitgs-hidden')
            }
            if (_this.processTargetCount > _this.maxProcessTargetTryCount) {
                retryingTextEl.classList.add('dnitgs-hidden');
                retryButton.classList.remove('dnitgs-button_disabled');
                retryButton.removeAttribute('disabled')
            } else {
                retryingTextEl.classList.remove('dnitgs-hidden');
                retryButton.classList.add('dnitgs-button_disabled');
                retryButton.setAttribute('disabled', 'disabled')
            }
        }
        var listItemTemplate = document.createElement('li');
        listItemTemplate.className = 'dnitgs-target dnitgs-target-item';
        listItemTemplate.innerHTML = "\n  <div class=\"dnitgs-target-label\">\n    <span class=\"dnitgs-target-tag\"></span>\n    <span class=\"dnitgs-target-id\"></span>\n    <span class=\"dnitgs-target-class\"></span>\n  </div>\n  <div class=\"dnitgs-target-count\"></div>\n  ";
        var targetPropsMap = ['tag', 'id', 'class'];
        function addTargets(targetListEl, targets) {
            var itemsToBeRemoved = Array.prototype.slice.call(_this.selectorOverlayEl.querySelectorAll('[data-dn-inline-query]'));
            for (var i = 0; i < targets.length; i++) {
                var target = targets[i];
                var alreadyAddedItemEl = _this.selectorOverlayEl.querySelector('[data-dn-inline-query="' + target.query + '"]');
                if (alreadyAddedItemEl) {
                    itemsToBeRemoved = itemsToBeRemoved.filter((function(item) {
                        return item.dataset.dnInlineQuery !== target.query
                    }
                    ));
                    var countEl = alreadyAddedItemEl.querySelector('.dnitgs-target-count');
                    countEl.innerText = target.results.length;
                    continue
                }
                var targetListItemEl = listItemTemplate.cloneNode(true);
                targetListItemEl.dataset.dnInlineQuery = target.query;
                targetListItemEl.addEventListener('click', (function(event) {
                    selectTarget(this, targetListEl)
                }
                ));
                for (var j = 0; j < targetPropsMap.length; j++) {
                    var propName = targetPropsMap[j];
                    var propValue = target[propName];
                    var el = targetListItemEl.querySelector('.dnitgs-target-' + propName);
                    if (!propValue) {
                        el.remove()
                    } else {
                        el.innerText = propValue
                    }
                }
                var count = target.results.length;
                var countEl = targetListItemEl.querySelector('.dnitgs-target-count');
                countEl.innerText = count;
                if (!_this.selectedQuery && count === 1) {
                    selectTarget(targetListItemEl, targetListEl)
                }
                targetListEl.appendChild(targetListItemEl)
            }
            for (var i = 0; i < itemsToBeRemoved.length; i++) {
                itemsToBeRemoved[i].remove()
            }
        }
        function selectTarget(targetEl, targetListEl) {
            _this.selectedQuery = targetEl.dataset.dnInlineQuery;
            var selectedEl = targetListEl.querySelector('.dnitgs-target-item_selected');
            if (selectedEl) {
                selectedEl.classList.remove('dnitgs-target-item_selected')
            }
            var selectedHighlightLayers = document.querySelectorAll('.dnitgs-highlight-layer_selected');
            for (var j = 0; j < selectedHighlightLayers.length; j++) {
                selectedHighlightLayers[j].classList.remove('dnitgs-highlight-layer_selected')
            }
            targetEl.classList.add('dnitgs-target-item_selected');
            var targetedHighlightLayers = document.querySelectorAll(_this.selectedQuery + '>.dnitgs-highlight-layer');
            for (var j = 0; j < targetedHighlightLayers.length; j++) {
                targetedHighlightLayers[j].classList.add('dnitgs-highlight-layer_selected')
            }
            document.querySelector(_this.selectedQuery).scrollIntoView({
                behavior: "smooth",
                block: "nearest"
            });
            confirmButton.classList.remove('dnitgs-button_disabled');
            confirmButton.removeAttribute('disabled')
        }
        function addHighlights(highlightNodes) {
            for (var i = 0; i < highlightNodes.length; i++) {
                var resultNode = highlightNodes[i].node;
                if (resultNode.querySelector('.dnitgs-highlight-layer')) {
                    continue
                }
                var highlightLayerEl = document.createElement('div');
                highlightLayerEl.className = 'dnitgs-highlight-layer';
                var queries = highlightNodes[i].queries;
                if (queries.length > 1) {
                    var highlightDropdownEl = document.createElement('div');
                    highlightDropdownEl.className = 'dnitgs-highlight-dropdown dnitgs-hidden';
                    highlightLayerEl.addEventListener('click', (function(event) {
                        event.stopPropagation();
                        var x = event.offsetX
                          , y = event.offsetY
                          , rect = this.getBoundingClientRect()
                          , dropdownEl = this.querySelector('.dnitgs-highlight-dropdown');
                        closeOpenDropdowns();
                        dropdownEl.classList.remove('dnitgs-hidden');
                        dropdownEl.style.top = Math.min(rect.height, Math.max(y - 20, 0)) + 'px';
                        dropdownEl.style.left = Math.min(rect.width, Math.max(x - 20, 0)) + 'px'
                    }
                    ));
                    for (var j = 0; j < queries.length; j++) {
                        var query = queries[j];
                        var highlightDropdownOptionEl = document.createElement('div');
                        highlightDropdownOptionEl.className = 'dnitgs-highlight-dropdown-option';
                        highlightDropdownOptionEl.innerText = query;
                        highlightDropdownOptionEl.addEventListener('click', (function(event) {
                            event.stopPropagation();
                            var dropdownEl = this.parentNode;
                            dropdownEl.classList.add('dnitgs-hidden');
                            selectTarget(document.querySelector('.dnitgs-target-item[data-dn-inline-query="' + this.innerText + '"]'), document.querySelector('#dnitgs-targets'))
                        }
                        ));
                        highlightDropdownEl.appendChild(highlightDropdownOptionEl)
                    }
                    highlightLayerEl.appendChild(highlightDropdownEl)
                } else {
                    highlightLayerEl.addEventListener('click', (function(event) {
                        event.stopPropagation();
                        closeOpenDropdowns();
                        selectTarget(document.querySelector('.dnitgs-target-item[data-dn-inline-query="' + queries[0] + '"]'), document.querySelector('#dnitgs-targets'))
                    }
                    ))
                }
                resultNode.appendChild(highlightLayerEl);
                var nodePositionType = getComputedStyle(resultNode).position;
                if (!nodePositionType || nodePositionType === 'static') {
                    resultNode.style.cssText += 'position: relative !important;'
                }
            }
        }
        function closeOpenDropdowns() {
            var openDropdowns = document.querySelectorAll('.dnitgs-highlight-dropdown:not(.dnitgs-hidden)');
            for (var i = 0; i < openDropdowns.length; i++) {
                openDropdowns[i].classList.add('dnitgs-hidden')
            }
        }
        function activeStatusMessage() {
            return {
                keyword: _this.keyword,
                targetableCount: _this.targetableNodes.length,
                initializeTime: _this.initializeTime
            }
        }
        function sendHealthStatus() {
            var isHealthy = !!document.querySelector('.dnitgs-targets-container');
            if (!_this.adminPanelWindow) {
                return
            }
            _this.adminPanelWindow.postMessage({
                message: 'dnInlineTargetSelector' + (isHealthy ? 'Active' : 'Error'),
                details: isHealthy ? activeStatusMessage() : {
                    text: 'inlineTargetSelector.overlayNotExist'
                }
            }, '*');
            _this.statusMessageCount++;
            if (isHealthy && _this.statusMessageCount < 200) {
                setTimeout(sendHealthStatus, 5e3)
            }
        }
    }
    var selectorOverlayStyle = "\n:root {\n  --dnitgs-color-highlight-overlay: hsla(221, 96%, 53%, 0.15);\n  --dnitgs-color-highlight-overlay-hover: hsla(221, 96%, 53%, 0.35);\n  --dnitgs-color-highlight-overlay-selected: hsla(161.93, 82.18%, 39.61%, 0.35);\n}\n.dnitgs-overlay {\n  --dnitgs-color-surface: hsl(0, 0%, 100%);\n  --dnitgs-color-surface-transparent: hsla(0, 0%, 100%, 0.9);\n\n  --dnitgs-color-foreground: hsl(0, 0%, 7.06%);\n\n  --dnitgs-color-primary: hsl(221, 96%, 53%);\n  --dnitgs-color-primary-dark: hsl(221, 96%, 43%);\n  --dnitgs-color-primary-light: hsl(221, 96%, 87%);\n  --dnitgs-color-primary-lighter: hsl(221, 96%, 94%);\n  \n  --dnitgs-color-primary-transparent: hsla(221, 96%, 53%, 0.9);\n  --dnitgs-color-primary-light-transparent: hsla(221, 96%, 87%, 0.9);\n  --dnitgs-color-primary-lighter-transparent: hsla(221, 96%, 94%, 0.9);\n  \n  --dnitgs-color-secondary: hsl(220, 95.12%, 91.96%);\n  --dnitgs-color-secondary-dark: hsl(220, 95.12%, 81.96%);\n  \n  --dnitgs-color-disabled: hsl(205.71, 25.93%, 94.71%);\n  \n  --dnitgs-color-tag: hsl(180, 88.35%, 14.44%);\n  --dnitgs-color-id: hsl(0, 92.18%, 26.25%);\n  --dnitgs-color-class: hsl(300, 86.11%, 23.52%);\n\n  position: fixed !important;\n  right: 0 !important;\n  top: 50% !important;\n  width: 200px !important;\n  border-radius: 8px 0 0 8px !important;\n  background-color: var(--dnitgs-color-surface-transparent) !important;\n  color: var(--dnitgs-color-foreground) !important;\n  backdrop-filter: blur(5px) !important;\n  box-shadow: 0 1px 2px rgba(0,0,0,.08), 0 1px 4px rgba(0,2,38,.12) !important;\n  font-family: Helvetica, Arial, sans-serif !important;\n  z-index: 2147483647 !important;\n  transform: translate(0, -50%) !important;\n  transition: 0.2s ease-in-out !important;\n}\n.dnitgs-overlay.dnitgs-overlay_collapsed {\n  transform: translate(200px, -50%) !important;\n  box-shadow: none !important;;\n}\n\n.dnitgs-targets-container {\n  width: 100%;\n  padding: 6px !important;\n  border-radius: 8px 0 0 8px !important;\n}\n\n.dnitgs-button {\n  display: flex !important;\n  align-items: center !important;\n  justify-content: center !important;\n  padding: 4px 6px !important;\n  transition: background-color 0.2s ease-in-out !important;\n  border: none !important;\n  outline: 0 !important;\n  border-radius: 8px !important;\n}\n.dnitgs-button.dnitgs-primary-button {\n  background-color: var(--dnitgs-color-primary) !important;\n  color: var(--dnitgs-color-surface) !important;\n}\n.dnitgs-button.dnitgs-primary-button:hover {\n  background-color: var(--dnitgs-color-primary-dark) !important;\n}\n.dnitgs-button.dnitgs-secondary-button {\n  background-color: var(--dnitgs-color-secondary) !important;\n  color: var(--dnitgs-color-primary) !important;\n}\n.dnitgs-button.dnitgs-secondary-button:hover {\n  background-color: var(--dnitgs-color-secondary-dark) !important;\n}\n.dnitgs-button.dnitgs-button_disabled, .dnitgs-button.dnitgs-button_disabled:hover {\n  background-color: var(--dnitgs-color-disabled) !important;\n  color: var(--dnitgs-color-foreground) !important;\n  cursor: not-allowed;\n}\n\n#dnitgs-targets-toggle {\n  position: absolute !important;\n  top: calc(50% - 24px) !important;\n  left: -24px;\n  height: 48px;\n  width: 24px;\n  border-radius: 12px 0 0 12px !important;\n  padding: 0 !important; \n  box-shadow: 0 1px 2px rgba(0,0,0,.08), 0 1px 4px rgba(0,2,38,.12) !important;\n}\n#dnitgs-targets-toggle > svg {\n  transition: transform 0.2s ease-in-out;\n  transform: rotate(0);\n  transform-origin: center;\n}\n.dnitgs-overlay.dnitgs-overlay_collapsed > #dnitgs-targets-toggle > svg {\n  transform: rotate(180deg);\n}\n.dnitgs-targets-header {\n  font-size: 16px !important;\n  font-weight: bold !important;\n}\n#dnitgs-targets {\n  list-style: none !important;\n  padding: 0 !important;\n  margin: 0 0 8px 0 !important;\n}\n#dnitgs-target-template {\n  display: none !important;\n}\n.dnitgs-target {\n  display: flex !important;\n  gap: 2px !important;\n  justify-content: space-between !important;\n  padding: 4px 8px !important;\n  border-radius: 6px !important;\n}\n.dnitgs-target-header {\n  font-weight: bold !important;\n}\n.dnitgs-target-item {\n  transition: background-color 0.2s ease-in-out !important;\n  cursor: pointer;\n}\n.dnitgs-target-item:hover {\n  background-color: var(--dnitgs-color-primary-lighter-transparent) !important;\n}\n.dnitgs-target-item_selected,\n.dnitgs-target-item_selected:hover{\n  background-color: var(--dnitgs-color-primary-light-transparent) !important;\n}\n@keyframes target-highlight {\n  from {\n    background-color: transparent;\n  }\n  to {\n    background-color: var(--dnitgs-color-primary-lighter-transparent);\n  }\n}\n.dnitgs-target-item_highlighted {\n  animation-name: target-highlight;\n  animation-duration: 2s;\n  animation-delay: 0.5s;\n  animation-iteration-count: infinite;\n  animation-direction: alternate;\n  animation-timing-function: ease-in-out;\n  transition: none !important;\n}\n\n.dnitgs-target-label {\n  display: flex !important;\n}\n.dnitgs-target-tag {\n  color: var(--dnitgs-color-tag) !important;\n}\n.dnitgs-target-id {\n  color: var(--dnitgs-color-id) !important;\n}\n.dnitgs-target-class {\n  color: var(--dnitgs-color-class) !important;\n}\n.dnitgs-buttons-container {\n  display:flex !important;\n}\n\n#dnitgs-confirm-button {\n  flex-grow: 1 !important;\n  margin-right: 6px !important;\n}\n\n#dnitgs-retry-button {\n  width: 100% !important\n}\n\n#dnitgs-refresh-button {\n  width: 28px !important;\n  height: 28px !important;\n  padding: 4px !important;\n}\n#dnitgs-refresh-button > svg {\n  width: 100% !important;\n  height: 100% !important;\n  // transform: rotate(0);\n  transform-origin: 50% 57% !important;\n}\n@keyframes refresh-rotate {\n  from {\n    transform: rotate(0);\n  }\n  to {\n    transform: rotate(360deg);\n  }\n}\n#dnitgs-refresh-button.dnitgs-searching > svg {\n  animation-name: refresh-rotate;\n  animation-duration: 1s;\n  animation-iteration-count: infinite;\n  animation-timing-function: linear;\n}\n\n#dnitgs-highlight-layer-template {\n  display: none !important;\n}\n.dnitgs-highlight-layer {\n  --dnitgs-color-highlight-foreground: hsl(0, 0%, 7.06%);\n  --dnitgs-color-highlight-surface: hsl(0, 0%, 100%);\n  --dnitgs-color-highlight-primary-light: hsl(221, 96%, 87%);\n  position: absolute !important;\n  top: 0 !important;\n  left: 0 !important;\n  width: 100% !important;\n  height: 100% !important;\n  transition: background-color 0.2s ease-in-out;\n  background-color: var(--dnitgs-color-highlight-overlay);\n  z-index: 2147483646 !important;\n  cursor: pointer;\n}\n.dnitgs-highlight-layer:hover {\n  background-color: var(--dnitgs-color-highlight-overlay-hover);\n}\n.dnitgs-highlight-layer.dnitgs-highlight-layer_selected,\n.dnitgs-highlight-layer.dnitgs-highlight-layer_selected:hover {\n  background-color: var(--dnitgs-color-highlight-overlay-selected);\n}\n.dnitgs-highlight-dropdown {\n  background-color: var(--dnitgs-color-highlight-surface) !important;\n  color: var(--dnitgs-color-highlight-foreground) !important;\n  border-radius: 8px;\n  position: absolute;\n}\n.dnitgs-highlight-dropdown-option {\n  padding: 4px 8px;\n  transition: background-color 0.2s ease-in-out !important;\n  cursor: pointer;\n}\n.dnitgs-highlight-dropdown-option:first-child {\n  border-radius: 8px 8px 0 0;\n}\n.dnitgs-highlight-dropdown-option:last-child {\n  border-radius: 0 0 8px 8px;\n}\n.dnitgs-highlight-dropdown-option:hover {\n  background-color: var(--dnitgs-color-highlight-primary-light) !important;\n}\n.dnitgs-highlight-dropdown-option_selected, .dnitgs-highlight-dropdown-option_selected:hover {\n  background-color: var(--dnitgs-color-highlight-primary-light) !important;\n}\n.dnitgs-hidden {\n  display: none !important;\n}\n";
    var selectorOverlayHtml = "\n<button\n  type=\"button\"\n  id=\"dnitgs-targets-toggle\"\n  class=\"dnitgs-button dnitgs-primary-button\"\n>\n  <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\">\n    <g id=\"Arrow / Chevron_Right\">\n    <path id=\"Vector\" d=\"M9 5L16 12L9 19\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n    </g>\n  </svg>\n</button>\n<div id=\"dnitgs-no-results\" class=\"dnitgs-targets-container\">\n  No targetable nodes found with \"<span id=\"dnitgs-keyword\"></span>\" keyword. <span id=\"dnitgs-retrying\">Searching...</span>\n  <button\n    id=\"dnitgs-retry-button\"\n    class=\"dnitgs-button dnitgs-primary-button dnitgs-button_disabled\"\n    disabled\n  >\n    Search Again\n  </button>\n</div>\n<div id=\"dnitgs-has-results\" class=\"dnitgs-targets-container\">\n  <ul id=\"dnitgs-targets\">\n    <li class=\"dnitgs-target dnitgs-target-header\">\n      <div class=\"dnitgs-target-label\">Selector</div>\n      <div class=\"dnitgs-target-count\">Target(s)</div>\n    </li>\n    <li id=\"dnitgs-target-template\" class=\"dnitgs-target dnitgs-target-item\">\n      <div class=\"dnitgs-target-label\">\n        <span class=\"dnitgs-target-tag\"></span>\n        <span class=\"dnitgs-target-id\"></span>\n        <span class=\"dnitgs-target-class\"></span>\n      </div>\n      <div class=\"dnitgs-target-count\"></div>\n    </li>\n  </ul>\n  <div class=\"dnitgs-buttons-container\">\n    <button \n      type=\"button\"\n      id=\"dnitgs-confirm-button\"\n      class=\"dnitgs-button dnitgs-primary-button dnitgs-button_disabled\"\n      disabled\n    >\n      Confirm Target\n    </button>\n    <button \n      type=\"button\"\n      id=\"dnitgs-refresh-button\"\n      class=\"dnitgs-button dnitgs-secondary-button dnitgs-button_disabled\"\n      title=\"Searching...\"\n      disabled\n    >\n    <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"28\" height=\"28\" viewBox=\"0 0 512 512\"><path d=\"M320,146s24.36-12-64-12A160,160,0,1,0,416,294\" style=\"fill:none;stroke:currentColor;stroke-linecap:round;stroke-miterlimit:10;stroke-width:32px\"/>\n      <polyline points=\"256 58 336 138 256 218\" style=\"fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:32px\"/>\n    </svg>\n    </button>\n  </div>\n</div>\n";
    var initialized = false;
    function getNextMessageDisplayTime() {
        return storage.getInt('extra.next_onsite_message_t')
    }
    function getOnSiteMinSecBetweenMessages() {
        var minutes = '1';
        if (isDebugMode()) {
            return 0
        }
        return parseInt(minutes) || 0
    }
    function onMessageDisplayed(message) {
        sendOnsiteEvent(message, 'DISPLAY');
        setMessageAsDisplayed(message.publicId);
        if (message.content.contentType !== 'HTML_INLINE') {
            var minTime = getOnSiteMinSecBetweenMessages();
            storage.set('extra.next_onsite_message_t', Date.now() + minTime * 1e3)
        }
    }
    function onMessageDismissed(message) {
        isPopupShowing = message.content.contentType !== 'HTML_INLINE' ? false : isPopupShowing;
        sendOnsiteEvent(message, 'DISMISS');
        setMessageAsDismissed(message.publicId);
        if (message.triggerSettings.showEveryXMinutes == 0) {
            deleteMsg(message.publicId)
        }
    }
    function onMessageClicked(message, button) {
        isPopupShowing = message.content.contentType !== 'HTML_INLINE' ? false : isPopupShowing;
        sendOnsiteEvent(message, 'CLICK', button);
        setMessageAsClicked(message.publicId);
        if (message.triggerSettings.dontShowAfterClick || !message.isRealtime) {
            deleteMsg(message.publicId)
        }
    }
    function onMessageSubDisplayed(message, subDisplayDetails) {
        sendOnsiteEvent(message, 'DISPLAY', subDisplayDetails)
    }
    var isPopupShowing = false
      , popupsIterating = false
      , inlinesIterating = false;
    function getAndShowMessages(trigger) {
        getAll().then((function(messages) {
            var popupMessages = []
              , inlineMessages = [];
            for (var i = 0; i < messages.length; i++) {
                var message = messages[i];
                (message.hasOwnProperty('inlineTarget') ? inlineMessages : popupMessages).push(message)
            }
            logInfo('inline messages: ', inlineMessages);
            logInfo('popup messages: ', popupMessages);
            function messageIterator(array, index, isInline) {
                var message = array[index];
                if (!message) {
                    if (isInline) {
                        inlinesIterating = false
                    } else {
                        popupsIterating = false
                    }
                    return
                }
                if (!isInline && isPopupShowing) {
                    messageIterator(array, -1, isInline);
                    return
                }
                if (isInline) {
                    inlinesIterating = true
                } else {
                    popupsIterating = true
                }
                checkMessage(message, trigger).then((function(canShowMessage) {
                    return canShowMessage ? showOnsiteMessage(message) : null
                }
                )).then((function(messagePrompt) {
                    if (messagePrompt) {
                        if (!isInline) {
                            isPopupShowing = true
                        }
                        messagePrompt.onDismissPopup(onMessageDismissed);
                        messagePrompt.onClickMessage(onMessageClicked);
                        if (messagePrompt.onSubDisplay) {
                            messagePrompt.onSubDisplay(onMessageSubDisplayed)
                        }
                        onMessageDisplayed(message)
                    }
                    messageIterator(array, index + 1, isInline)
                }
                ))
            }
            if (!popupsIterating) {
                messageIterator(popupMessages, 0, false)
            }
            if (!inlinesIterating) {
                messageIterator(inlineMessages, 0, true)
            }
        }
        ))
    }
    function start$1() {
        var hashAndQuery = window.location.search + window.location.hash;
        if (hashAndQuery.includes('dn_content_preview')) {
            setLogLevel('info');
            registerPreviewMessageListener()
        } else if (hashAndQuery.includes('dn_inline_target_selector')) {
            setLogLevel('info');
            registerInlineTargetListener()
        } else {
            getAll().then((function(messages) {
                start(messages.map((function(m) {
                    return m.triggerSettings
                }
                )));
                logInfo('All onsite messages', messages);
                initialized = true
            }
            ))
        }
    }
    function isInitialized() {
        return initialized
    }
    function triggerMessage(triggerSettings) {
        if (initialized) {
            if (getNextMessageDisplayTime() >= (new Date).getTime()) {
                return
            }
            return getAndShowMessages(triggerSettings)
        }
        return Promise.reject()
    }
    function registerPreviewMessageListener() {
        window.addEventListener('message', (function(event) {
            if (!event.data || !event.data._dn_onsite_message) {
                return
            }
            event.source.postMessage({
                action: 'dnPreviewMessageReceived'
            }, '*');
            var message = {
                publicId: 'preview_test',
                content: event.data.message
            };
            showOnsiteMessage(message).then((function(messagePrompt) {
                logInfo(messagePrompt);
                messagePrompt.onDismissPopup((function(a) {
                    logInfo('Preview Onsite message is dismissed')
                }
                ));
                messagePrompt.onClickMessage((function(a) {
                    logInfo('Preview Onsite message is clicked')
                }
                ))
            }
            ))
        }
        ))
    }
    var isStarted = false;
    function start(triggers) {
        for (var i = 0; i < triggers.length; i++) {
            var t = triggers[i];
            switch (t.triggerBy) {
            case 'NAVIGATION':
                registerNavigationEvent(t.delay);
                break;
            case 'ON_SCROLL':
                registerScrollEvent(t.scrollPercentage);
                break;
            case 'DENGAGE_EVENT':
                registerDengageEvent(t.eventName);
                break;
            case 'DATA_LAYER_EVENT':
                registerDataLayerEvent(t.eventName);
                break;
            case 'EXIT_INTENT':
                registerExitIntent();
                break
            }
        }
        if (navigationEventRegistered) {
            logInfo('TriggerEngine: Navigation registered, delays:', delayList)
        }
        if (scrollHandlerRegistered) {
            logInfo('TriggerEngine: Scroll trigger registered, percentages:', scrollPercentages)
        }
        if (exitIntentRegistered) {
            logInfo('TriggerEngine: Exit intent trigger registered:', exitIntentRegistered)
        }
        isStarted = true
    }
    var eventQueue = [];
    var lastExecutionTime = 0;
    function queueEvent(event) {
        var now = (new Date).getTime();
        if (event) {
            eventQueue.push(event)
        }
        if (now - lastExecutionTime > 100 && isInitialized() && eventQueue.length > 0) {
            lastExecutionTime = now;
            var trigger = eventQueue.shift();
            logInfo('TriggerEngine: Event triggered: ', trigger);
            triggerMessage(trigger)
        }
        if (eventQueue.length > 0) {
            setTimeout(queueEvent, 100)
        }
    }
    function clearEvents(name) {
        if (name) {
            eventQueue = eventQueue.filter((function(event) {
                return event.triggerBy !== name
            }
            ))
        } else {
            eventQueue.length = 0
        }
    }
    var acceptExitIntent = true;
    var minScrollPerc = 0;
    var delayList = [0];
    var navigationEventRegistered = false;
    function registerNavigationEvent(delay) {
        navigationEventRegistered = true;
        pushIfNotExists(delayList, parseFloat(delay))
    }
    var hasNavigationFired = false;
    function setNavigation(screenName) {
        waitUntil((function() {
            return isStarted
        }
        )).then((function() {
            if (hasNavigationFired) {
                storage.increment('session.pviv');
                storage.increment('extra.pview')
            } else {
                hasNavigationFired = true
            }
            clearEvents();
            acceptExitIntent = true;
            minScrollPerc = 0;
            for (var i = 0; i < delayList.length; i++) {
                setTimeout((function(delay) {
                    queueEvent({
                        triggerBy: 'NAVIGATION',
                        screenName: screenName.name ? screenName.name : screenName,
                        delay: delay
                    })
                }
                ), delayList[i] * 1e3, delayList[i])
            }
        }
        ))
    }
    var scrollHandlerRegistered = false;
    var scrollPercentages = [];
    function registerScrollEvent(scrollPercentage) {
        if (!scrollHandlerRegistered) {
            window.addEventListener('scroll', scrollHandler);
            scrollHandlerRegistered = true
        }
        pushIfNotExists(scrollPercentages, parseFloat(scrollPercentage))
    }
    function scrollHandler(e) {
        var scrollPercentage = window.scrollY / (document.body.scrollHeight - window.innerHeight) * 100;
        for (var i = 0; i < scrollPercentages.length; i++) {
            if (scrollPercentage >= scrollPercentages[i] && scrollPercentages[i] > minScrollPerc) {
                queueEvent({
                    triggerBy: 'ON_SCROLL',
                    scrollPercentage: scrollPercentages[i]
                })
            }
        }
        if (scrollPercentage > minScrollPerc) {
            minScrollPerc = scrollPercentage
        }
    }
    var dataLayerRegistered = false;
    var eventNames = [];
    function registerDataLayerEvent(eventName) {
        pushIfNotExists(eventNames, eventName);
        if (!dataLayerRegistered) {
            new DataLayerHelper(window.dataLayer,{
                listener: dataLayerListener,
                listenToPast: true
            });
            dataLayerRegistered = true
        }
    }
    function dataLayerListener(model, message) {
        if (eventNames.includes(message.event || '')) {
            queueEvent({
                triggerBy: 'DATA_LAYER_EVENT',
                eventName: message.event
            })
        }
    }
    function registerDengageEvent(eventName) {}
    var exitIntentRegistered = false;
    function registerExitIntent() {
        exitIntentRegistered = true;
        ouibounce(false, {
            aggressive: true,
            timer: 0,
            callback: function callback() {
                if (acceptExitIntent) {
                    queueEvent({
                        triggerBy: 'EXIT_INTENT'
                    });
                    acceptExitIntent = false
                }
            }
        })
    }
    var LIBVERSION = '0.7.31'
      , EMPTY = ''
      , UNKNOWN = '?'
      , FUNC_TYPE = 'function'
      , UNDEF_TYPE = 'undefined'
      , OBJ_TYPE = 'object'
      , STR_TYPE = 'string'
      , MAJOR = 'major'
      , MODEL = 'model'
      , NAME = 'name'
      , TYPE = 'type'
      , VENDOR = 'vendor'
      , VERSION = 'version'
      , ARCHITECTURE = 'architecture'
      , CONSOLE = 'console'
      , MOBILE = 'mobile'
      , TABLET = 'tablet'
      , SMARTTV = 'smarttv'
      , WEARABLE = 'wearable'
      , EMBEDDED = 'embedded'
      , UA_MAX_LENGTH = 255;
    var AMAZON = 'Amazon'
      , APPLE = 'Apple'
      , ASUS = 'ASUS'
      , BLACKBERRY = 'BlackBerry'
      , BROWSER = 'Browser'
      , CHROME = 'Chrome'
      , EDGE = 'Edge'
      , FIREFOX = 'Firefox'
      , GOOGLE = 'Google'
      , HUAWEI = 'Huawei'
      , LG = 'LG'
      , MICROSOFT = 'Microsoft'
      , MOTOROLA = 'Motorola'
      , OPERA = 'Opera'
      , SAMSUNG = 'Samsung'
      , SONY = 'Sony'
      , XIAOMI = 'Xiaomi'
      , ZEBRA = 'Zebra'
      , FACEBOOK = 'Facebook';
    var extend = function extend(regexes, extensions) {
        var mergedRegexes = {};
        for (var i in regexes) {
            if (extensions[i] && extensions[i].length % 2 === 0) {
                mergedRegexes[i] = extensions[i].concat(regexes[i])
            } else {
                mergedRegexes[i] = regexes[i]
            }
        }
        return mergedRegexes
    }
      , enumerize = function enumerize(arr) {
        var enums = {};
        for (var i = 0; i < arr.length; i++) {
            enums[arr[i].toUpperCase()] = arr[i]
        }
        return enums
    }
      , has = function has(str1, str2) {
        return _typeof(str1) === STR_TYPE ? lowerize(str2).indexOf(lowerize(str1)) !== -1 : false
    }
      , lowerize = function lowerize(str) {
        return str.toLowerCase()
    }
      , majorize = function majorize(version) {
        return _typeof(version) === STR_TYPE ? version.replace(/[^\d\.]/g, EMPTY).split('.')[0] : undefined
    }
      , trim = function trim(str, len) {
        if (_typeof(str) === STR_TYPE) {
            str = str.replace(/^\s\s*/, EMPTY).replace(/\s\s*$/, EMPTY);
            return _typeof(len) === UNDEF_TYPE ? str : str.substring(0, UA_MAX_LENGTH)
        }
    };
    var rgxMapper = function rgxMapper(ua, arrays) {
        var i = 0, j, k, p, q, matches, match;
        while (i < arrays.length && !matches) {
            var regex = arrays[i]
              , props = arrays[i + 1];
            j = k = 0;
            while (j < regex.length && !matches) {
                matches = regex[j++].exec(ua);
                if (!!matches) {
                    for (p = 0; p < props.length; p++) {
                        match = matches[++k];
                        q = props[p];
                        if (_typeof(q) === OBJ_TYPE && q.length > 0) {
                            if (q.length === 2) {
                                if (_typeof(q[1]) == FUNC_TYPE) {
                                    this[q[0]] = q[1].call(this, match)
                                } else {
                                    this[q[0]] = q[1]
                                }
                            } else if (q.length === 3) {
                                if (_typeof(q[1]) === FUNC_TYPE && !(q[1].exec && q[1].test)) {
                                    this[q[0]] = match ? q[1].call(this, match, q[2]) : undefined
                                } else {
                                    this[q[0]] = match ? match.replace(q[1], q[2]) : undefined
                                }
                            } else if (q.length === 4) {
                                this[q[0]] = match ? q[3].call(this, match.replace(q[1], q[2])) : undefined
                            }
                        } else {
                            this[q] = match ? match : undefined
                        }
                    }
                }
            }
            i += 2
        }
    }
      , strMapper = function strMapper(str, map) {
        for (var i in map) {
            if (_typeof(map[i]) === OBJ_TYPE && map[i].length > 0) {
                for (var j = 0; j < map[i].length; j++) {
                    if (has(map[i][j], str)) {
                        return i === UNKNOWN ? undefined : i
                    }
                }
            } else if (has(map[i], str)) {
                return i === UNKNOWN ? undefined : i
            }
        }
        return str
    };
    var oldSafariMap = {
        '1.0': '/8',
        1.2: '/1',
        1.3: '/3',
        '2.0': '/412',
        '2.0.2': '/416',
        '2.0.3': '/417',
        '2.0.4': '/419',
        '?': '/'
    }
      , windowsVersionMap = {
        ME: '4.90',
        'NT 3.11': 'NT3.51',
        'NT 4.0': 'NT4.0',
        2e3: 'NT 5.0',
        XP: ['NT 5.1', 'NT 5.2'],
        Vista: 'NT 6.0',
        7: 'NT 6.1',
        8: 'NT 6.2',
        8.1: 'NT 6.3',
        10: ['NT 6.4', 'NT 10.0'],
        RT: 'ARM'
    };
    var regexes = {
        browser: [[/\b(?:crmo|crios)\/([\w\.]+)/i], [VERSION, [NAME, 'Chrome']], [/edg(?:e|ios|a)?\/([\w\.]+)/i], [VERSION, [NAME, 'Edge']], [/(opera mini)\/([-\w\.]+)/i, /(opera [mobiletab]{3,6})\b.+version\/([-\w\.]+)/i, /(opera)(?:.+version\/|[\/ ]+)([\w\.]+)/i], [NAME, VERSION], [/opios[\/ ]+([\w\.]+)/i], [VERSION, [NAME, OPERA + ' Mini']], [/\bopr\/([\w\.]+)/i], [VERSION, [NAME, OPERA]], [/(kindle)\/([\w\.]+)/i, /(lunascape|maxthon|netfront|jasmine|blazer)[\/ ]?([\w\.]*)/i, /(avant |iemobile|slim)(?:browser)?[\/ ]?([\w\.]*)/i, /(ba?idubrowser)[\/ ]?([\w\.]+)/i, /(?:ms|\()(ie) ([\w\.]+)/i, /(flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron|vivaldi|iridium|phantomjs|bowser|quark|qupzilla|falkon|rekonq|puffin|brave|whale|qqbrowserlite|qq)\/([-\w\.]+)/i, /(weibo)__([\d\.]+)/i], [NAME, VERSION], [/(?:\buc? ?browser|(?:juc.+)ucweb)[\/ ]?([\w\.]+)/i], [VERSION, [NAME, 'UC' + BROWSER]], [/\bqbcore\/([\w\.]+)/i], [VERSION, [NAME, 'WeChat(Win) Desktop']], [/micromessenger\/([\w\.]+)/i], [VERSION, [NAME, 'WeChat']], [/konqueror\/([\w\.]+)/i], [VERSION, [NAME, 'Konqueror']], [/trident.+rv[: ]([\w\.]{1,9})\b.+like gecko/i], [VERSION, [NAME, 'IE']], [/yabrowser\/([\w\.]+)/i], [VERSION, [NAME, 'Yandex']], [/(avast|avg)\/([\w\.]+)/i], [[NAME, /(.+)/, '$1 Secure ' + BROWSER], VERSION], [/\bfocus\/([\w\.]+)/i], [VERSION, [NAME, FIREFOX + ' Focus']], [/\bopt\/([\w\.]+)/i], [VERSION, [NAME, OPERA + ' Touch']], [/coc_coc\w+\/([\w\.]+)/i], [VERSION, [NAME, 'Coc Coc']], [/dolfin\/([\w\.]+)/i], [VERSION, [NAME, 'Dolphin']], [/coast\/([\w\.]+)/i], [VERSION, [NAME, OPERA + ' Coast']], [/miuibrowser\/([\w\.]+)/i], [VERSION, [NAME, 'MIUI ' + BROWSER]], [/fxios\/([-\w\.]+)/i], [VERSION, [NAME, FIREFOX]], [/\bqihu|(qi?ho?o?|360)browser/i], [[NAME, '360 ' + BROWSER]], [/(oculus|samsung|sailfish)browser\/([\w\.]+)/i], [[NAME, /(.+)/, '$1 ' + BROWSER], VERSION], [/(comodo_dragon)\/([\w\.]+)/i], [[NAME, /_/g, ' '], VERSION], [/(electron)\/([\w\.]+) safari/i, /(tesla)(?: qtcarbrowser|\/(20\d\d\.[-\w\.]+))/i, /m?(qqbrowser|baiduboxapp|2345Explorer)[\/ ]?([\w\.]+)/i], [NAME, VERSION], [/(metasr)[\/ ]?([\w\.]+)/i, /(lbbrowser)/i], [NAME], [/((?:fban\/fbios|fb_iab\/fb4a)(?!.+fbav)|;fbav\/([\w\.]+);)/i], [[NAME, FACEBOOK], VERSION], [/safari (line)\/([\w\.]+)/i, /\b(line)\/([\w\.]+)\/iab/i, /(chromium|instagram)[\/ ]([-\w\.]+)/i], [NAME, VERSION], [/\bgsa\/([\w\.]+) .*safari\//i], [VERSION, [NAME, 'GSA']], [/headlesschrome(?:\/([\w\.]+)| )/i], [VERSION, [NAME, CHROME + ' Headless']], [/ wv\).+(chrome)\/([\w\.]+)/i], [[NAME, CHROME + ' WebView'], VERSION], [/droid.+ version\/([\w\.]+)\b.+(?:mobile safari|safari)/i], [VERSION, [NAME, 'Android ' + BROWSER]], [/(chrome|omniweb|arora|[tizenoka]{5} ?browser)\/v?([\w\.]+)/i], [NAME, VERSION], [/version\/([\w\.]+) .*mobile\/\w+ (safari)/i], [VERSION, [NAME, 'Mobile Safari']], [/version\/([\w\.]+) .*(mobile ?safari|safari)/i], [VERSION, NAME], [/webkit.+?(mobile ?safari|safari)(\/[\w\.]+)/i], [NAME, [VERSION, strMapper, oldSafariMap]], [/(webkit|khtml)\/([\w\.]+)/i], [NAME, VERSION], [/(navigator|netscape\d?)\/([-\w\.]+)/i], [[NAME, 'Netscape'], VERSION], [/mobile vr; rv:([\w\.]+)\).+firefox/i], [VERSION, [NAME, FIREFOX + ' Reality']], [/ekiohf.+(flow)\/([\w\.]+)/i, /(swiftfox)/i, /(icedragon|iceweasel|camino|chimera|fennec|maemo browser|minimo|conkeror|klar)[\/ ]?([\w\.\+]+)/i, /(seamonkey|k-meleon|icecat|iceape|firebird|phoenix|palemoon|basilisk|waterfox)\/([-\w\.]+)$/i, /(firefox)\/([\w\.]+)/i, /(mozilla)\/([\w\.]+) .+rv\:.+gecko\/\d+/i, /(polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf|sleipnir|obigo|mosaic|(?:go|ice|up)[\. ]?browser)[-\/ ]?v?([\w\.]+)/i, /(links) \(([\w\.]+)/i], [NAME, VERSION]],
        cpu: [[/(?:(amd|x(?:(?:86|64)[-_])?|wow|win)64)[;\)]/i], [[ARCHITECTURE, 'amd64']], [/(ia32(?=;))/i], [[ARCHITECTURE, lowerize]], [/((?:i[346]|x)86)[;\)]/i], [[ARCHITECTURE, 'ia32']], [/\b(aarch64|arm(v?8e?l?|_?64))\b/i], [[ARCHITECTURE, 'arm64']], [/\b(arm(?:v[67])?ht?n?[fl]p?)\b/i], [[ARCHITECTURE, 'armhf']], [/windows (ce|mobile); ppc;/i], [[ARCHITECTURE, 'arm']], [/((?:ppc|powerpc)(?:64)?)(?: mac|;|\))/i], [[ARCHITECTURE, /ower/, EMPTY, lowerize]], [/(sun4\w)[;\)]/i], [[ARCHITECTURE, 'sparc']], [/((?:avr32|ia64(?=;))|68k(?=\))|\barm(?=v(?:[1-7]|[5-7]1)l?|;|eabi)|(?=atmel )avr|(?:irix|mips|sparc)(?:64)?\b|pa-risc)/i], [[ARCHITECTURE, lowerize]]],
        device: [[/\b(sch-i[89]0\d|shw-m380s|sm-[pt]\w{2,4}|gt-[pn]\d{2,4}|sgh-t8[56]9|nexus 10)/i], [MODEL, [VENDOR, SAMSUNG], [TYPE, TABLET]], [/\b((?:s[cgp]h|gt|sm)-\w+|galaxy nexus)/i, /samsung[- ]([-\w]+)/i, /sec-(sgh\w+)/i], [MODEL, [VENDOR, SAMSUNG], [TYPE, MOBILE]], [/\((ip(?:hone|od)[\w ]*);/i], [MODEL, [VENDOR, APPLE], [TYPE, MOBILE]], [/\((ipad);[-\w\),; ]+apple/i, /applecoremedia\/[\w\.]+ \((ipad)/i, /\b(ipad)\d\d?,\d\d?[;\]].+ios/i], [MODEL, [VENDOR, APPLE], [TYPE, TABLET]], [/\b((?:ag[rs][23]?|bah2?|sht?|btv)-a?[lw]\d{2})\b(?!.+d\/s)/i], [MODEL, [VENDOR, HUAWEI], [TYPE, TABLET]], [/(?:huawei|honor)([-\w ]+)[;\)]/i, /\b(nexus 6p|\w{2,4}-[atu]?[ln][01259x][012359][an]?)\b(?!.+d\/s)/i], [MODEL, [VENDOR, HUAWEI], [TYPE, MOBILE]], [/\b(poco[\w ]+)(?: bui|\))/i, /\b; (\w+) build\/hm\1/i, /\b(hm[-_ ]?note?[_ ]?(?:\d\w)?) bui/i, /\b(redmi[\-_ ]?(?:note|k)?[\w_ ]+)(?: bui|\))/i, /\b(mi[-_ ]?(?:a\d|one|one[_ ]plus|note lte|max)?[_ ]?(?:\d?\w?)[_ ]?(?:plus|se|lite)?)(?: bui|\))/i], [[MODEL, /_/g, ' '], [VENDOR, XIAOMI], [TYPE, MOBILE]], [/\b(mi[-_ ]?(?:pad)(?:[\w_ ]+))(?: bui|\))/i], [[MODEL, /_/g, ' '], [VENDOR, XIAOMI], [TYPE, TABLET]], [/; (\w+) bui.+ oppo/i, /\b(cph[12]\d{3}|p(?:af|c[al]|d\w|e[ar])[mt]\d0|x9007|a101op)\b/i], [MODEL, [VENDOR, 'OPPO'], [TYPE, MOBILE]], [/vivo (\w+)(?: bui|\))/i, /\b(v[12]\d{3}\w?[at])(?: bui|;)/i], [MODEL, [VENDOR, 'Vivo'], [TYPE, MOBILE]], [/\b(rmx[12]\d{3})(?: bui|;|\))/i], [MODEL, [VENDOR, 'Realme'], [TYPE, MOBILE]], [/\b(milestone|droid(?:[2-4x]| (?:bionic|x2|pro|razr))?:?( 4g)?)\b[\w ]+build\//i, /\bmot(?:orola)?[- ](\w*)/i, /((?:moto[\w\(\) ]+|xt\d{3,4}|nexus 6)(?= bui|\)))/i], [MODEL, [VENDOR, MOTOROLA], [TYPE, MOBILE]], [/\b(mz60\d|xoom[2 ]{0,2}) build\//i], [MODEL, [VENDOR, MOTOROLA], [TYPE, TABLET]], [/((?=lg)?[vl]k\-?\d{3}) bui| 3\.[-\w; ]{10}lg?-([06cv9]{3,4})/i], [MODEL, [VENDOR, LG], [TYPE, TABLET]], [/(lm(?:-?f100[nv]?|-[\w\.]+)(?= bui|\))|nexus [45])/i, /\blg[-e;\/ ]+((?!browser|netcast|android tv)\w+)/i, /\blg-?([\d\w]+) bui/i], [MODEL, [VENDOR, LG], [TYPE, MOBILE]], [/(ideatab[-\w ]+)/i, /lenovo ?(s[56]000[-\w]+|tab(?:[\w ]+)|yt[-\d\w]{6}|tb[-\d\w]{6})/i], [MODEL, [VENDOR, 'Lenovo'], [TYPE, TABLET]], [/(?:maemo|nokia).*(n900|lumia \d+)/i, /nokia[-_ ]?([-\w\.]*)/i], [[MODEL, /_/g, ' '], [VENDOR, 'Nokia'], [TYPE, MOBILE]], [/(pixel c)\b/i], [MODEL, [VENDOR, GOOGLE], [TYPE, TABLET]], [/droid.+; (pixel[\daxl ]{0,6})(?: bui|\))/i], [MODEL, [VENDOR, GOOGLE], [TYPE, MOBILE]], [/droid.+ ([c-g]\d{4}|so[-gl]\w+|xq-a\w[4-7][12])(?= bui|\).+chrome\/(?![1-6]{0,1}\d\.))/i], [MODEL, [VENDOR, SONY], [TYPE, MOBILE]], [/sony tablet [ps]/i, /\b(?:sony)?sgp\w+(?: bui|\))/i], [[MODEL, 'Xperia Tablet'], [VENDOR, SONY], [TYPE, TABLET]], [/ (kb2005|in20[12]5|be20[12][59])\b/i, /(?:one)?(?:plus)? (a\d0\d\d)(?: b|\))/i], [MODEL, [VENDOR, 'OnePlus'], [TYPE, MOBILE]], [/(alexa)webm/i, /(kf[a-z]{2}wi)( bui|\))/i, /(kf[a-z]+)( bui|\)).+silk\//i], [MODEL, [VENDOR, AMAZON], [TYPE, TABLET]], [/((?:sd|kf)[0349hijorstuw]+)( bui|\)).+silk\//i], [[MODEL, /(.+)/g, 'Fire Phone $1'], [VENDOR, AMAZON], [TYPE, MOBILE]], [/(playbook);[-\w\),; ]+(rim)/i], [MODEL, VENDOR, [TYPE, TABLET]], [/\b((?:bb[a-f]|st[hv])100-\d)/i, /\(bb10; (\w+)/i], [MODEL, [VENDOR, BLACKBERRY], [TYPE, MOBILE]], [/(?:\b|asus_)(transfo[prime ]{4,10} \w+|eeepc|slider \w+|nexus 7|padfone|p00[cj])/i], [MODEL, [VENDOR, ASUS], [TYPE, TABLET]], [/ (z[bes]6[027][012][km][ls]|zenfone \d\w?)\b/i], [MODEL, [VENDOR, ASUS], [TYPE, MOBILE]], [/(nexus 9)/i], [MODEL, [VENDOR, 'HTC'], [TYPE, TABLET]], [/(htc)[-;_ ]{1,2}([\w ]+(?=\)| bui)|\w+)/i, /(zte)[- ]([\w ]+?)(?: bui|\/|\))/i, /(alcatel|geeksphone|nexian|panasonic|sony)[-_ ]?([-\w]*)/i], [VENDOR, [MODEL, /_/g, ' '], [TYPE, MOBILE]], [/droid.+; ([ab][1-7]-?[0178a]\d\d?)/i], [MODEL, [VENDOR, 'Acer'], [TYPE, TABLET]], [/droid.+; (m[1-5] note) bui/i, /\bmz-([-\w]{2,})/i], [MODEL, [VENDOR, 'Meizu'], [TYPE, MOBILE]], [/\b(sh-?[altvz]?\d\d[a-ekm]?)/i], [MODEL, [VENDOR, 'Sharp'], [TYPE, MOBILE]], [/(blackberry|benq|palm(?=\-)|sonyericsson|acer|asus|dell|meizu|motorola|polytron)[-_ ]?([-\w]*)/i, /(hp) ([\w ]+\w)/i, /(asus)-?(\w+)/i, /(microsoft); (lumia[\w ]+)/i, /(lenovo)[-_ ]?([-\w]+)/i, /(jolla)/i, /(oppo) ?([\w ]+) bui/i], [VENDOR, MODEL, [TYPE, MOBILE]], [/(archos) (gamepad2?)/i, /(hp).+(touchpad(?!.+tablet)|tablet)/i, /(kindle)\/([\w\.]+)/i, /(nook)[\w ]+build\/(\w+)/i, /(dell) (strea[kpr\d ]*[\dko])/i, /(le[- ]+pan)[- ]+(\w{1,9}) bui/i, /(trinity)[- ]*(t\d{3}) bui/i, /(gigaset)[- ]+(q\w{1,9}) bui/i, /(vodafone) ([\w ]+)(?:\)| bui)/i], [VENDOR, MODEL, [TYPE, TABLET]], [/(surface duo)/i], [MODEL, [VENDOR, MICROSOFT], [TYPE, TABLET]], [/droid [\d\.]+; (fp\du?)(?: b|\))/i], [MODEL, [VENDOR, 'Fairphone'], [TYPE, MOBILE]], [/(u304aa)/i], [MODEL, [VENDOR, 'AT&T'], [TYPE, MOBILE]], [/\bsie-(\w*)/i], [MODEL, [VENDOR, 'Siemens'], [TYPE, MOBILE]], [/\b(rct\w+) b/i], [MODEL, [VENDOR, 'RCA'], [TYPE, TABLET]], [/\b(venue[\d ]{2,7}) b/i], [MODEL, [VENDOR, 'Dell'], [TYPE, TABLET]], [/\b(q(?:mv|ta)\w+) b/i], [MODEL, [VENDOR, 'Verizon'], [TYPE, TABLET]], [/\b(?:barnes[& ]+noble |bn[rt])([\w\+ ]*) b/i], [MODEL, [VENDOR, 'Barnes & Noble'], [TYPE, TABLET]], [/\b(tm\d{3}\w+) b/i], [MODEL, [VENDOR, 'NuVision'], [TYPE, TABLET]], [/\b(k88) b/i], [MODEL, [VENDOR, 'ZTE'], [TYPE, TABLET]], [/\b(nx\d{3}j) b/i], [MODEL, [VENDOR, 'ZTE'], [TYPE, MOBILE]], [/\b(gen\d{3}) b.+49h/i], [MODEL, [VENDOR, 'Swiss'], [TYPE, MOBILE]], [/\b(zur\d{3}) b/i], [MODEL, [VENDOR, 'Swiss'], [TYPE, TABLET]], [/\b((zeki)?tb.*\b) b/i], [MODEL, [VENDOR, 'Zeki'], [TYPE, TABLET]], [/\b([yr]\d{2}) b/i, /\b(dragon[- ]+touch |dt)(\w{5}) b/i], [[VENDOR, 'Dragon Touch'], MODEL, [TYPE, TABLET]], [/\b(ns-?\w{0,9}) b/i], [MODEL, [VENDOR, 'Insignia'], [TYPE, TABLET]], [/\b((nxa|next)-?\w{0,9}) b/i], [MODEL, [VENDOR, 'NextBook'], [TYPE, TABLET]], [/\b(xtreme\_)?(v(1[045]|2[015]|[3469]0|7[05])) b/i], [[VENDOR, 'Voice'], MODEL, [TYPE, MOBILE]], [/\b(lvtel\-)?(v1[12]) b/i], [[VENDOR, 'LvTel'], MODEL, [TYPE, MOBILE]], [/\b(ph-1) /i], [MODEL, [VENDOR, 'Essential'], [TYPE, MOBILE]], [/\b(v(100md|700na|7011|917g).*\b) b/i], [MODEL, [VENDOR, 'Envizen'], [TYPE, TABLET]], [/\b(trio[-\w\. ]+) b/i], [MODEL, [VENDOR, 'MachSpeed'], [TYPE, TABLET]], [/\btu_(1491) b/i], [MODEL, [VENDOR, 'Rotor'], [TYPE, TABLET]], [/(shield[\w ]+) b/i], [MODEL, [VENDOR, 'Nvidia'], [TYPE, TABLET]], [/(sprint) (\w+)/i], [VENDOR, MODEL, [TYPE, MOBILE]], [/(kin\.[onetw]{3})/i], [[MODEL, /\./g, ' '], [VENDOR, MICROSOFT], [TYPE, MOBILE]], [/droid.+; (cc6666?|et5[16]|mc[239][23]x?|vc8[03]x?)\)/i], [MODEL, [VENDOR, ZEBRA], [TYPE, TABLET]], [/droid.+; (ec30|ps20|tc[2-8]\d[kx])\)/i], [MODEL, [VENDOR, ZEBRA], [TYPE, MOBILE]], [/(ouya)/i, /(nintendo) ([wids3utch]+)/i], [VENDOR, MODEL, [TYPE, CONSOLE]], [/droid.+; (shield) bui/i], [MODEL, [VENDOR, 'Nvidia'], [TYPE, CONSOLE]], [/(playstation [345portablevi]+)/i], [MODEL, [VENDOR, SONY], [TYPE, CONSOLE]], [/\b(xbox(?: one)?(?!; xbox))[\); ]/i], [MODEL, [VENDOR, MICROSOFT], [TYPE, CONSOLE]], [/smart-tv.+(samsung)/i], [VENDOR, [TYPE, SMARTTV]], [/hbbtv.+maple;(\d+)/i], [[MODEL, /^/, 'SmartTV'], [VENDOR, SAMSUNG], [TYPE, SMARTTV]], [/(nux; netcast.+smarttv|lg (netcast\.tv-201\d|android tv))/i], [[VENDOR, LG], [TYPE, SMARTTV]], [/(apple) ?tv/i], [VENDOR, [MODEL, APPLE + ' TV'], [TYPE, SMARTTV]], [/crkey/i], [[MODEL, CHROME + 'cast'], [VENDOR, GOOGLE], [TYPE, SMARTTV]], [/droid.+aft(\w)( bui|\))/i], [MODEL, [VENDOR, AMAZON], [TYPE, SMARTTV]], [/\(dtv[\);].+(aquos)/i], [MODEL, [VENDOR, 'Sharp'], [TYPE, SMARTTV]], [/\b(roku)[\dx]*[\)\/]((?:dvp-)?[\d\.]*)/i, /hbbtv\/\d+\.\d+\.\d+ +\([\w ]*; *(\w[^;]*);([^;]*)/i], [[VENDOR, trim], [MODEL, trim], [TYPE, SMARTTV]], [/\b(android tv|smart[- ]?tv|opera tv|tv; rv:)\b/i], [[TYPE, SMARTTV]], [/((pebble))app/i], [VENDOR, MODEL, [TYPE, WEARABLE]], [/droid.+; (glass) \d/i], [MODEL, [VENDOR, GOOGLE], [TYPE, WEARABLE]], [/droid.+; (wt63?0{2,3})\)/i], [MODEL, [VENDOR, ZEBRA], [TYPE, WEARABLE]], [/(quest( 2)?)/i], [MODEL, [VENDOR, FACEBOOK], [TYPE, WEARABLE]], [/(tesla)(?: qtcarbrowser|\/[-\w\.]+)/i], [VENDOR, [TYPE, EMBEDDED]], [/droid .+?; ([^;]+?)(?: bui|\) applew).+? mobile safari/i], [MODEL, [TYPE, MOBILE]], [/droid .+?; ([^;]+?)(?: bui|\) applew).+?(?! mobile) safari/i], [MODEL, [TYPE, TABLET]], [/\b((tablet|tab)[;\/]|focus\/\d(?!.+mobile))/i], [[TYPE, TABLET]], [/(phone|mobile(?:[;\/]| safari)|pda(?=.+windows ce))/i], [[TYPE, MOBILE]], [/(android[-\w\. ]{0,9});.+buil/i], [MODEL, [VENDOR, 'Generic']]],
        engine: [[/windows.+ edge\/([\w\.]+)/i], [VERSION, [NAME, EDGE + 'HTML']], [/webkit\/537\.36.+chrome\/(?!27)([\w\.]+)/i], [VERSION, [NAME, 'Blink']], [/(presto)\/([\w\.]+)/i, /(webkit|trident|netfront|netsurf|amaya|lynx|w3m|goanna)\/([\w\.]+)/i, /ekioh(flow)\/([\w\.]+)/i, /(khtml|tasman|links)[\/ ]\(?([\w\.]+)/i, /(icab)[\/ ]([23]\.[\d\.]+)/i], [NAME, VERSION], [/rv\:([\w\.]{1,9})\b.+(gecko)/i], [VERSION, NAME]],
        os: [[/microsoft (windows) (vista|xp)/i], [NAME, VERSION], [/(windows) nt 6\.2; (arm)/i, /(windows (?:phone(?: os)?|mobile))[\/ ]?([\d\.\w ]*)/i, /(windows)[\/ ]?([ntce\d\. ]+\w)(?!.+xbox)/i], [NAME, [VERSION, strMapper, windowsVersionMap]], [/(win(?=3|9|n)|win 9x )([nt\d\.]+)/i], [[NAME, 'Windows'], [VERSION, strMapper, windowsVersionMap]], [/ip[honead]{2,4}\b(?:.*os ([\w]+) like mac|; opera)/i, /cfnetwork\/.+darwin/i], [[VERSION, /_/g, '.'], [NAME, 'iOS']], [/(mac os x) ?([\w\. ]*)/i, /(macintosh|mac_powerpc\b)(?!.+haiku)/i], [[NAME, 'Mac OS'], [VERSION, /_/g, '.']], [/droid ([\w\.]+)\b.+(android[- ]x86)/i], [VERSION, NAME], [/(android|webos|qnx|bada|rim tablet os|maemo|meego|sailfish)[-\/ ]?([\w\.]*)/i, /(blackberry)\w*\/([\w\.]*)/i, /(tizen|kaios)[\/ ]([\w\.]+)/i, /\((series40);/i], [NAME, VERSION], [/\(bb(10);/i], [VERSION, [NAME, BLACKBERRY]], [/(?:symbian ?os|symbos|s60(?=;)|series60)[-\/ ]?([\w\.]*)/i], [VERSION, [NAME, 'Symbian']], [/mozilla\/[\d\.]+ \((?:mobile|tablet|tv|mobile; [\w ]+); rv:.+ gecko\/([\w\.]+)/i], [VERSION, [NAME, FIREFOX + ' OS']], [/web0s;.+rt(tv)/i, /\b(?:hp)?wos(?:browser)?\/([\w\.]+)/i], [VERSION, [NAME, 'webOS']], [/crkey\/([\d\.]+)/i], [VERSION, [NAME, CHROME + 'cast']], [/(cros) [\w]+ ([\w\.]+\w)/i], [[NAME, 'Chromium OS'], VERSION], [/(nintendo|playstation) ([wids345portablevuch]+)/i, /(xbox); +xbox ([^\);]+)/i, /\b(joli|palm)\b ?(?:os)?\/?([\w\.]*)/i, /(mint)[\/\(\) ]?(\w*)/i, /(mageia|vectorlinux)[; ]/i, /([kxln]?ubuntu|debian|suse|opensuse|gentoo|arch(?= linux)|slackware|fedora|mandriva|centos|pclinuxos|red ?hat|zenwalk|linpus|raspbian|plan 9|minix|risc os|contiki|deepin|manjaro|elementary os|sabayon|linspire)(?: gnu\/linux)?(?: enterprise)?(?:[- ]linux)?(?:-gnu)?[-\/ ]?(?!chrom|package)([-\w\.]*)/i, /(hurd|linux) ?([\w\.]*)/i, /(gnu) ?([\w\.]*)/i, /\b([-frentopcghs]{0,5}bsd|dragonfly)[\/ ]?(?!amd|[ix346]{1,2}86)([\w\.]*)/i, /(haiku) (\w+)/i], [NAME, VERSION], [/(sunos) ?([\w\.\d]*)/i], [[NAME, 'Solaris'], VERSION], [/((?:open)?solaris)[-\/ ]?([\w\.]*)/i, /(aix) ((\d)(?=\.|\)| )[\w\.])*/i, /\b(beos|os\/2|amigaos|morphos|openvms|fuchsia|hp-ux)/i, /(unix) ?([\w\.]*)/i], [NAME, VERSION]]
    };
    function UAParser(ua, extensions) {
        if (_typeof(ua) === OBJ_TYPE) {
            extensions = ua;
            ua = undefined
        }
        if (!(this instanceof UAParser)) {
            return new UAParser(ua,extensions).getResult()
        }
        var _ua = ua || ((typeof window === "undefined" ? "undefined" : _typeof(window)) !== UNDEF_TYPE && window.navigator && window.navigator.userAgent ? window.navigator.userAgent : EMPTY);
        var _rgxmap = extensions ? extend(regexes, extensions) : regexes;
        this.getBrowser = function() {
            var _browser = {};
            _browser[NAME] = undefined;
            _browser[VERSION] = undefined;
            rgxMapper.call(_browser, _ua, _rgxmap.browser);
            _browser.major = majorize(_browser.version);
            return _browser
        }
        ;
        this.getCPU = function() {
            var _cpu = {};
            _cpu[ARCHITECTURE] = undefined;
            rgxMapper.call(_cpu, _ua, _rgxmap.cpu);
            return _cpu
        }
        ;
        this.getDevice = function() {
            var _device = {};
            _device[VENDOR] = undefined;
            _device[MODEL] = undefined;
            _device[TYPE] = undefined;
            rgxMapper.call(_device, _ua, _rgxmap.device);
            return _device
        }
        ;
        this.getEngine = function() {
            var _engine = {};
            _engine[NAME] = undefined;
            _engine[VERSION] = undefined;
            rgxMapper.call(_engine, _ua, _rgxmap.engine);
            return _engine
        }
        ;
        this.getOS = function() {
            var _os = {};
            _os[NAME] = undefined;
            _os[VERSION] = undefined;
            rgxMapper.call(_os, _ua, _rgxmap.os);
            return _os
        }
        ;
        this.getResult = function() {
            return {
                ua: this.getUA(),
                browser: this.getBrowser(),
                engine: this.getEngine(),
                os: this.getOS(),
                device: this.getDevice(),
                cpu: this.getCPU()
            }
        }
        ;
        this.getUA = function() {
            return _ua
        }
        ;
        this.setUA = function(ua) {
            _ua = _typeof(ua) === STR_TYPE && ua.length > UA_MAX_LENGTH ? trim(ua, UA_MAX_LENGTH) : ua;
            return this
        }
        ;
        this.setUA(_ua);
        return this
    }
    UAParser.VERSION = LIBVERSION;
    UAParser.BROWSER = enumerize([NAME, VERSION, MAJOR]);
    UAParser.CPU = enumerize([ARCHITECTURE]);
    UAParser.DEVICE = enumerize([MODEL, VENDOR, TYPE, CONSOLE, MOBILE, SMARTTV, TABLET, WEARABLE, EMBEDDED]);
    UAParser.ENGINE = UAParser.OS = enumerize([NAME, VERSION]);
    var publicMethods = {
        initialize: function initialize(params, callback) {
            var cb = function cb() {
                start$4();
                if (callback) {
                    callback()
                }
            };
            if (params && params.logLevel) {
                setLogLevel(params.logLevel)
            }
            if (shouldPushManagerStart()) {
                if (_typeof(params) == 'object') {
                    pushClient.setParams(params)
                }
                runOnWindowLoaded((function() {
                    start$3(cb)
                }
                ))
            } else {
                cb()
            }
            if (shouldOnsiteManagerStart(false)) {
                runOnWindowLoaded((function() {
                    start$1();
                    start$2()
                }
                ))
            }
        },
        setLogLevel: function setLogLevel$1(val, callback) {
            setLogLevel(val);
            if (callback) {
                callback()
            }
        },
        showNativePrompt: function showNativePrompt$1(callback) {
            if (!shouldPushManagerStart()) {
                return
            }
            showNativePrompt().then((function(result) {
                if (callback) {
                    callback(result)
                }
            }
            ))
        },
        showCustomPrompt: function showCustomPrompt$1(callback) {
            if (!shouldPushManagerStart()) {
                return
            }
            showCustomPrompt().then((function(result) {
                if (callback) {
                    callback(result)
                }
            }
            ))
        },
        getNotificationPermission: function getNotificationPermission(callback) {
            if (!shouldPushManagerStart()) {
                return
            }
            if (callback) {
                callback(pushClient.getPermission())
            }
        },
        getToken: function getToken$1(callback) {
            if (!shouldPushManagerStart()) {
                return
            }
            if (callback) {
                callback(getToken())
            }
        },
        isPushNotificationsSupported: function isPushNotificationsSupported(callback) {
            if (callback) {
                callback(pushClient.detected())
            }
        },
        getDeviceId: function getDeviceId$1(callback) {
            if (callback) {
                callback(getDeviceId())
            }
        },
        setDeviceId: function setDeviceId$1(val, callback) {
            setDeviceId(val);
            if (callback) {
                callback()
            }
        },
        pageView: function pageView$1(data, callback) {
            pageView(data);
            if (callback) {
                callback()
            }
        },
        sendDeviceEvent: function sendDeviceEvent$1(table, data, callback) {
            sendDeviceEvent(table, data).then((function() {
                if (callback) {
                    callback()
                }
            }
            ))
        },
        sendCustomEvent: function sendCustomEvent$1(table, key, data, callback) {
            sendCustomEvent(table, key, data).then((function() {
                if (callback) {
                    callback()
                }
            }
            ))
        },
        setContactKey: function setContactKey$1(val, callback) {
            setContactKey(val);
            if (callback) {
                callback()
            }
        },
        getContactKey: function getContactKey$1(callback) {
            if (callback) {
                callback(getContactKey())
            }
        },
        setUserPermission: function setUserPermission$1(val, callback) {
            setUserPermission(val);
            if (callback) {
                callback()
            }
        },
        getUserPermission: function getUserPermission$1(callback) {
            if (callback) {
                callback(getUserPermission())
            }
        },
        setTrackingPermission: function setTrackingPermission$1(val, callback) {
            setTrackingPermission(val);
            if (callback) {
                callback()
            }
        },
        getTrackingPermission: function getTrackingPermission$1(callback) {
            if (callback) {
                callback(getTrackingPermission())
            }
        },
        setTags: function setTags(params, callback) {
            setTagsFn(params).then((function() {
                if (callback) {
                    callback()
                }
            }
            ))
        },
        setNavigation: function setNavigation$1(params) {
            if (!shouldOnsiteManagerStart(true)) {
                return
            }
            if (params == undefined) {
                params = {}
            }
            setNavigation(params)
        },
        setCountry: function setCountry$1(val, callback) {
            setCountry(val);
            if (callback) {
                callback()
            }
        },
        getCountry: function getCountry$1(callback) {
            if (callback) {
                callback(getCountry())
            }
        }
    };
    if ('Promise'in window && 'fetch'in window) {
        if (window._Dn_globaL_) {
            throw new Error('Dengage SDK is already loaded.')
        }
        var currentScript = document.currentScript || function() {
            var scripts = document.getElementsByTagName('script');
            return scripts[scripts.length - 1]
        }();
        var scriptUrl = new URL(currentScript.src);
        window._Dn_globaL_ = {
            scriptTag: currentScript,
            domain: scriptUrl.host,
            loadParams: {
                init: scriptUrl.searchParams.get('init') == 'true',
                swUrl: scriptUrl.searchParams.get('sw_url') || undefined,
                swScope: scriptUrl.searchParams.get('sw_scope') || undefined,
                useSwQueryParams: scriptUrl.searchParams.get('use_sw_query_params') || undefined,
                logLevel: scriptUrl.searchParams.get('log_level') || undefined
            },
            logLevel: '',
            cookieData: {
                webpushDomain: ''
            },
            customFunctions: {},
            storage: {},
            inlineScripts: {},
            storySets: {}
        };
        storage.isAvailable().then((function(storageAvailable) {
            if (storageAvailable) {
                isBotOrPrivateWindow().then((function(botOrPrivate) {
                    if (botOrPrivate !== true) {
                        if (appSettings.subdomainDataSync) {
                            var cookieData = getCookie('_dn_data');
                            cookieData = parseCookieData(cookieData);
                            if (cookieData) {
                                setDeviceId(cookieData.deviceId);
                                setContactKey(cookieData.contactKey);
                                setTokenType(cookieData.tokenType);
                                setToken(cookieData.token);
                                setWebSubscription(cookieData.webSubscription);
                                window._Dn_globaL_.cookieData = cookieData
                            }
                        }
                        var ua = UAParser(navigator.userAgent);
                        var sWidth = window.screen.width;
                        if (ua.device.type == null) {
                            if (navigator.userAgentData) {
                                if (navigator.userAgentData.mobile) {
                                    ua.device.type = 'mobile'
                                } else {
                                    ua.device.type = sWidth > 960 ? 'desktop' : 'tablet'
                                }
                            } else {
                                ua.device.type = sWidth <= 640 ? 'mobile' : sWidth > 960 ? 'desktop' : 'tablet'
                            }
                        }
                        if (['desktop', 'tablet', 'mobile'].includes(ua.device.type) == false) {
                            if (['wearable', 'embedded'].includes(ua.device.type)) {
                                ua.device.type = 'mobile'
                            } else {
                                ua.device.type = 'desktop'
                            }
                        }
                        window._Dn_globaL_.ua = ua;
                        var q = [];
                        if (window.dengage && window.dengage.q) {
                            q = window.dengage.q
                        }
                        if (appSettings.triggerNavigationOnLoad) {
                            q.push(['setNavigation'])
                        }
                        startSession();
                        window.dengage = function() {
                            try {
                                if (typeof arguments[0] != 'string') {
                                    logError('dengage function requires function name as string');
                                    return
                                }
                                if (arguments[0].indexOf('ec:') == 0) {
                                    if (typeof ecommFunctions[arguments[0].replace('ec:', '')] != 'function') {
                                        logError('There is no function called ' + arguments[0]);
                                        return
                                    }
                                    ecommFunctions[arguments[0].replace('ec:', '')].apply(this, Array.prototype.slice.call(arguments, 1))
                                } else if (arguments[0].indexOf('custom:') == 0) {
                                    if (typeof window._Dn_globaL_.customFunctions[arguments[0].replace('custom:', '')] != 'function') {
                                        logError('There is no function called ' + arguments[0]);
                                        return
                                    }
                                    window._Dn_globaL_.customFunctions[arguments[0].replace('custom:', '')].apply(this, Array.prototype.slice.call(arguments, 1))
                                } else {
                                    if (typeof publicMethods[arguments[0]] != 'function') {
                                        logError('There is no function called ' + arguments[0]);
                                        return
                                    }
                                    publicMethods[arguments[0]].apply(this, Array.prototype.slice.call(arguments, 1))
                                }
                            } catch (e) {
                                logError(e.toString())
                            }
                        }
                        ;
                        if (window._Dn_globaL_.loadParams.init) {
                            dengage('initialize', window._Dn_globaL_.loadParams)
                        }
                        q.forEach((function(command) {
                            window.dengage.apply(this, command)
                        }
                        ));
                        window.dnQueue = window.dnQueue || [];
                        window.dnQueue.forEach((function(func) {
                            func()
                        }
                        ));
                        window.dnQueue.push = function(func) {
                            func()
                        }
                        ;
                        window.dataLayer = window.dataLayer || []
                    }
                }
                ))
            }
        }
        ))
    }
    function isBotOrPrivateWindow() {
        if (isbot(navigator.userAgent)) {
            return Promise.resolve(true)
        } else {
            return isPrivateWindow()
        }
    }
    var __custom_js = function() {};
    try {
        __custom_js()
    } catch (e) {}
}
)();

//
//  DengageSubscriptionQueue.swift
//  Dengage
//
//  Created by Egemen Gülkılık on 11.12.2024.
//

import Foundation
import UserNotifications

final class DengageSubscriptionQueue {

    private let apiClient: DengageNetworking
    private let config: DengageConfiguration
    
    private var subscriptionRequestWorkItem: DispatchWorkItem?
    
    private let subscriptionRequestDelay: TimeInterval = 5.0
    
    init(apiClient: DengageNetworking,
         config: DengageConfiguration) {
        self.apiClient = apiClient
        self.config = config
    }

    func enqueueSubscription() {
        subscriptionRequestWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSubscriptionRequest()
        }
        
        subscriptionRequestWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + subscriptionRequestDelay, execute: workItem)
    }
        
    private func performSubscriptionRequest() {
        // Check if subscription is enabled (skip sending if disabled)
        if let remoteConfig = config.remoteConfiguration, !remoteConfig.subscriptionEnabled {
            Logger.log(message: "DengageSubscriptionQueue -> sync skipped (subscriptionEnabled=false)")
            return
        }

        Dengage.dengage?.eventManager.eventSessionStart()
        fetchPushPermission { [weak self] pushPermission in
            guard let self = self else { return }
            let request = MakeSubscriptionRequest(config: self.config, pushPermission: pushPermission)
            Logger.log(message: "DengageSubscriptionQueue -> sync started")
            self.apiClient.send(request: request) { [weak self] result in
                switch result {
                case .success(_):
                    Logger.log(message: "DengageSubscriptionQueue -> sync success")
                    self?.updateLocalStorage(pushPermission: pushPermission)

                case .failure(_):
                    Logger.log(message: "DengageSubscriptionQueue -> sync error")
                }
            }
        }
    }

    private func fetchPushPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var granted = settings.authorizationStatus == .authorized ||
                          settings.authorizationStatus == .provisional
            if #available(iOS 14.0, *) {
                granted = granted || settings.authorizationStatus == .ephemeral
            }
            completion(granted)
        }
    }
    
    private func updateLocalStorage(pushPermission: Bool) {
        DengageLocalStorage.shared.set(value: config.integrationKey, for: .integrationKeySubscription)
        DengageLocalStorage.shared.set(value: config.deviceToken, for: .tokenSubscription)
        DengageLocalStorage.shared.set(value: config.getContactKey() ?? "", for: .contactKeySubscription)
        DengageLocalStorage.shared.set(value: config.permission && pushPermission, for: .permissionSubscription)
        DengageLocalStorage.shared.set(value: config.applicationIdentifier, for: .udidSubscription)
        DengageLocalStorage.shared.set(value: config.getCarrierIdentifier, for: .carrierIdSubscription)
        DengageLocalStorage.shared.set(value: config.appVersion, for: .appVersionSubscription)
        DengageLocalStorage.shared.set(value: SDK_VERSION, for: .sdkVersionSubscription)
        DengageLocalStorage.shared.set(value: config.getDeviceCountry(), for: .countrySubscription)
        DengageLocalStorage.shared.set(value: config.getLanguage(), for: .languageSubscription)
        DengageLocalStorage.shared.set(value: config.deviceTimeZone, for: .timezoneSubscription)
        DengageLocalStorage.shared.set(value: config.getPartnerDeviceID() ?? "", for: .partner_device_idSubscription)
        DengageLocalStorage.shared.set(value: config.advertisingIdentifier, for: .advertisingIdSubscription)
        DengageLocalStorage.shared.set(value: Date(), for: .lastSyncdSubscription)
    }
}

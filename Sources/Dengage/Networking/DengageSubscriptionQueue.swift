//
//  DengageSubscriptionQueue.swift
//  Dengage
//
//  Created by Egemen Gülkılık on 11.12.2024.
//

import Foundation

final class DengageSubscriptionQueue {

    private let apiClient: DengageNetworking
    private let config: DengageConfiguration
    
    private var subscriptionRequestWorkItem: DispatchWorkItem?
    
    private let subscriptionRequestDelay: TimeInterval = 1.0
    
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
        Dengage.dengage?.eventManager.eventSessionStart()
        let request = MakeSubscriptionRequest(config: config)
        Logger.log(message: "DengageSubscriptionQueue -> sync Started")
        apiClient.send(request: request) { [weak self] result in
            switch result {
            case .success(_):
                Logger.log(message: "DengageSubscriptionQueue -> sync success")
                self?.updateLocalStorage()
                
            case .failure(_):
                Logger.log(message: "DengageSubscriptionQueue -> sync error")
            }
        }
    }
    
    private func updateLocalStorage() {
        DengageLocalStorage.shared.set(value: config.integrationKey, for: .integrationKeySubscription)
        DengageLocalStorage.shared.set(value: config.deviceToken, for: .tokenSubscription)
        DengageLocalStorage.shared.set(value: config.getContactKey() ?? "", for: .contactKeySubscription)
        DengageLocalStorage.shared.set(value: config.permission, for: .permissionSubscription)
        DengageLocalStorage.shared.set(value: config.applicationIdentifier, for: .udidSubscription)
        DengageLocalStorage.shared.set(value: config.getCarrierIdentifier, for: .carrierIdSubscription)
        DengageLocalStorage.shared.set(value: config.appVersion, for: .appVersionSubscription)
        DengageLocalStorage.shared.set(value: SDK_VERSION, for: .sdkVersionSubscription)
        DengageLocalStorage.shared.set(value: config.deviceCountryCode, for: .countrySubscription)
        DengageLocalStorage.shared.set(value: config.getLanguage(), for: .languageSubscription)
        DengageLocalStorage.shared.set(value: config.deviceTimeZone, for: .timezoneSubscription)
        DengageLocalStorage.shared.set(value: config.getPartnerDeviceID() ?? "", for: .partner_device_idSubscription)
        DengageLocalStorage.shared.set(value: config.advertisingIdentifier, for: .advertisingIdSubscription)
        DengageLocalStorage.shared.set(value: Date(), for: .lastSyncdSubscription)
    }
}

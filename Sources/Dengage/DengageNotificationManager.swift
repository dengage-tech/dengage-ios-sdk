
import Foundation
import UIKit

final class DengageNotificationManager: NSObject {
    
    private let config: DengageConfiguration
    private let apiClient: DengageNetworking
    private let eventManager: DengageEventProtocolInterface
    private let launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    static var notificationDelegate = DengageNotificationDelegate()
   
    init(config: DengageConfiguration,
         service: DengageNetworking,
         eventManager: DengageEventProtocolInterface,
         launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        self.config = config
        self.apiClient = service
        self.eventManager = eventManager
        self.launchOptions = launchOptions
        
        DengageNotificationManager.notificationDelegate  = DengageNotificationDelegate.init(config: self.config, eventManager: self.eventManager)
        
    }
    
}

import UIKit
import UserNotifications
import UserNotificationsUI
import Dengage
@objc(NotificationViewController)

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    let carouselView = DengageNotificationCarouselView.create()
    
    func didReceive(_ notification: UNNotification) {
        carouselView.didReceive(notification)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        carouselView.didReceive(response, completionHandler: completion)
    }
    
    override func loadView() {
        self.view = carouselView
    }
}

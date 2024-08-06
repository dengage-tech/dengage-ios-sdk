
import UIKit
import Dengage

class RootViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 60
        view.backgroundColor = .white
        view.register(ActionTableViewCell.self, forCellReuseIdentifier: "ActionTableViewCell")
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var rows = Actions.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dengage Example App"
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
}

extension RootViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableViewCell", for: indexPath) as! ActionTableViewCell
        cell.populateUI(with: rows[indexPath.row].title)
        return cell
    }
    
}

extension RootViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row]{
        case .allowNotification:
            Dengage.promptForPushNotifications()
        case .deviceInfo:
            self.navigationController?.pushViewController(DeviceInfoViewController(), animated: true)
        case .contactKey:
            self.navigationController?.pushViewController(ContactKeyViewController(), animated: true)
        case .inboxMessages:
            self.navigationController?.pushViewController(InboxMessagesViewController(), animated: true)
        case .customEvent:
            self.navigationController?.pushViewController(EventViewController(), animated: true)
        case .inAppMessage:
            self.navigationController?.pushViewController(InAppMessageViewController(), animated: true)
        case .realTime:
            self.navigationController?.pushViewController(RealTimeViewController(), animated: true)
        case .tags:
            self.navigationController?.pushViewController(TagsViewController(), animated: true)
        case .testPage:
            Dengage.showTestPage()
        case .rating:
            Dengage.showRatingView()
        case .inAppInLine:
            self.navigationController?.pushViewController(ShowInLineInAPP(), animated: true)
        }
    }
}

extension RootViewController{
    enum Actions: CaseIterable{
        case allowNotification, deviceInfo, contactKey, inboxMessages, customEvent, inAppMessage,realTime, tags, testPage,rating , inAppInLine
        var title: String{
            switch self{
            case .allowNotification:
                return "ASK NOTIFICATIONS"
            case .deviceInfo:
                return "DEVICE INFO"
            case .contactKey:
                return "CHANGE CONTACT KEY"
            case .inboxMessages:
                return "INBOX MESSAGES"
            case .customEvent:
                return "SEND CUSTOM EVENT"
            case .inAppMessage:
                return "IN APP MESSAGES"
            case .realTime:
                return "REAL TIME IN APP MESSAGES"
            case .tags:
                return "SET TAGS"
            case .testPage:
                return "DENGAGE TEST PAGE"
            case .rating:
                return "APPSTORE REVIEW"
            case .inAppInLine:
                return "Show InLine InAPP"
            }
        }
    }
}

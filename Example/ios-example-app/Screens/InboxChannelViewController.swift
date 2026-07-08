import UIKit
import Dengage

final class InboxChannelViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 72
        view.backgroundColor = .white
        view.register(InboxChannelMessageTableViewCell.self,
                      forCellReuseIdentifier: "InboxChannelMessageTableViewCell")
        return view
    }()

    private var messages = [DengageInboxChannelMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inbox Channel"
        view.addSubview(tableView)
        tableView.fillSuperview()
        fetchMessages()
    }

    private func fetchMessages() {
        Dengage.getInboxChannelMessages(limit: 20) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                DispatchQueue.main.async {
                    self.messages = messages
                    self.tableView.reloadData()
                }
                // Report an impression (IM) for every message shown, in bulk.
                self.sendImpressions(for: messages)
            case .failure(let error):
                print("getInboxChannelMessages failed: \(error)")
            }
        }
    }

    private func sendImpressions(for messages: [DengageInboxChannelMessage]) {
        guard !messages.isEmpty else { return }
        let events = messages.map { $0.event(.impression) }
        Dengage.sendInboxChannelEvents(events) { _ in }
    }

    private func send(_ type: DengageInboxChannelEventType,
                      for message: DengageInboxChannelMessage) {
        Dengage.sendInboxChannelEvents([message.event(type)]) { result in
            if case .failure(let error) = result {
                print("send \(type.rawValue) failed: \(error)")
            }
        }
    }
}

extension InboxChannelViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "InboxChannelMessageTableViewCell",
            for: indexPath) as! InboxChannelMessageTableViewCell
        cell.populateUI(with: messages[indexPath.row])
        return cell
    }
}

extension InboxChannelViewController: UITableViewDelegate {

    // Tapping a row reports a click (CL) and routes to the message's deeplink.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        send(.click, for: message)
        messages[indexPath.row].isRead = true
        tableView.reloadRows(at: [indexPath], with: .automatic)
        openDeeplink(for: message)
    }

    private func openDeeplink(for message: DengageInboxChannelMessage) {
        let cta = message.data.ctaButtons?.first
        let target = [cta?.iosDeeplink, cta?.webUrl]
            .compactMap { $0 }
            .first { !$0.isEmpty }
        guard let target = target, let url = URL(string: target) else {
            print("No deeplink for this message")
            return
        }
        UIApplication.shared.open(url, options: [:]) { success in
            if !success { print("Cannot open: \(target)") }
        }
    }

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] _, indexPath in
            guard let self = self else { return }
            let message = self.messages[indexPath.row]
            // Reflect the delete on the UI immediately; the server processes the event async.
            self.send(.delete, for: message)
            self.messages.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let open = UITableViewRowAction(style: .normal, title: "Open") { [weak self] _, indexPath in
            guard let self = self else { return }
            let message = self.messages[indexPath.row]
            self.send(.open, for: message)
            self.messages[indexPath.row].isRead = true
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        open.backgroundColor = .blue

        return [delete, open]
    }
}

private extension DengageInboxChannelMessage {
    func event(_ type: DengageInboxChannelEventType) -> DengageInboxChannelEvent {
        DengageInboxChannelEvent(eventType: type,
                                 messageId: id,
                                 messageDetails: data.messageDetails)
    }
}

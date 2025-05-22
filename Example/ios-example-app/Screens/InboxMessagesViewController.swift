
import UIKit
import Dengage

final class InboxMessagesViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 60
        view.backgroundColor = .white
        view.register(InboxMessageTableViewCell.self, forCellReuseIdentifier: "InboxMessageTableViewCell")
        return view
    }()
    
    private lazy var messages = [DengageMessage] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fillSuperview()
        setupBarButtons()
        fetchMessages()
    }
    
    private func setupBarButtons() {
        let deleteAllButton = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllTapped))
        let markAllReadButton = UIBarButtonItem(title: "Mark All Read", style: .plain, target: self, action: #selector(markAllReadTapped))
        navigationItem.rightBarButtonItems = [deleteAllButton, markAllReadButton]
    }
    
    func fetchMessages() {
        Dengage.getInboxMessages(offset: 0){ [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func deleteAllTapped() {
        Dengage.deleteAllInboxMessages { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("All messages deleted.")
                    self?.fetchMessages()
                case .failure(let error):
                    print("Delete all failed: \(error)")
                }
            }
        }
    }

    @objc private func markAllReadTapped() {
        Dengage.setAllInboxMessageAsClicked { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("All messages marked as read.")
                    self?.fetchMessages()
                case .failure(let error):
                    print("Mark all read failed: \(error)")
                }
            }
        }
    }
}

extension InboxMessagesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxMessageTableViewCell", for: indexPath) as! InboxMessageTableViewCell
        let item = messages[indexPath.row]
        cell.populateUI(with: item)
        return cell
    }
    
}

extension InboxMessagesViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let item = self.messages[indexPath.row]
            Dengage.deleteInboxMessage(with: item.id) { [weak self] _ in
                self?.fetchMessages()
            }
        }
        let markAsClicked = UITableViewRowAction(style: .normal, title: "Mark as Clicked") { (action, indexPath) in
            let item = self.messages[indexPath.row]
            Dengage.setInboxMessageAsClicked(with: item.id) { [weak self] result in
                switch result {
                case .success:
                    print("Message marked as clicked successfully!")
                    self?.fetchMessages()
                case .failure(let error):
                    print("Failed to mark message as clicked: \(error)")
                }
            }
        }
        markAsClicked.backgroundColor = .blue
        
        return [delete, markAsClicked]
    }
    
}

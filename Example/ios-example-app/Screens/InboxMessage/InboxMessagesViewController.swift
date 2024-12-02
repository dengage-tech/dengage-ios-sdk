
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
        fetchMessages()
        
       // Dengage.setNavigation()

    }
    
    func fetchMessages(){
        
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

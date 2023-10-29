
import UIKit
import Dengage

final class InboxMessagesViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        
        view.backgroundColor = .white
        view.register(InboxMessageTableViewCell.self, forCellReuseIdentifier: "InboxMessageTableViewCell")
        return view
    }()
    
    private lazy var messages = [DengageMessage] ()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
       
        
        tableView.fillSuperview()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = 100
        fetchMessages()
    }
    
    func fetchMessages(){
        
        Dengage.getInboxMessages(offset: 0){ [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    
                   
                   
                    self?.tableView.reloadData()

                })
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
        cell.backgroundColor = .green
        cell.populateUI(with: item)
        return cell
    }
    
}

extension InboxMessagesViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.messages[indexPath.row]

        
        for msg in self.messages
        {
            Dengage.setInboxMessageAsClicked(with: msg.id) { [weak self] _ in
                
               
            }
        }
        
       
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//
//
//            self.tableView.reloadData()
//
//        })
    }
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

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}

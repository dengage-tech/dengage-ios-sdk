import UIKit
import Dengage

class RealTimeInAppFiltersViewController: UIViewController {

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
        self.title = "Real Time In App Filters"
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
}

extension RealTimeInAppFiltersViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableViewCell", for: indexPath) as! ActionTableViewCell
        cell.populateUI(with: rows[indexPath.row].title)
        return cell
    }
}

extension RealTimeInAppFiltersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row]{
        case .eventHistory:
            self.navigationController?.pushViewController(EventHistoryViewController(), animated: true)
        case .cart:
            self.navigationController?.pushViewController(CartViewController(), animated: true)
        }
    }
}

extension RealTimeInAppFiltersViewController{
    enum Actions: CaseIterable{
        case eventHistory, cart
        var title: String{
            switch self{
            case .eventHistory:
                return "Event History"
            case .cart:
                return "Cart"
            }
        }
    }
}

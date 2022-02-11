import UIKit
final class TestPageLogController: UIViewController {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 200
        view.backgroundColor = .white
        view.register(DeviceInfoTableViewCell.self, forCellReuseIdentifier: "DeviceInfoTableViewCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        return view
    }()
    private var rows = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupViews()
        rows = Logger.logs.filter{!$0.isEmpty}
    }
    
    private func setupViews(){
        self.title = "LOG PAGE"
        view.backgroundColor = .white
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }
    
}
extension TestPageLogController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceInfoTableViewCell", for: indexPath) as! DeviceInfoTableViewCell
        let item = rows[indexPath.row]
        cell.populateUI(with: (name:"", value: item))
        return cell
    }
}

extension TestPageLogController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = rows.joined(separator: "\n")
        TestPageViewController.showToast(message: "Copied to clipboard", on: self)
    }
}

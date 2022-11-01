import Foundation
import UIKit
final class TestPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 200
        view.backgroundColor = .white
        view.register(TestPageTableViewCell.self, forCellReuseIdentifier: "TestPageTableViewCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        return view
    }()
    
    private var rows = Actions.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupViews()
    }
    
    private func setupViews(){
        self.title = "DENGAGE TEST PAGE"
        view.backgroundColor = .white
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                            style: .plain,
                                                            target: self, action: #selector(didTapCloseButton))
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

    }
    
    @objc func didTapCloseButton(){
        Dengage.manager?.testPageWindow = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestPageTableViewCell", for: indexPath) as! TestPageTableViewCell
        cell.populateUI(with: rows[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row]{
        case .push:
            break
        case .inApp:
            let controller = TestInAppMessageViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        case .deviceInfo:
            let controller = DeviceInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        case .deviceCache:
            let controller = DeviceCacheResetViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        case .log:
            let controller = TestPageLogController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    enum Actions: CaseIterable{
        case push, inApp, deviceInfo, deviceCache, log
        var title: String{
            switch self{
            case .push:
                return "PUSH TEST (in progress)"
            case .inApp:
                return "IN APP MESSAGE TEST"
            case .deviceInfo:
                return "DEVICE INFO TEST"
            case .deviceCache:
                return "DEVICE CACHE TEST"
            case .log:
                return "LOGS"
            }
        }
    }
    
    static func showToast(message : String, on viewController: UIViewController) {
        let toastLabel = UILabel(frame: CGRect(x: viewController.view.frame.size.width/2 - 75, y: viewController.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = .systemFont(ofSize: 16)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        viewController.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

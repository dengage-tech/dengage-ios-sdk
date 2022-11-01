import Foundation
import UIKit
final class DeviceInfoViewController: UIViewController {

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
    
    private var rows = [(name:String, value:String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupViews()
        getInfo()
    }
    
    private func setupViews(){
        self.title = "DEVICE INFO TEST PAGE"
        view.backgroundColor = .white
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }

    func getInfo(){
        guard let manager = Dengage.manager else {return}
        let sdkParamsData = DengageLocalStorage.shared.userDefaults.object(forKey: DengageLocalStorage.Key.configParams.rawValue) as? Data ?? Data()
        rows.append((name:"Push URL:", value: manager.config.subscriptionURL.absoluteString))
        rows.append((name:"Event URL:", value: manager.config.eventURL.absoluteString))
        rows.append((name:"Integration Key:", value: manager.config.integrationKey))
        rows.append((name:"Device Id:", value: manager.config.getContactKey() ?? ""))
        rows.append((name:"Timezone:", value: manager.config.deviceTimeZone))
        rows.append((name:"Language:", value: manager.config.deviceLanguage))
        rows.append((name:"User Permission:", value: manager.config.permission.description))
        rows.append((name:"SDK Version:", value: manager.config.sdkVersion))
        rows.append((name:"APP Version:", value: manager.config.appVersion))
        
        rows.append((name:"SDK Parameters:", value: String(data: sdkParamsData, encoding: String.Encoding.utf8) ?? ""))
        let encoder = JSONEncoder()
        if let json = try? encoder.encode(manager.config) {
            rows.append((name:"Subscription Details:", value: String(data: json, encoding: .utf8) ?? ""))
        }
        
        if let json = try? encoder.encode(DengageLocalStorage.shared.getInAppMessages()) {
            rows.append((name:"In App Messages:", value: String(data: json, encoding: .utf8) ?? ""))
        }

        rows.append((name:"In App Message Fetch Time:", value: String(manager.config.inAppMessageLastFetchedTime ?? 0.0)))
        rows.append((name:"In App Message Show Time:", value: String(manager.config.inAppMessageShowTime)))
        
        if let fetchTime = manager.config.inboxLastFetchedDate?.timeMiliseconds {
            rows.append((name:"InBox Message Fetch Time:", value: String(fetchTime)))
        } else {
            rows.append((name:"InBox Message Fetch Time:", value: "0"))
        }

        rows.append((name:"App Session Id:", value: manager.sessionManager.currentSessionId))
        if let sessionTime = manager.sessionManager.currentSession?.expireIn.timeMiliseconds  {
            rows.append((name:"App Session Expire Time:", value: String(sessionTime)))
        }else {
            rows.append((name:"App Session Expire Time:", value: "0"))
        }
    }
}

extension DeviceInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceInfoTableViewCell", for: indexPath) as! DeviceInfoTableViewCell
        let item = rows[indexPath.row]
        cell.populateUI(with: item)
        return cell
    }
}

extension DeviceInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = rows[indexPath.row]
        UIPasteboard.general.string = item.value
        TestPageViewController.showToast(message: "Copied to clipboard", on: self)
    }
}

final class DeviceInfoTableViewCell: UITableViewCell {

    private(set) lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 14)
        view.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return view
    }()
    
    private(set) lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 11)
        view.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle = .default,
                  reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        contentView.addSubview(stackView)
        contentView.backgroundColor = .white
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    func populateUI(with item: (name:String, value:String)){
        nameLabel.text = item.name
        valueLabel.text = item.value
    }
}

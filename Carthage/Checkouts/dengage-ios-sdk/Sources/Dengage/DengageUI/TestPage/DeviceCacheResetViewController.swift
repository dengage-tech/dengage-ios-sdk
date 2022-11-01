import Foundation
import UIKit
final class DeviceCacheResetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 200
        view.backgroundColor = .white
        view.register(DeviceCacheResetTableViewCell.self, forCellReuseIdentifier: "DeviceCacheResetTableViewCell")
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCacheResetTableViewCell", for: indexPath) as! DeviceCacheResetTableViewCell
        var value: Double?
        switch rows[indexPath.row]{
        case .inboxFetchTime:
            value = Dengage.manager?.config.inboxLastFetchedDate?.timeMiliseconds
        case .inAppShowTime:
            value = Dengage.manager?.config.inAppMessageShowTime
        case .inAppFetchTime:
            value = Dengage.manager?.config.inAppMessageLastFetchedTime
        case .sdkParamsFetchTime:
            value = (DengageLocalStorage.shared.value(for: .lastFetchedConfigTime) as? Date)?.timeMiliseconds
        }
        cell.populateUI(with: (name:rows[indexPath.row].title, value: String(value ?? 0)))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row]{
        case .inboxFetchTime:
            Dengage.manager?.config.inboxLastFetchedDate = nil
        case .inAppShowTime:
            DengageLocalStorage.shared.set(value: nil, for: .inAppMessageShowTime)
        case .inAppFetchTime:
            DengageLocalStorage.shared.set(value: nil, for: .lastFetchedInAppMessageTime)
        case .sdkParamsFetchTime:
            DengageLocalStorage.shared.set(value: nil, for: .lastFetchedConfigTime)
        }
        tableView.reloadData()
    }
    
    enum Actions: CaseIterable{
        case inboxFetchTime, inAppShowTime, inAppFetchTime, sdkParamsFetchTime
        var title: String{
            switch self{
            case .inboxFetchTime:
                return "Inbox Message Fetch Time"
            case .inAppShowTime:
                return "In App Show Time"
            case .inAppFetchTime:
                return "In App Fetch Time"
            case .sdkParamsFetchTime:
                return "SDK Parameters Fetch Time"
            }
        }
    }
    
}

final class DeviceCacheResetTableViewCell: UITableViewCell {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        label.text = "RESET"
        return label
    }()

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
    
    private lazy var valueStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [valueStackView, label])
        view.axis = .horizontal
        view.spacing = 20
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

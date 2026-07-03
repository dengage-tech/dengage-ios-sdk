
import UIKit
import Dengage
import DengageGeofence

class GeofenceViewController: UIViewController {
    
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
        self.title = "Geofence"
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
}

extension GeofenceViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableViewCell", for: indexPath) as! ActionTableViewCell
        cell.setLabelFontSize(size: 14)
        cell.populateUI(with: rows[indexPath.row].title)
        return cell
    }
    
}

extension GeofenceViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row]{
        case .requestLocationAlwaysAuthorization:
            DengageGeofence.requestLocationPermissions()
        case .stopGeofencing:
            DengageGeofence.stopGeofence()
        case .showLastSilentPushSync:
            showLastSilentPushSync()
        }
    }

    private func showLastSilentPushSync() {
        let message: String
        if let date = DengageGeofenceEngine.shared.lastSilentPushSyncDate() {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            message = "Last silent push sync: \(formatter.string(from: date))"
        } else {
            message = "Last silent push sync: none yet"
        }
        let alert = UIAlertController(title: "Geofence", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension GeofenceViewController{
    enum Actions: CaseIterable{
        case requestLocationAlwaysAuthorization, stopGeofencing, showLastSilentPushSync
        var title: String{
            switch self{
            case .requestLocationAlwaysAuthorization:
                return "REQUEST LOCATION ALWAYS AUTHORIZATION"
            case .stopGeofencing:
                return "STOP GEOFENCING"
            case .showLastSilentPushSync:
                return "SHOW LAST SILENT PUSH SYNC"
            }
        }
    }
}

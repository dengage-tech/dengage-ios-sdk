
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
        case .showMonitoredGeofences:
            showMonitoredGeofences()
        case .showRecentTriggeredEvents:
            showRecentTriggeredEvents()
        }
    }

    private func showMonitoredGeofences() {
        let fences = DengageGeofenceEngine.shared.monitoredGeofences()
        let lines = fences.map { fence -> String in
            let name = fence.title ?? "(no title)"
            return """
            #\(fence.geofenceId) \(name)
              cluster: \(fence.clusterId) · state: \(fence.state)
              \(String(format: "%.5f", fence.latitude)), \(String(format: "%.5f", fence.longitude)) · r=\(Int(fence.radiusM))m
            """
        }
        showList(title: "Monitored Geofences (\(fences.count))",
                 lines: lines,
                 emptyMessage: "No geofence is currently being monitored.")
    }

    private func showRecentTriggeredEvents() {
        let events = DengageGeofenceEngine.shared.recentTriggeredEvents()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let lines = events.map { event -> String in
            let name = event.title ?? "(no title)"
            let campaigns = event.campaignIds.isEmpty
                ? "no matching campaign"
                : "campaigns: \(event.campaignIds.map(String.init).joined(separator: ", "))"
            let accuracy = event.accuracyM.map { "accuracy: \(Int($0.rounded()))m" } ?? "accuracy: n/a"
            let campaignsLine = event.stateOnly ? "state-only (no push) · \(campaigns)" : campaigns
            let origin = event.syntheticTransition ? "synthetic (SDK inferred)" : "OS callback"
            return """
            \(event.eventType.uppercased()) · #\(event.geofenceId) \(name)
              \(formatter.string(from: event.occurredAt))
              \(origin) · \(accuracy)
              \(campaignsLine)
            """
        }
        showList(title: "Triggered Events (\(events.count))",
                 lines: lines,
                 emptyMessage: "No geofence event has been triggered yet.")
    }

    /// Listeyi kaydırılabilir bir ekranda gösterir; alert uzun listeler için kullanışsız kalıyor.
    private func showList(title: String, lines: [String], emptyMessage: String) {
        let controller = GeofenceInfoListViewController(
            listTitle: title,
            text: lines.isEmpty ? emptyMessage : lines.joined(separator: "\n\n")
        )
        navigationController?.pushViewController(controller, animated: true)
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
        case requestLocationAlwaysAuthorization, stopGeofencing, showLastSilentPushSync,
             showMonitoredGeofences, showRecentTriggeredEvents
        var title: String{
            switch self{
            case .requestLocationAlwaysAuthorization:
                return "REQUEST LOCATION ALWAYS AUTHORIZATION"
            case .stopGeofencing:
                return "STOP GEOFENCING"
            case .showLastSilentPushSync:
                return "SHOW LAST SILENT PUSH SYNC"
            case .showMonitoredGeofences:
                return "SHOW MONITORED GEOFENCES"
            case .showRecentTriggeredEvents:
                return "SHOW TRIGGERED EVENTS"
            }
        }
    }
}

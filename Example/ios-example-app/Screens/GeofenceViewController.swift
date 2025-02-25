
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
        }
    }
}

extension GeofenceViewController{
    enum Actions: CaseIterable{
        case requestLocationAlwaysAuthorization, stopGeofencing
        var title: String{
            switch self{
            case .requestLocationAlwaysAuthorization:
                return "REQUEST LOCATION ALWAYS AUTHORIZATION"
            case .stopGeofencing:
                return "STOP GEOFENCING"
            }
        }
    }
}

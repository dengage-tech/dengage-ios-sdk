
import UIKit
import Dengage
class DeviceInfoViewController: UIViewController {

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.isEditable = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device Info"
        view.backgroundColor = .white
        view.addSubview(textView)
        textView.fillSuperview(horizontalPadding: 16, verticalPadding: 8)
        getInfo()
    }
    
    func getInfo(){
        var text = ""
        text += "Device Id: " + (Dengage.getDeviceId() ?? "") + "\n"
        text += "Contact Key: " + (Dengage.getContactKey() ?? "") + "\n"
        text += "User Permission: " + Dengage.getPermission().description + "\n"
        text += "Device Token: " + (Dengage.getDeviceToken() ?? "")
        textView.text = text
    }

}

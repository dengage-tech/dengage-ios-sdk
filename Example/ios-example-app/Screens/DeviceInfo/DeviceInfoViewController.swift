
import UIKit
import Dengage
class DeviceInfoViewController: UIViewController {

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        let currentDevice = UIDevice.current
        var text = ""
        text += "Integration Key: " + Dengage.getIntegrationKey() + "\n"
        text += "Device Id: " + (Dengage.getDeviceId() ?? "") + "\n"
        text += "Contact Key: " + (Dengage.getContactKey() ?? "") + "\n"
        text += "User Permission: " + Dengage.getPermission().description + "\n"
        text += "Device Token: " + (Dengage.getDeviceToken() ?? "") + "\n"
        text += "Device Brand: " + "apple" + "\n"
        text += "Device Model: " + "iphone" + "\n"
        text += "Advertising Identifier: " + Dengage.getAdvertisingIdentifier() + "\n"
        text += "Bundle Identifier:" + (Bundle.main.bundleIdentifier ?? "") + "\n"
        text += "Sdk Version: " + (Dengage.getSdkVersion() ?? "") + "\n"
        text += "Screen Width: " + UIScreen.main.nativeBounds.width.description + "\n"
        text += "Screen Height: " + UIScreen.main.nativeBounds.height.description + "\n"
        text += "Os Version: " + "\(currentDevice.systemName)/\(currentDevice.systemVersion)" + "\n"
        textView.text = text
    }

}

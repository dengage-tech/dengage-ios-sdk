
import UIKit
import Dengage
import AppTrackingTransparency
import AdSupport

class ContactKeyViewController: UIViewController {

    private lazy var textField:UITextField = {
        let view = UITextField()
        view.placeholder = "email@email.com"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.delegate = self
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let view = UIButton()
        view.setTitle("Set Contact Key", for: .normal)
        view.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [textField,saveButton,UIView()])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device Info"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.fillSafeArea(with: .init(top: 8, left: 16, bottom: 8, right: 16))
        
      
        
     // Dengage.setNavigation(screenName: "p1")
        
        Dengage.beginCheckout(parameters: ["price":40])
        
       // Dengage.showRealTimeInApp(screenName: "p1",params: ["": ""])
        
      /* if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }*/
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        Dengage.removeInAppMessageDisplay()
        
    }
    
    @objc private func didTapSaveButton() {
        guard let text = textField.text else {return}
        Dengage.set(contactKey: text)
        view.endEditing(true)
    }

}

extension ContactKeyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

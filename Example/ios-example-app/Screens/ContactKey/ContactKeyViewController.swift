
import UIKit
import Dengage
class ContactKeyViewController: UIViewController {

    private lazy var textField:UITextField = {
        let view = UITextField()
        view.placeholder = "email@email.com"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
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
    
    private lazy var requestCountField:UITextField = {
        let view = UITextField()
        view.placeholder = "Request Count"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.keyboardType = .numberPad
        view.text = "1"
        view.delegate = self
        return view
    }()
    
    private lazy var subscribeButton: UIButton = {
        let view = UIButton()
        view.setTitle("Subscribe", for: .normal)
        view.addTarget(self, action: #selector(didTapSubscribe), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [textField, saveButton, requestCountField, subscribeButton, UIView()])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact Key"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.fillSafeArea(with: .init(top: 8, left: 16, bottom: 8, right: 16))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
          
            Dengage.setNavigation(screenName: "p1")

            
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
          
            Dengage.removeInAppMessageDisplay()

            
        })
        
        
        
    }
    
    @objc private func didTapSubscribe() {
        let requestCount = Int(requestCountField.text ?? "1") ?? 1
        
        let randomInt = Int.random(in: 1..<1000)
        for i in 0..<requestCount {
            //Dengage.set(deviceId: "\(randomInt)")
            //Dengage.set(contactKey: "\(randomInt)")
        }
        
        Dengage.set(deviceId: "\(randomInt)")
        Dengage.set(contactKey: "\(randomInt)")
        
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

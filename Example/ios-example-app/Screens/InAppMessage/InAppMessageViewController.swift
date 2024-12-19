
import UIKit
import Dengage

final class InAppMessageViewController: UIViewController {
    
    private lazy var deviceIdTextView:UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var screenNameTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Screen Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var navigationButton: UIButton = {
        let view = UIButton()
        view.setTitle("Set Navigation", for: .normal)
        view.addTarget(self, action: #selector(didTapNavigationButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var clearDeviceInfoButton: UIButton = {
        let view = UIButton()
        view.setTitle("Clear Device Info", for: .normal)
        view.addTarget(self, action: #selector(didTapClearDeviceInfo), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [deviceIdTextView,
                                                  screenNameTextField,
                                                  navigationButton,
                                                  clearDeviceInfoButton,
                                                  UIView()])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    private lazy var addNewDeviceInfoButton: UIButton = {
        let view = UIButton()
        view.setTitle("+ Add New Device Info", for: .normal)
        view.addTarget(self, action: #selector(didTapAddNewDeviceInfoButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var deviceInfoStackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [addNewDeviceInfoButton])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return view
    }()
    
    @objc private func didTapAddNewDeviceInfoButton(){
        addNewDeviceInfoView(key: "", value: "")
    }
    
    private func addNewDeviceInfoView(key: String, value: String){
        let view = DeviceInfoItemView(key: key, value: value)
        view.onDelete = { [weak self, weak view] in
            guard let self = self, let view = view else { return }
            self.deviceInfoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        deviceInfoStackView.addArrangedSubview(view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let deviceInfo = Dengage.getInAppDeviceInfo()
        for info in deviceInfo {
            addNewDeviceInfoView(key: info.key, value: info.value)
        }
        addNewDeviceInfoView(key: "", value: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceIdTextView.text = "Device Id:\n" + (Dengage.getDeviceId() ?? "") + "\nContact Key:\n" + (Dengage.getContactKey() ?? "")
    }
    
    private func setupUI(){
        title = "In-App"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        
        view.addSubview(deviceInfoStackView)
        NSLayoutConstraint.activate([
            deviceInfoStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            deviceInfoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            deviceInfoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
    
    @objc private func didTapNavigationButton(){
        guard let text = screenNameTextField.text else {return}
        
        let deviceInfo:Dictionary = deviceInfoStackView.arrangedSubviews
                .compactMap{$0 as? DeviceInfoItemView}
                .compactMap{$0.values}
                .reduce(into: [:]) { $0[$1.0] = $1.1 }
        
        for (key, value) in deviceInfo {
            Dengage.setInAppDeviceInfo(key: key, value: value)
        }
        
        Dengage.setNavigation(screenName: text)
        //        Dengage.handleInAppDeeplink { str in
        //
        //        }
        
        view.endEditing(true)
        navigationButton.setTitleColor(.black, for: .normal)
    }
    
    @objc private func didTapClearDeviceInfo(){
        Dengage.clearInAppDeviceInfo()
        for view in deviceInfoStackView.arrangedSubviews{
            view.removeFromSuperview()
        }
        addNewDeviceInfoView(key: "", value: "")
    }
}


extension InAppMessageViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        navigationButton.setTitleColor(.blue, for: .normal)
        return true
    }
}


extension InAppMessageViewController{
    final class DeviceInfoItemView: UIView{
        
        private lazy var keyTextField:UITextField = {
            let view = UITextField()
            view.placeholder = "key"
            view.borderStyle = .roundedRect
            view.textColor = .black
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var valueTextField:UITextField = {
            let view = UITextField()
            view.placeholder = "value"
            view.borderStyle = .roundedRect
            view.textColor = .black
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var deleteButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Remove", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
            return button
        }()
        
        private lazy var stackView:UIStackView = {
            let view = UIStackView(arrangedSubviews: [keyTextField, valueTextField])
            view.axis = .horizontal
            view.translatesAutoresizingMaskIntoConstraints = false
            view.spacing = 10
            view.distribution = .fillEqually
            return view
        }()
        
        var onDelete: (() -> Void)?
        
        init(key: String, value: String) {
            super.init(frame: .zero)
            if !key.isEmpty {
                keyTextField.text = key
            }
            if !value.isEmpty {
                valueTextField.text = value
            }
            addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        @objc private func didTapDeleteButton() {
            onDelete?()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var values:(String,String)? {
            guard let key = keyTextField.text, !key.isEmpty,
                  let value = valueTextField.text, !value.isEmpty else {return nil}
            return (key,value)
        }
    }
}


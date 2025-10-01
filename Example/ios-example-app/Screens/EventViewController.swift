import UIKit
import Dengage

final class EventViewController: UIViewController {
    
    private lazy var eventTableNameTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Table Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        view.text = "page_view_events"
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Send Event", for: .normal)
        view.setTitleColor(.blue, for: .normal)
        view.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        return view
    }()
    
    private lazy var addParameterButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("+ Add New Parameter", for: .normal)
        view.setTitleColor(.blue, for: .normal)
        view.addTarget(self, action: #selector(didTapAddParameterButton), for: .touchUpInside)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            eventTableNameTextField,
            addParameterButton,
            sendButton
        ])
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Dengage.setNavigation(screenName: "p3")
    }
    
    private func setupUI() {
        title = "Event Collection"
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
        
        addParameterItemView(key: "page_type", value: "category")
    }
    
    @objc private func didTapSendButton() {
        let eventTableName = eventTableNameTextField.text ?? ""
        
        let parameters: [String: String] = stackView.arrangedSubviews
            .compactMap { $0 as? EventParameterItemView }
            .compactMap { $0.values }
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        
        Dengage.sendCustomEvent(eventTable: eventTableName, parameters: parameters)
    }
    
    @objc private func didTapAddParameterButton() {
        addParameterItemView()
    }
    
    private func addParameterItemView(key: String = "", value: String = "") {
        let view = EventParameterItemView(key: key, value: value)
        stackView.insertArrangedSubview(view, at: 1)
    }
}

extension EventViewController {
    
    final class EventParameterItemView: UIView {
        
        private lazy var keyTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "key"
            view.borderStyle = .roundedRect
            view.textColor = .black
            return view
        }()
        
        private lazy var valueTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "value"
            view.borderStyle = .roundedRect
            view.textColor = .black
            return view
        }()
        
        private lazy var stackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [keyTextField, valueTextField])
            view.axis = .horizontal
            view.spacing = 10
            view.distribution = .fillEqually
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        init(key: String = "", value: String = "") {
            super.init(frame: .zero)
            keyTextField.text = key
            valueTextField.text = value
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        var values: (String, String)? {
            guard let key = keyTextField.text,
                  let value = valueTextField.text,
                  !key.isEmpty, !value.isEmpty else { return nil }
            return (key, value)
        }
    }
}

extension EventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

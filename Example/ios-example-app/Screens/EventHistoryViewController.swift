import UIKit
import Dengage

final class EventHistoryViewController: UIViewController {
    
    private lazy var screenNameTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Screen Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var showButton: UIButton = {
        let view = UIButton()
        view.setTitle("Show Event History In App", for: .normal)
        view.addTarget(self, action: #selector(didTapShowButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var addParameterButton: UIButton = {
        let view = UIButton()
        view.setTitle("+ Add New Parameter", for: .normal)
        view.addTarget(self, action: #selector(didTapAddParameterButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [screenNameTextField, addParameterButton, showButton])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        title = "Event History"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        addParameterItemView()
    }
    
    @objc private func didTapShowButton(){
        let parameters: Dictionary = stackView.arrangedSubviews
            .compactMap{$0 as? EventViewController.EventParameterItemView}
            .compactMap{$0.values}
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        
        // Event History için Dengage method çağrısı
        Dengage.showRealTimeInApp(screenName: screenNameTextField.text,
                                  params: parameters)
    }
    
    @objc private func didTapAddParameterButton(){
        addParameterItemView()
    }

    private func addParameterItemView(){
        let view = EventViewController.EventParameterItemView()
        stackView.insertArrangedSubview(view, at: 1)
    }
}

extension EventHistoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

import Foundation

import UIKit
import Dengage

final class RealTimeViewController: UIViewController {

    private lazy var setCategoryPathView: CustomFunctionView = {
        let view = CustomFunctionView()
        view.valueTextField.placeholder = "Category Path"
        view.delegate = self
        return view
    }()
    
    private lazy var setCartItemCountView: CustomFunctionView = {
        let view = CustomFunctionView()
        view.valueTextField.placeholder = "Cart Item Count"
        view.delegate = self
        return view
    }()
    
    private lazy var setCartAmountView: CustomFunctionView = {
        let view = CustomFunctionView()
        view.valueTextField.placeholder = "Cart Amount"
        view.delegate = self
        return view
    }()
    
    private lazy var setStateView: CustomFunctionView = {
        let view = CustomFunctionView()
        view.valueTextField.placeholder = "State"
        view.delegate = self
        return view
    }()
    
    private lazy var setCityView: CustomFunctionView = {
        let view = CustomFunctionView()
        view.valueTextField.placeholder = "City"
        view.delegate = self
        return view
    }()
    
    private lazy var screenNameTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Screen name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        return view
    }()
        
    private lazy var showButton: UIButton = {
        let view = UIButton()
        view.setTitle("Show Real Time In App", for: .normal)
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
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [setCategoryPathView,
                                                  setCartItemCountView,
                                                  setCartAmountView,
                                                  setStateView,
                                                  setCityView,
                                                  screenNameTextField, addParameterButton, showButton])
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
        title = "Event Collection"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        addParameterItemView()
    }
    
    @objc private func didTapShowButton(){
        let parameters:Dictionary = stackView.arrangedSubviews
            .compactMap{$0 as? EventViewController.EventParameterItemView}
            .compactMap{$0.values}
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        Dengage.showRealTimeInApp(screenName: screenNameTextField.text,
                                  params: parameters)
    }
    
    @objc private func didTapAddParameterButton(){
        addParameterItemView()
    }

    private func addParameterItemView(){
        let view = EventViewController.EventParameterItemView()
        stackView.insertArrangedSubview(view, at: 6)
    }
}



extension RealTimeViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension RealTimeViewController: CustomFunctionViewDelegate {
    func didTapSet(view: CustomFunctionView) {
        if view == setCategoryPathView {
            Dengage.setCategory(path: view.valueTextField.text)
        } else if view == setCartItemCountView {
            Dengage.setCart(itemCount: view.valueTextField.text)
        } else if view == setCartAmountView {
            Dengage.setCart(amount: view.valueTextField.text)
        } else if view == setStateView {
            Dengage.setState(name: view.valueTextField.text)
        }else if view == setCityView {
            Dengage.setCity(name: view.valueTextField.text)
        }
    }
}

protocol CustomFunctionViewDelegate: AnyObject {
    func didTapSet(view: CustomFunctionView)
}

final class CustomFunctionView: UIView, UITextFieldDelegate {
    
    private(set) lazy var valueTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Event Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        return view
    }()
        
    private lazy var setButton: UIButton = {
        let view = UIButton()
        view.setTitle("Set", for: .normal)
        view.addTarget(self, action: #selector(didTapSetButton),
                       for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        view.sizeAnchor(width: 30)
        return view
    }()
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [valueTextField, setButton])
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 8
        return view
    }()
    
    weak var delegate: CustomFunctionViewDelegate?
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .white
        addSubview(stackView)
        stackView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return false
    }
    
    @objc private func didTapSetButton(){
        delegate?.didTapSet(view: self)
    }
}

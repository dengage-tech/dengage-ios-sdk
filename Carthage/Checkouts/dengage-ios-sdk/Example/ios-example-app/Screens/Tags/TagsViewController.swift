
import UIKit
import Dengage
final class TagsViewController: UIViewController {
    
    private lazy var tagNameTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Tag Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var tagValueTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Tag Value"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var changeTimeTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Change Time"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var changeValueTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Change Value"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var removeTimeTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Remove Time"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()
    
    private lazy var navigationButton: UIButton = {
        let view = UIButton()
        view.setTitle("Send", for: .normal)
        view.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView(arrangedSubviews: [tagNameTextField,
                                                  tagValueTextField,
                                                  changeTimeTextField,
                                                  changeValueTextField,
                                                  removeTimeTextField,
                                                  navigationButton,
                                                  UIView()])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    let changeTimeDatePicker = UIDatePicker()
    let removeTimeDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupUI(){
        title = "Tags"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        
        createRemoveDatePicker()
        createChangeDatePicker()
    }
    
    @objc private func didTapSendButton(){
        guard let name = tagNameTextField.text else {return}
        guard let value = tagValueTextField.text else {return}
        let changeValue = changeValueTextField.text
        let changeTimeText = changeTimeTextField.text
        let removeTimeText = removeTimeTextField.text
        var changeTime : Date? = nil
        var removeTime : Date? = nil
        
        if !(changeTimeText?.isEmpty ?? false) {
            changeTime = changeTimeDatePicker.date
        }
        
        if !(removeTimeText?.isEmpty ?? false) {
            removeTime = removeTimeDatePicker.date
        }
         
        let tag = TagItem(tagName: name,
                          tagValue: value,
                          changeTime: changeTime,
                          removeTime: removeTime,
                          changeValue: changeValue)
        Dengage.setTags([tag])
    }
    
    func createChangeDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(changeDateDoneButtonClicked))
        toolbar.setItems([doneButton], animated: true)
        changeTimeTextField.inputAccessoryView = toolbar
        changeTimeTextField.inputView = changeTimeDatePicker
        changeTimeDatePicker.datePickerMode = .dateAndTime
        changeTimeDatePicker.addTarget(self, action: #selector(changeDateDoneButtonClicked), for: .valueChanged)
    }
    
    func createRemoveDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(removeDateDoneButtonClicked))
        toolbar.setItems([doneButton], animated: true)
        removeTimeTextField.inputAccessoryView = toolbar
        removeTimeTextField.inputView = removeTimeDatePicker
        removeTimeDatePicker.datePickerMode = .dateAndTime
        removeTimeDatePicker.addTarget(self, action: #selector(removeDateDoneButtonClicked), for: .valueChanged)
    }
    
    @objc func changeDateDoneButtonClicked(){
        changeTimeTextField.text = changeTimeDatePicker.date.description
        self.view.endEditing(true)
    }
    
    @objc func removeDateDoneButtonClicked(){
        removeTimeTextField.text = removeTimeDatePicker.date.description
        self.view.endEditing(true)
    }
}

extension TagsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

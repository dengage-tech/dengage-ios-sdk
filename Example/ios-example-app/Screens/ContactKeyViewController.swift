import UIKit
import Dengage

class ContactKeyViewController: UIViewController {

    private lazy var textField: UITextField = {
        let view = UITextField()
        view.placeholder = "email@email.com"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        view.text = Dengage.getContactKey()
        return view
    }()

    private lazy var saveButton: UIButton = {
        let view = UIButton()
        view.setTitle("Set Contact Key", for: .normal)
        view.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()

    private lazy var permissionSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = Dengage.getPermission()
        view.addTarget(self, action: #selector(permissionSwitchChanged), for: .valueChanged)
        return view
    }()

    private lazy var permissionLabel: UILabel = {
        let label = UILabel()
        label.text = "Permission"
        return label
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [textField, saveButton, permissionLabel, permissionSwitch, UIView()])
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            Dengage.removeInAppMessageDisplay()
        }
    }

    @objc private func didTapSaveButton() {
        guard let text = textField.text else { return }
        Dengage.set(contactKey: text)
        view.endEditing(true)
    }

    @objc private func permissionSwitchChanged(_ sender: UISwitch) {
        Dengage.set(permission: sender.isOn)
    }
}

extension ContactKeyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

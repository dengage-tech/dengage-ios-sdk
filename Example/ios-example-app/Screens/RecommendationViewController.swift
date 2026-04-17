import UIKit
import WebKit
import Dengage

class RecommendationViewController: UIViewController {

    private lazy var propertyIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Property ID"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.text = "1"
        return view
    }()

    private lazy var screenNameTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Screen Name"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.text = "recommendation"
        return view
    }()

    private lazy var customParam1: EventViewController.EventParameterItemView = {
        let v = EventViewController.EventParameterItemView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var customParam2: EventViewController.EventParameterItemView = {
        let v = EventViewController.EventParameterItemView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var showButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Recommendation", for: .normal)
        button.addTarget(self, action: #selector(didTapShow), for: .touchUpInside)
        return button
    }()

    private lazy var recommendationView: RecommendationView = {
        let config = WKWebViewConfiguration()
        let rv = RecommendationView(frame: .zero, configuration: config)
        rv.translatesAutoresizingMaskIntoConstraints = false
        return rv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recommendation"
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        [propertyIdTextField, screenNameTextField, customParam1, customParam2, showButton, recommendationView]
            .forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            propertyIdTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            propertyIdTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            propertyIdTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            propertyIdTextField.heightAnchor.constraint(equalToConstant: 50),

            screenNameTextField.topAnchor.constraint(equalTo: propertyIdTextField.bottomAnchor, constant: 8),
            screenNameTextField.leadingAnchor.constraint(equalTo: propertyIdTextField.leadingAnchor),
            screenNameTextField.trailingAnchor.constraint(equalTo: propertyIdTextField.trailingAnchor),
            screenNameTextField.heightAnchor.constraint(equalToConstant: 50),

            customParam1.topAnchor.constraint(equalTo: screenNameTextField.bottomAnchor, constant: 8),
            customParam1.leadingAnchor.constraint(equalTo: screenNameTextField.leadingAnchor),
            customParam1.trailingAnchor.constraint(equalTo: screenNameTextField.trailingAnchor),
            customParam1.heightAnchor.constraint(equalToConstant: 40),

            customParam2.topAnchor.constraint(equalTo: customParam1.bottomAnchor, constant: 8),
            customParam2.leadingAnchor.constraint(equalTo: customParam1.leadingAnchor),
            customParam2.trailingAnchor.constraint(equalTo: customParam1.trailingAnchor),
            customParam2.heightAnchor.constraint(equalToConstant: 40),

            showButton.topAnchor.constraint(equalTo: customParam2.bottomAnchor, constant: 16),
            showButton.leadingAnchor.constraint(equalTo: customParam2.leadingAnchor),
            showButton.trailingAnchor.constraint(equalTo: customParam2.trailingAnchor),
            showButton.heightAnchor.constraint(equalToConstant: 50),

            recommendationView.topAnchor.constraint(equalTo: showButton.bottomAnchor, constant: 16),
            recommendationView.leadingAnchor.constraint(equalTo: showButton.leadingAnchor),
            recommendationView.trailingAnchor.constraint(equalTo: showButton.trailingAnchor)
        ])
    }

    @objc private func didTapShow() {
        view.endEditing(true)

        guard let propertyId = propertyIdTextField.text, !propertyId.isEmpty else { return }
        let screenName = (screenNameTextField.text ?? "").isEmpty ? nil : screenNameTextField.text

        var customParams: [String: String] = [:]
        if let p1 = customParam1.values, !p1.0.isEmpty, !p1.1.isEmpty { customParams[p1.0] = p1.1 }
        if let p2 = customParam2.values, !p2.0.isEmpty, !p2.1.isEmpty { customParams[p2.0] = p2.1 }

        Dengage.getRecommendation(
            recommendationPropertyId: propertyId,
            recommendationView: recommendationView,
            screenName: screenName,
            customParams: customParams.isEmpty ? nil : customParams
        )
    }
}

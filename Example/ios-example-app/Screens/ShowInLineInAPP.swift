import UIKit
import WebKit
import Dengage

class ShowInLineInAPP: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: - UI Elements
    private lazy var screenNameTextField1: UITextField = {
        let view = UITextField()
        view.placeholder = "Property ID"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.text = "1"
        return view
    }()

    private lazy var screenNameTextField2: UITextField = {
        let view = UITextField()
        view.placeholder = "Enter Screen Name"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.text = "inline"
        return view
    }()

    private lazy var customVw1: UIView = {
        let customView = EventViewController.EventParameterItemView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        return customView
    }()

    private lazy var customVw2: UIView = {
        let customView = EventViewController.EventParameterItemView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        return customView
    }()

    private lazy var navigationButton1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show InLineInAPP", for: .normal)
        button.addTarget(self, action: #selector(didTapNavigationButton1), for: .touchUpInside)
        return button
    }()

    private lazy var webView1: InAppInlineElementView = {
        let config = WKWebViewConfiguration()
        let wv = InAppInlineElementView(frame: .zero, configuration: config)
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.backgroundColor = .yellow
        wv.navigationDelegate = self
        return wv
    }()

    // Constraint to update height dynamically
    private var webViewHeightConstraint: NSLayoutConstraint?
    
    private var showInAppInLineCalled = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "InLineInAPP"
        view.backgroundColor = .gray
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        [screenNameTextField1, screenNameTextField2, customVw1, customVw2, navigationButton1, webView1].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            screenNameTextField1.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            screenNameTextField1.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            screenNameTextField1.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            screenNameTextField1.heightAnchor.constraint(equalToConstant: 50),

            screenNameTextField2.topAnchor.constraint(equalTo: screenNameTextField1.bottomAnchor, constant: 8),
            screenNameTextField2.leadingAnchor.constraint(equalTo: screenNameTextField1.leadingAnchor),
            screenNameTextField2.trailingAnchor.constraint(equalTo: screenNameTextField1.trailingAnchor),
            screenNameTextField2.heightAnchor.constraint(equalToConstant: 50),

            customVw1.topAnchor.constraint(equalTo: screenNameTextField2.bottomAnchor, constant: 8),
            customVw1.leadingAnchor.constraint(equalTo: screenNameTextField2.leadingAnchor),
            customVw1.trailingAnchor.constraint(equalTo: screenNameTextField2.trailingAnchor),
            customVw1.heightAnchor.constraint(equalToConstant: 40),

            customVw2.topAnchor.constraint(equalTo: customVw1.bottomAnchor, constant: 8),
            customVw2.leadingAnchor.constraint(equalTo: customVw1.leadingAnchor),
            customVw2.trailingAnchor.constraint(equalTo: customVw1.trailingAnchor),
            customVw2.heightAnchor.constraint(equalToConstant: 40),

            navigationButton1.topAnchor.constraint(equalTo: customVw2.bottomAnchor, constant: 16),
            navigationButton1.leadingAnchor.constraint(equalTo: customVw2.leadingAnchor),
            navigationButton1.trailingAnchor.constraint(equalTo: customVw2.trailingAnchor),
            navigationButton1.heightAnchor.constraint(equalToConstant: 50),

            webView1.topAnchor.constraint(equalTo: navigationButton1.bottomAnchor, constant: 16),
            webView1.leadingAnchor.constraint(equalTo: navigationButton1.leadingAnchor),
            webView1.trailingAnchor.constraint(equalTo: navigationButton1.trailingAnchor)
        ])

        // Initialize height constraint
        webView1.isHidden = true
        webViewHeightConstraint = webView1.heightAnchor.constraint(equalToConstant: 0)
        webViewHeightConstraint?.isActive = true
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, error in
            guard let self = self, let height = result as? CGFloat, showInAppInLineCalled else { return }
            self.webViewHeightConstraint?.constant = height
            self.webView1.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    @objc private func didTapNavigationButton1() {
        view.endEditing(true)
        guard let propertyid = screenNameTextField1.text,
              let screenName = screenNameTextField2.text else { return }

        let parameters: [String: String] = view.subviews
            .compactMap { $0 as? EventViewController.EventParameterItemView }
            .compactMap { $0.values }
            .reduce(into: [:]) { dict, pair in dict[pair.0] = pair.1 }

        Dengage.showInAppInLine(
            propertyID: propertyid,
            inAppInlineElement: webView1,
            screenName: screenName,
            customParams: parameters,
            hideIfNotFound: true
        )
        showInAppInLineCalled = true
    }
}

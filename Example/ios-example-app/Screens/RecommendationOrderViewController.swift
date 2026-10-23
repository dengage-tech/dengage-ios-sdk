import UIKit
import Dengage

/// Opened from a recommendation item's `Dn.iosUrlN` link, e.g.
/// `dengage://recommendationOrder?productId=M300055998-0012-0002`,
/// and sends an order for that product via `Dengage.sendCustomEvent`.
final class RecommendationOrderViewController: UIViewController {

    // MARK: - Routing
    static let host = "recommendationOrder"

    /// Pushes the order screen if `urlString` is a recommendation order link.
    @discardableResult
    static func route(_ urlString: String) -> Bool {
        guard let components = URLComponents(string: urlString),
              components.host == host,
              let productId = components.queryItems?.first(where: { $0.name == "productId" })?.value,
              !productId.isEmpty else { return false }

        DispatchQueue.main.async {
            let window = (UIApplication.shared.delegate as? AppDelegate)?.window
            guard let nav = window?.rootViewController as? UINavigationController else { return }
            nav.pushViewController(RecommendationOrderViewController(productId: productId), animated: true)
        }
        return true
    }

    // MARK: - Properties
    private let productId: String

    private lazy var productIdLabel: UILabel = {
        let view = UILabel()
        view.text = "Product ID: \(productId)"
        view.textAlignment = .center
        view.numberOfLines = 0
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()

    private lazy var quantityTextField: UITextField = {
        let view = makeTextField(placeholder: "Quantity")
        view.text = "1"
        view.keyboardType = .numberPad
        return view
    }()

    private lazy var unitPriceTextField: UITextField = {
        let view = makeTextField(placeholder: "Unit Price")
        view.text = "995000"
        view.keyboardType = .decimalPad
        return view
    }()

    private lazy var paymentMethodTextField: UITextField = {
        let view = makeTextField(placeholder: "Payment Method")
        view.text = "card"
        return view
    }()

    private lazy var couponCodeTextField: UITextField = makeTextField(placeholder: "Coupon Code")

    private lazy var orderButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Send Order Event", for: .normal)
        view.titleLabel?.font = .boldSystemFont(ofSize: 18)
        view.addTarget(self, action: #selector(didTapOrderButton), for: .touchUpInside)
        return view
    }()

    private lazy var resultTextView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        view.textColor = .darkGray
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            productIdLabel,
            quantityTextField,
            unitPriceTextField,
            paymentMethodTextField,
            couponCodeTextField,
            orderButton,
            resultTextView
        ])
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(productId: String) {
        self.productId = productId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recommendation Order"
        view.backgroundColor = .white
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaBottomAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }

    // MARK: - Actions
    @objc private func didTapOrderButton() {
        view.endEditing(true)

        let quantity = Int(quantityTextField.text ?? "") ?? 1
        let unitPrice = Double(unitPriceTextField.text ?? "") ?? 0
        let totalAmount = unitPrice * Double(quantity)
        let paymentMethod = paymentMethodTextField.text ?? ""
        let orderId = Int.random(in: 1_000_000...9_999_999)

        let orderParameters: [String: Any] = [
            "order_id": orderId,
            "item_count": quantity,
            "total_amount": totalAmount,
            "payment_method": paymentMethod,
            "shipping": 1,
            "discounted_price": totalAmount,
            "coupon_code": couponCodeTextField.text ?? "",
            "event_type": "order"
        ]

        let orderDetailParameters: [String: Any] = [
            "product_id": productId,
            "product_variant_id": "1",
            "quantity": quantity,
            "unit_price": formatted(unitPrice),
            "discounted_price": formatted(unitPrice),
            "order_id": orderId,
            "payment_method": paymentMethod,
            "event_type": "order"
        ]

        Dengage.sendCustomEvent(eventTable: "order_events", parameters: orderParameters)
        Dengage.sendCustomEvent(eventTable: "order_events_detail", parameters: orderDetailParameters)

        resultTextView.text = """
        Sent order \(orderId)

        order_events:
        \(prettyPrinted(orderParameters))

        order_events_detail:
        \(prettyPrinted(orderDetailParameters))
        """
    }
}

// MARK: - Helpers
private extension RecommendationOrderViewController {

    func makeTextField(placeholder: String) -> UITextField {
        let view = UITextField()
        view.placeholder = placeholder
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.autocapitalizationType = .none
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return view
    }

    func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
    }

    func prettyPrinted(_ parameters: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else { return "\(parameters)" }
        return string
    }
}

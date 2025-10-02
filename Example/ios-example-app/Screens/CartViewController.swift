import UIKit
import Dengage

final class CartViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var addItemButton: UIButton = {
        let view = UIButton()
        view.setTitle("Add Item", for: .normal)
        view.addTarget(self, action: #selector(didTapAddItemButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var updateCartButton: UIButton = {
        let view = UIButton()
        view.setTitle("Update Cart", for: .normal)
        view.addTarget(self, action: #selector(didTapUpdateCartButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addItemButton, updateCartButton])
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cartItemsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            buttonStackView,
            cartItemsStackView
        ])
        view.axis = .vertical
        view.spacing = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cartItems: [CartItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentCart()
    }
    
    private func setupUI(){
        title = "Cart"
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            addItemButton.heightAnchor.constraint(equalToConstant: 44),
            updateCartButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func loadCurrentCart() {
        do {
            let currentCart = Dengage.getCart()
            cartItems = currentCart.items
            
            showToast("Loading cart: \(currentCart.items.count) items")
            
            // Clear existing cart item views
            for view in cartItemsStackView.arrangedSubviews {
                if view is CartItemView {
                    cartItemsStackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }
            
            // Add cart item views
            for (index, cartItem) in cartItems.enumerated() {
                let cartItemView = CartItemView(cartItem: cartItem) { [weak self] in
                    self?.removeCartItem(at: index)
                }
                cartItemsStackView.addArrangedSubview(cartItemView)
            }
            
        } catch {
            showToast("Error loading cart: \(error.localizedDescription)")
        }
    }
    
    @objc private func didTapAddItemButton() {
        let newItem = CartItem(
            productId: "",
            productVariantId: "",
            categoryPath: "",
            price: 0,
            discountedPrice: 0,
            hasDiscount: false,
            hasPromotion: false,
            quantity: 1,
            attributes: [:]
        )
        
        cartItems.append(newItem)
        
        let cartItemView = CartItemView(cartItem: newItem) { [weak self] in
            self?.removeCartItem(at: self?.cartItems.count ?? 0 - 1)
        }
        cartItemsStackView.addArrangedSubview(cartItemView)
        
        showToast("New item added")
    }
    
    @objc private func didTapUpdateCartButton() {
        do {
            // Get updated items from cart item views
            let cartItemViews = cartItemsStackView.arrangedSubviews.compactMap { $0 as? CartItemView }
            let updatedItems = cartItemViews.compactMap { $0.getUpdatedCartItem() }
            
            showToast("Retrieved \(updatedItems.count) items from views")
            
            // Create new cart with updated items
            let newCart = Cart(items: updatedItems)
            
            // Update cart in SDK
            Dengage.setCart(cart: newCart)
            
            // Update local cart items
            cartItems = updatedItems
            
            showToast("Cart updated successfully!")
            
        } catch {
            showToast("Error updating cart: \(error.localizedDescription)")
        }
    }
    
    private func removeCartItem(at index: Int) {
        guard index >= 0 && index < cartItems.count else { return }
        
        cartItems.remove(at: index)
        
        // Remove corresponding view
        let cartItemViews = cartItemsStackView.arrangedSubviews.compactMap { $0 as? CartItemView }
        if index < cartItemViews.count {
            let viewToRemove = cartItemViews[index]
            cartItemsStackView.removeArrangedSubview(viewToRemove)
            viewToRemove.removeFromSuperview()
        }
        
        showToast("Item removed")
    }
    
    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - CartItemView
extension CartViewController {
    final class CartItemView: UIView {
        
        private lazy var productIdTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "Product ID"
            view.borderStyle = .roundedRect
            view.font = .systemFont(ofSize: 12)
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var productVariantIdTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "Product Variant ID"
            view.borderStyle = .roundedRect
            view.font = .systemFont(ofSize: 12)
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var categoryPathTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "Category Path"
            view.borderStyle = .roundedRect
            view.font = .systemFont(ofSize: 12)
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var priceTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "Price"
            view.borderStyle = .roundedRect
            view.keyboardType = .numberPad
            view.font = .systemFont(ofSize: 12)
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var discountedPriceTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "Discounted Price"
            view.borderStyle = .roundedRect
            view.keyboardType = .numberPad
            view.font = .systemFont(ofSize: 12)
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var quantityTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "Quantity"
            view.borderStyle = .roundedRect
            view.keyboardType = .numberPad
            view.font = .systemFont(ofSize: 12)
            view.autocapitalizationType = .none
            return view
        }()
        
        private lazy var hasDiscountSwitch: UISwitch = {
            let view = UISwitch()
            return view
        }()
        
        private lazy var hasPromotionSwitch: UISwitch = {
            let view = UISwitch()
            return view
        }()
        
        private lazy var effectivePriceLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 11)
            view.textColor = .darkGray
            view.text = "Effective Price: 0"
            return view
        }()
        
        private lazy var lineTotalLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 11)
            view.textColor = .darkGray
            view.text = "Line Total: 0"
            return view
        }()
        
        private lazy var discountedLineTotalLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 11)
            view.textColor = .darkGray
            view.text = "Discounted Line Total: 0"
            return view
        }()
        
        private lazy var effectiveLineTotalLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 11)
            view.textColor = .darkGray
            view.text = "Effective Line Total: 0"
            return view
        }()
        
        private lazy var removeButton: UIButton = {
            let view = UIButton(type: .system)
            view.setTitle("Remove", for: .normal)
            view.setTitleColor(.red, for: .normal)
            view.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
            return view
        }()
        
        private let onRemove: () -> Void
        private var cartItem: CartItem
        
        init(cartItem: CartItem, onRemove: @escaping () -> Void) {
            self.cartItem = cartItem
            self.onRemove = onRemove
            super.init(frame: .zero)
            setupUI()
            populateFields()
            setupTextFieldTargets()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            layer.cornerRadius = 8
            layer.borderWidth = 1
            layer.borderColor = UIColor.lightGray.cgColor
            
            let priceStackView = UIStackView(arrangedSubviews: [priceTextField, discountedPriceTextField])
            priceStackView.axis = .horizontal
            priceStackView.spacing = 8
            priceStackView.distribution = .fillEqually
            
            let switchStackView = UIStackView(arrangedSubviews: [
                createLabeledSwitch(label: "Has Discount", switch: hasDiscountSwitch),
                createLabeledSwitch(label: "Has Promotion", switch: hasPromotionSwitch)
            ])
            switchStackView.axis = .horizontal
            switchStackView.spacing = 16
            switchStackView.distribution = .fillEqually
            
            let calculatedFieldsStackView = UIStackView(arrangedSubviews: [
                effectivePriceLabel,
                lineTotalLabel,
                discountedLineTotalLabel,
                effectiveLineTotalLabel
            ])
            calculatedFieldsStackView.axis = .vertical
            calculatedFieldsStackView.spacing = 2
            
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            let bottomStackView = UIStackView(arrangedSubviews: [calculatedFieldsStackView, removeButton])
            bottomStackView.axis = .horizontal
            bottomStackView.alignment = .center
            bottomStackView.spacing = 8
            
            let mainStackView = UIStackView(arrangedSubviews: [
                productIdTextField,
                productVariantIdTextField,
                categoryPathTextField,
                priceStackView,
                UIStackView(arrangedSubviews: [quantityTextField, switchStackView]),
                separatorView,
                bottomStackView
            ])
            mainStackView.axis = .vertical
            mainStackView.spacing = 8
            mainStackView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(mainStackView)
            NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            ])
        }
        
        private func createLabeledSwitch(label: String, switch: UISwitch) -> UIStackView {
            let labelView = UILabel()
            labelView.text = label
            labelView.font = .systemFont(ofSize: 11)
            
            let stackView = UIStackView(arrangedSubviews: [labelView, `switch`])
            stackView.axis = .horizontal
            stackView.spacing = 4
            stackView.alignment = .center
            
            return stackView
        }
        
        private func populateFields() {
            productIdTextField.text = cartItem.productId
            productVariantIdTextField.text = cartItem.productVariantId
            categoryPathTextField.text = cartItem.categoryPath
            priceTextField.text = "\(cartItem.price)"
            discountedPriceTextField.text = "\(cartItem.discountedPrice)"
            quantityTextField.text = "\(cartItem.quantity)"
            hasDiscountSwitch.isOn = cartItem.hasDiscount
            hasPromotionSwitch.isOn = cartItem.hasPromotion
            
            updateCalculatedFields()
        }
        
        private func setupTextFieldTargets() {
            [productIdTextField, productVariantIdTextField, categoryPathTextField, 
             priceTextField, discountedPriceTextField, quantityTextField].forEach {
                $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            }
            
            hasDiscountSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
            hasPromotionSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
        }
        
        @objc private func textFieldDidChange() {
            updateCalculatedFields()
        }
        
        @objc private func switchDidChange() {
            updateCalculatedFields()
        }
        
        private func updateCalculatedFields() {
            let updatedItem = getUpdatedCartItem()
            effectivePriceLabel.text = "Effective Price: \(updatedItem.effectivePrice)"
            lineTotalLabel.text = "Line Total: \(updatedItem.lineTotal)"
            discountedLineTotalLabel.text = "Discounted Line Total: \(updatedItem.discountedLineTotal)"
            effectiveLineTotalLabel.text = "Effective Line Total: \(updatedItem.effectiveLineTotal)"
        }
        
        func getUpdatedCartItem() -> CartItem {
            return CartItem(
                productId: productIdTextField.text ?? "",
                productVariantId: productVariantIdTextField.text ?? "",
                categoryPath: categoryPathTextField.text ?? "",
                price: Int(priceTextField.text ?? "0") ?? 0,
                discountedPrice: Int(discountedPriceTextField.text ?? "0") ?? 0,
                hasDiscount: hasDiscountSwitch.isOn,
                hasPromotion: hasPromotionSwitch.isOn,
                quantity: Int(quantityTextField.text ?? "0") ?? 0,
                attributes: [:]
            )
        }
        
        @objc private func didTapRemoveButton() {
            onRemove()
        }
    }
}

extension CartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

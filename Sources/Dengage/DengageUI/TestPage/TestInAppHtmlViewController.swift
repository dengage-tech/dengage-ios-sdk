//
//  TestInAppHtmlViewController.swift
//  Dengage
//
//  Created by Egemen Gülkılık on 27.11.2024.
//

import Foundation
import UIKit

extension TestInAppHtmlViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

final class TestInAppHtmlViewController: UIViewController {
    
    var selectedContentPosition: ContentPosition = .middle
    
    var inAppMessageWindow: UIWindow?
    var inAppBrowserWindow: UIWindow?
    var dengageInAppManager = Dengage.manager?.inAppManager
    
    private lazy var contentIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Content Id"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        view.text = "bd12edca-3fe3-4875-beb7-88b675099988"
        return view
    }()
    
    private lazy var publicIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Public Id"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        view.text = "b4c0a551-3c68-46d9-a1bc-c10a044d216b"
        return view
    }()
    
    private lazy var shouldAnimateLabel: UILabel = {
       let label = UILabel()
       label.text = "Should Animate:"
       label.font = UIFont.systemFont(ofSize: 14)
       label.textAlignment = .left
       return label
   }()
    
    private lazy var shouldAnimateSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false
        return switchControl
    }()
    
    private lazy var maxWidthTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Max Width"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.text = "300"
        return view
    }()
    
    private lazy var radiusTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Radius"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.text = "20"
        return view
    }()
    
    private lazy var marginTopTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Margin Top"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.text = "0"
        return view
    }()
    
    private lazy var marginBottomTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Margin Bottom"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.text = "0"
        return view
    }()
    
    private lazy var marginLeftTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Margin Left"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.text = "0"
        return view
    }()
    
    private lazy var marginRightTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Margin Right"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.text = "0"
        return view
    }()
    
    private lazy var dismissOnTouchOutsideLabel: UILabel = {
        let label = UILabel()
        label.text = "Dismiss on Touch Outside:"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var dismissOnTouchOutsideSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        return switchControl
    }()
    
    private lazy var backgroundColorTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Background Color"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.text = "#C46BDE2E"
        return view
    }()
    
    private lazy var contentPositionSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ContentPosition.allCases.map { $0.rawValue })
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(contentPositionChanged(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var setHtmlView: UITextView = {
        let view = UITextView()
        view.text = ""
        view.textAlignment = .left
        view.font = UIFont.systemFont(ofSize: 14) // Yazı tipi, UITextField ile aynı
        view.autocapitalizationType = .none
        view.isEditable = true
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.delegate = self
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your HTML here"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    
    private lazy var stackView: UIStackView = {
        
        let shouldAnimateStack = UIStackView(arrangedSubviews: [shouldAnimateLabel, shouldAnimateSwitch])
        shouldAnimateStack.axis = .horizontal
        shouldAnimateStack.spacing = 10

        let dismissOnTouchOutsideStack = UIStackView(arrangedSubviews: [dismissOnTouchOutsideLabel, dismissOnTouchOutsideSwitch])
        dismissOnTouchOutsideStack.axis = .horizontal
        dismissOnTouchOutsideStack.spacing = 10

        
        let view = UIStackView(arrangedSubviews: [
            contentIdTextField,
            publicIdTextField,
            contentPositionSegmentedControl,
            setHtmlView,
            shouldAnimateStack,
            maxWidthTextField,
            radiusTextField,
            marginTopTextField,
            marginBottomTextField,
            marginLeftTextField,
            marginRightTextField,
            dismissOnTouchOutsideStack,
            backgroundColorTextField,
            showButton
        ])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setHtmlView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: setHtmlView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: setHtmlView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: setHtmlView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupUI(){
        title = "In App Html Test"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    }
    
    @objc private func contentPositionChanged(_ sender: UISegmentedControl) {
        if let selectedValue = ContentPosition(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "") {
            selectedContentPosition = selectedValue
        }
    }
    
    @objc private func didTapShowButton() {
        
        let contentParams = ContentParams(
            position: selectedContentPosition,
            shouldAnimate: shouldAnimateSwitch.isOn,
            html: setHtmlView.text,
            maxWidth: CGFloat(Double(maxWidthTextField.text ?? "300") ?? 300),
            radius: Int(radiusTextField.text ?? "20") ?? 20,
            marginTop: CGFloat(Double(marginTopTextField.text ?? "0") ?? 0),
            marginBottom: CGFloat(Double(marginBottomTextField.text ?? "0") ?? 0),
            marginLeft: CGFloat(Double(marginLeftTextField.text ?? "0") ?? 0),
            marginRight: CGFloat(Double(marginRightTextField.text ?? "0") ?? 0),
            dismissOnTouchOutside: dismissOnTouchOutsideSwitch.isOn,
            backgroundColor: backgroundColorTextField.text ?? "#00000000",
            storySet: nil
        )
        
        let content = Content(
            type: "IMAGE_MODAL",
            props: contentParams,
            contentId: contentIdTextField.text ?? ""
        )
        
        let ruleSet = RuleSet(
            logicOperator: .AND,
            rules: []
        )
        
        let displayCondition = DisplayCondition(
            screenNameFilters: [],
            ruleSet: ruleSet,
            screenNameFilterLogicOperator: .AND
        )
        
        // DisplayTiming oluşturma
        let displayTiming = DisplayTiming(
            delay: 0,
            showEveryXMinutes: 0,
            maxShowCount: 0,
            maxDismissCount: 0
        )
        
        let inAppMessageData = InAppMessageData(
            messageDetailId: publicIdTextField.text ?? "",
            expireDate: "9999-12-31T23:59:59.999Z",
            priority: .high,
            content: content,
            displayCondition: displayCondition,
            displayTiming: displayTiming,
            publicId: publicIdTextField.text ?? "",
            inlineTarget: nil
        )
        
        // InAppMessage oluşturma
        let inAppMessage = InAppMessage(
            id: publicIdTextField.text ?? "",
            data: inAppMessageData,
            nextDisplayTime: nil ,
            showCount: 100
        )
        
        dengageInAppManager?.showInAppMessage(inAppMessage: inAppMessage)
    }
    
}



extension TestInAppHtmlViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension UIView {
    
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, topPadding: CGFloat = 0, leadingPadding: CGFloat = 0, bottomPadding: CGFloat = 0, trailingPadding: CGFloat = 0, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: leadingPadding).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -trailingPadding).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func sizeAnchor(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    
    func fillSuperview(with padding: UIEdgeInsets = .zero) {
        anchor(top: superview?.topAnchor,
               leading: superview?.leadingAnchor,
               bottom: superview?.bottomAnchor,
               trailing: superview?.trailingAnchor,
               topPadding: padding.top,
               leadingPadding: padding.left,
               bottomPadding: padding.bottom,
               trailingPadding: padding.right)
    }
    
}

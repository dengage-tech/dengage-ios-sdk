import UIKit
import WebKit

final class InAppMessageHTMLView: UIView {
    
    private(set) lazy var webView: WKWebView = {
        let view = WKWebView()
        view.scrollView.isScrollEnabled = true
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.bounces = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private var bottomConstraint: NSLayoutConstraint?
    private var centerConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?

    // Edge (non-safe-area) constraints used for the .full position so the content
    // covers the entire screen, including the status bar/notch and home indicator.
    private var fullTopConstraint: NSLayoutConstraint?
    private var fullBottomConstraint: NSLayoutConstraint?
    private var fullLeadingConstraint: NSLayoutConstraint?
    private var fullTrailingConstraint: NSLayoutConstraint?

    var height: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = self.safeAreaLayoutGuide

        leftConstraint = webView.leadingAnchor.constraint(lessThanOrEqualTo: safeArea.leadingAnchor)
        rightConstraint = webView.trailingAnchor.constraint(greaterThanOrEqualTo: safeArea.trailingAnchor)
        topConstraint = webView.topAnchor.constraint(equalTo: safeArea.topAnchor)
        bottomConstraint = webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        centerConstraint = webView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)

        fullTopConstraint = webView.topAnchor.constraint(equalTo: topAnchor)
        fullBottomConstraint = webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        fullLeadingConstraint = webView.leadingAnchor.constraint(equalTo: leadingAnchor)
        fullTrailingConstraint = webView.trailingAnchor.constraint(equalTo: trailingAnchor)

        height = webView.heightAnchor.constraint(equalToConstant: 0)
        height?.isActive = true
    }

    
    
    func setupConstraints(for params: ContentParams, message: InAppMessage) {
        backgroundColor = UIColor(hex: params.backgroundColor ?? "") ?? .clear
        
        setCornerRadius(params.radius)
        
        topConstraint?.constant = verticalPercentage(params.marginTop)
        bottomConstraint?.constant = -verticalPercentage(params.marginBottom)
        leftConstraint?.constant = horizontalPercentage(params.marginLeft, message: message)
        rightConstraint?.constant = -horizontalPercentage(params.marginRight, message: message)
        
        switch params.position {
        case .top:
            leftConstraint?.isActive = true
            rightConstraint?.isActive = true
            topConstraint?.isActive = true
        case .middle:
            leftConstraint?.isActive = true
            rightConstraint?.isActive = true
            centerConstraint?.isActive = true
        case .bottom:
            leftConstraint?.isActive = true
            rightConstraint?.isActive = true
            bottomConstraint?.isActive = true
        case .full:
            // Cover the whole screen: pin to the view's real edges instead of the
            // safe area, and let the WebView fill top-to-bottom (drop the height
            // constraint so it isn't capped to the measured content height).
            height?.isActive = false
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            fullLeadingConstraint?.isActive = true
            fullTrailingConstraint?.isActive = true
            fullTopConstraint?.isActive = true
            fullBottomConstraint?.isActive = true
        }
    }
    
    private func setCornerRadius(_ radius: Int?) {
        let corner = CGFloat(radius ?? 0)
        webView.layer.cornerRadius = corner
        layer.cornerRadius = corner
        clipsToBounds = true
    }
    
    private func setMaxWidth(_ width: CGFloat?) {
        guard let width = width else { return }
        webView.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
    }
    
    private func verticalPercentage(_ margin: CGFloat?) -> CGFloat {
        (UIScreen.main.bounds.height * ((margin ?? 1.0) / 100))
    }
    
    private func horizontalPercentage(_ margin: CGFloat?, message: InAppMessage) -> CGFloat {
        guard let margin = margin else { return 0 }
        
        if margin == 0 {
            switch message.data.content.props.position {
            case .full, .top, .bottom:
                return 0
            default:
                return UIScreen.main.bounds.width * 0.04
            }
        }
        return UIScreen.main.bounds.width * (margin / 100)
    }
}

final class InAppBrowserView: UIView {
    
    private(set) lazy var webView: WKWebView = {
        let view = WKWebView()
        view.scrollView.isScrollEnabled = true
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.bounces = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        addSubview(webView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCornerRadius(_ radius: Int?) {
        let corner = CGFloat(radius ?? 0)
        webView.layer.cornerRadius = corner
        layer.cornerRadius = corner
        clipsToBounds = true
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        guard hex.hasPrefix("#") else { return nil }
        let startIndex = hex.index(hex.startIndex, offsetBy: 1)
        var hexColor = String(hex[startIndex...])
        
        if hexColor.count == 3 {
            hexColor = hexColor.map { "\($0)\($0)" }.joined()
        }
        
        if hexColor.count == 6 {
            var hexNumber: UInt64 = 0
            Scanner(string: hexColor).scanHexInt64(&hexNumber)
            self.init(
                red:   CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((hexNumber & 0x00FF00) >>  8) / 255.0,
                blue:  CGFloat( hexNumber & 0x0000FF       ) / 255.0,
                alpha: 1.0
            )
            return
        } else if hexColor.count == 8 {
            var hexNumber: UInt64 = 0
            let scanner = Scanner(string: hexColor)
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >>  8) / 255
                a = CGFloat( hexNumber & 0x000000ff       ) / 255
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        
        return nil
    }
}

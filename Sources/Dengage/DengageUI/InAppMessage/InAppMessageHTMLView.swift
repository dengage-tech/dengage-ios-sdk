import UIKit
import WebKit
final class InAppMessageHTMLView: UIView{
    
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

    var height: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(webView)
        leftConstraint = webView
            .leadingAnchor
            .constraint(lessThanOrEqualTo: leadingAnchor,
                        constant: 0)
        
        rightConstraint = webView
            .trailingAnchor
            .constraint(greaterThanOrEqualTo: trailingAnchor,
                        constant: 0)
        
        height = webView
            .heightAnchor
            .constraint(equalToConstant: 0)
        
        height?.isActive = true
        
        bottomConstraint = webView
            .bottomAnchor
            .constraint(equalTo: bottomAnchor,
                        constant: 0)
        centerConstraint = webView
            .centerYAnchor
            .constraint(equalTo: centerYAnchor,
                        constant: 0)
        topConstraint = webView
            .topAnchor
            .constraint(equalTo: topAnchor,
                        constant: 0)
    }
    
    private func set(radius:Int?){
        webView.layer.cornerRadius = CGFloat(radius ?? 0)
        self.layer.cornerRadius = CGFloat(radius ?? 0)
        self.clipsToBounds = true

    }
    
    private func set(maxWidth:CGFloat?){
        guard let width = maxWidth else {return}
        webView.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
    }
    
    func setupConstaints(for params: ContentParams , message :InAppMessage){
        //set(maxWidth: params.maxWidth)
        
        if let color = params.backgroundColor
        {
            backgroundColor = UIColor.init(hex: color)

        }
        else
        {
            backgroundColor = UIColor.clear

        }
        
        set(radius: params.radius)
        topConstraint?.constant = getVerticalByPercentage(for: params.marginTop)
        bottomConstraint?.constant = -getVerticalByPercentage(for:params.marginBottom)
        leftConstraint?.constant = getHorizaltalByPercentage(for:params.marginLeft, message: message)
        rightConstraint?.constant = -getHorizaltalByPercentage(for:params.marginRight, message: message)
        leftConstraint?.isActive = true
        rightConstraint?.isActive = true
        switch params.position{
        case .top:
            topConstraint?.isActive = true
        case .middle:
            centerConstraint?.isActive = true
        case .bottom:
            bottomConstraint?.isActive = true
        case .full:
            topConstraint?.isActive = true
            bottomConstraint?.isActive = true
        }
    }
    
    func getVerticalByPercentage(for margin: CGFloat?) -> CGFloat {
        return (UIScreen.main.bounds.height * ((margin ?? 1.0) / 100))
    }
    
    func getHorizaltalByPercentage(for margin: CGFloat? , message : InAppMessage) -> CGFloat {
        
        
        if margin == 0
        {
            if message.data.content.props.position == .full
            {
                
                return (UIScreen.main.bounds.width * ((margin ?? 1.0) / 100))


            }
            else if message.data.content.props.position == .top
            {
                
                return (UIScreen.main.bounds.width * ((margin ?? 1.0) / 100))


            }
            else if message.data.content.props.position == .bottom
            {
                
                return (UIScreen.main.bounds.width * ((margin ?? 1.0) / 100))


            }

            else
            {
                return (UIScreen.main.bounds.width * (4 / 100))

            }
        }
        else
        {
            return (UIScreen.main.bounds.width * ((margin ?? 1.0) / 100))

        }
       
        

    }
}

final class InAppBrowserView: UIView{
    
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
        super.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(webView)
        
        
    }
    
    private func set(radius:Int?){
        webView.layer.cornerRadius = CGFloat(radius ?? 0)
        self.layer.cornerRadius = CGFloat(radius ?? 0)
        self.clipsToBounds = true

    }
   
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

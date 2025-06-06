import UIKit
import WebKit
final class InAppMessageHTMLViewController: UIViewController{
    
    private lazy var viewSource:InAppMessageHTMLView = {
        let view = InAppMessageHTMLView()
        view.webView.navigationDelegate = self
        return view
    }()
    
    var delegate: InAppMessagesActionsDelegate?
    
    
    let message:InAppMessage
    
    var isIosURLNPresent = false
    var isClicked = false

    var hasTopNotch: Bool {
        
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            {
                return true
                
            }
            else {
                // Fallback on earlier versions
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20

            }
        }
        
        
        return false
    }
    
    init(with message: InAppMessage) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = viewSource
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupJavascript()
        
        
        viewSource.setupConstaints(for: message.data.content.props , message : message)
        
        
        
        if let isPresent = message.data.content.props.html?.contains("Dn.iosUrlN") {
            
            self.isIosURLNPresent = isPresent
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
        guard message.data.content.props.dismissOnTouchOutside else { return }
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.viewSource.webView.alpha = 0.0
            
        },completion: { (finished: Bool) in
            self.delegate?.sendDissmissEvent(message: self.message)
            self.delegate?.close()
        })
    }
    
    private func setupJavascript(){
        
        let userScript = WKUserScript(source: javascriptInterface,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
        viewSource.webView.configuration.userContentController.addUserScript(userScript)
        
        if #available(iOS 14.0, *) {
            viewSource.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            viewSource.webView.configuration.preferences.javaScriptEnabled = true
        }
        
        viewSource.webView.configuration.userContentController.add(self, name: "dismiss")
        viewSource.webView.configuration.userContentController.add(self, name: "close")
        viewSource.webView.configuration.userContentController.add(self, name: "closeN")
        viewSource.webView.configuration.userContentController.add(self, name: "iosUrl")
        viewSource.webView.configuration.userContentController.add(self, name: "iosUrlN")
        viewSource.webView.configuration.userContentController.add(self, name: "sendClick")
        viewSource.webView.configuration.userContentController.add(self, name: "promptPushPermission")
        viewSource.webView.configuration.userContentController.add(self, name: "setTags")
        viewSource.webView.loadHTMLString(message.data.content.props.html!, baseURL: nil)
        
        viewSource.webView.contentMode = .scaleAspectFit
        viewSource.webView.sizeToFit()
        viewSource.webView.autoresizesSubviews = true
        
    }
}

extension InAppMessageHTMLViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        setWebViewHeight()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme, !scheme.contains("dengage") else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    private func setWebViewHeight(){
        guard viewSource.webView.url?.absoluteString == "about:blank" else { return }
        viewSource.webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            guard let scrollHeight = height as? CGFloat else {return}
            
            if scrollHeight > self.viewSource.frame.height
            {
                self.viewSource.height?.constant = self.viewSource.frame.height
                
            }
            else
            {
                self.viewSource.height?.constant = scrollHeight
                
            }
            
            if self.hasTopNotch
            {
                if self.message.data.content.props.position == .top
                {
                    self.viewSource.height?.constant = scrollHeight + 50
                    
                }
                
            }
            
            
        })
    }
}

extension InAppMessageHTMLViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        run(message: message)
    }
    
    private func run(message: WKScriptMessage){
        
        switch message.name {
            
        case "sendClick":
            let buttonId = message.body as? String
            isClicked = true
            self.delegate?.sendClickEvent(message: self.message,
                                          buttonId: buttonId)
            
            break
        case "iosUrl":
            
            if !isIosURLNPresent
            {
                if message.body as? String == "Dn.promptPushPermission()"
                {
                    delegate?.promptPushPermission()
                    
                }
                else if message.body as? String == "DN.SHOWRATING()"
                {
                    Dengage.showRatingView()
                }
                else
                {
                    guard let url = message.body as? String else {return}
                    self.delegate?.open(url: url)
                }
                
            }
            
            break
        case "iosUrlN":
            
            guard let dict = message.body as? [String:Any] else {return}
            
            if let openInAppBrowser = dict["openInAppBrowser"] as? Bool
            {
                DengageLocalStorage.shared.set(value: openInAppBrowser, for: .openInAppBrowser)
                
            }
            else
            {
                DengageLocalStorage.shared.set(value: false, for: .openInAppBrowser)
                
            }
            if let retrieveLinkOnSameScreen = dict["retrieveLinkOnSameScreen"] as? Bool
            {
                DengageLocalStorage.shared.set(value: retrieveLinkOnSameScreen, for: .retrieveLinkOnSameScreen)
                
            }
            else
            {
                DengageLocalStorage.shared.set(value: false, for: .retrieveLinkOnSameScreen)
            }
            
            if let deeplink = dict["deeplink"] as? String
            {
                if deeplink == "Dn.promptPushPermission()"
                {
                    delegate?.promptPushPermission()
                    
                }
                else if deeplink == "DN.SHOWRATING()"
                {
                    Dengage.showRatingView()
                }
                else
                {
                    self.delegate?.open(url: deeplink)
                }
                
            }
            break
        case "setTags":
            
            guard let tagItemData = message.body as? [Dictionary<String,String>] else {return}
            let tagItems = tagItemData.map{TagItem.init(with: $0)}
            self.delegate?.setTags(tags: tagItems)
            
            break
        case "promptPushPermission":
            delegate?.promptPushPermission()
            break
        case "dismiss":
            if !isClicked
            {
                isClicked = true
                delegate?.sendDissmissEvent(message: self.message)

            }
            break
        case "close":
            if !isClicked
            {
                isClicked = true
                delegate?.sendDissmissEvent(message: self.message)

            }
            if !isIosURLNPresent
            {
                delegate?.close()
                
            }
            break
        case "closeN":
            if !isClicked
            {
                isClicked = true
                delegate?.sendDissmissEvent(message: self.message)

            }
            delegate?.close()
            break
        default:
            break
        }
        
        
    }
}

extension InAppMessageHTMLViewController{
    fileprivate var javascriptInterface:String{
        return """
        var Dn =  {
            iosUrl: (url) => {
                window.webkit.messageHandlers.iosUrl.postMessage(url);
            },
            iosUrlN:(url,inbr,ret) => {
        
                window.webkit.messageHandlers.iosUrlN.postMessage({deeplink : url,openInAppBrowser : inbr,retrieveLinkOnSameScreen : ret});
            },
            androidUrl: (url) => {},
            androidUrlN: (url,inbr,ret) => {},
            sendClick: (eventName) => {
                window.webkit.messageHandlers.sendClick.postMessage(eventName);
            },
            dismiss: () => {
                window.webkit.messageHandlers.dismiss.postMessage(null);
            },
            close: () => {
                window.webkit.messageHandlers.close.postMessage(null);
            },
            closeN: () => {
                window.webkit.messageHandlers.closeN.postMessage(null);
            },
            setTags: (tags) => {
                window.webkit.messageHandlers.setTags.postMessage(tags);
            },
            promptPushPermission: () => {
                window.webkit.messageHandlers.promptPushPermission.postMessage(null);
            }
        }
        """
    }
}

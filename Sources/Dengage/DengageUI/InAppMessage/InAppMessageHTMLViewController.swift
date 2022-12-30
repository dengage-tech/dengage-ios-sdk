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

    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
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
        viewSource.setupConstaints(for: message.data.content.props)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
        guard message.data.content.props.dismissOnTouchOutside else { return }
         UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.viewSource.webView.alpha = 0.0
             
         },completion: { (finished: Bool) in
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
        viewSource.webView.configuration.userContentController.add(self, name: "iosUrl")
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
            else
            {
                self.viewSource.height?.constant = scrollHeight + 20

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
            self.delegate?.sendClickEvent(message: self.message,
                                          buttonId: buttonId)
        case "iosUrl":
             
            if message.body as? String == "Dn.promptPushPermission()"
            {
                delegate?.promptPushPermission()

            }
            else
            {
                guard let url = message.body as? String else {return}
                print("WKScriptMessage In app message \(url)")
                self.delegate?.open(url: url)
            }
          
        case "setTags":
            guard let tagItemData = message.body as? [Dictionary<String,String>] else {return}
            let tagItems = tagItemData.map{TagItem.init(with: $0)}
            self.delegate?.setTags(tags: tagItems)
        case "promptPushPermission":
            delegate?.promptPushPermission()
        case "dismiss":
            delegate?.sendDissmissEvent(message: self.message)
        case "close":
            delegate?.close()
        default:
            break
        }
    }
}

extension InAppMessageHTMLViewController{
    fileprivate var javascriptInterface:String{
        return """
        var Dn = {
            iosUrl: (url) => {
                window.webkit.messageHandlers.iosUrl.postMessage(url);
            },
            androidUrl: (url) => {},
            sendClick: (eventName) => {
                window.webkit.messageHandlers.sendClick.postMessage(eventName);
            },
            dismiss: () => {
                window.webkit.messageHandlers.dismiss.postMessage(null);
            },
            close: () => {
                window.webkit.messageHandlers.close.postMessage(null);
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

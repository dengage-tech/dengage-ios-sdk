import UIKit
import WebKit
final class InAppBrowserViewController: UIViewController,WKNavigationDelegate{
    
    private lazy var viewSource:InAppBrowserView = {
        let view = InAppBrowserView()
        view.webView.navigationDelegate = self
        return view
    }()

    var delegate: InAppMessagesActionsDelegate?
    var Activity: UIActivityIndicatorView!
    let url:String
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
    
    
    init(with url: String) {
        
        self.url = url
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(viewSource)

        self.view.backgroundColor = .gray
        if let link = URL(string:self.url)
        {
            let request = URLRequest(url: link)
            viewSource.webView.load(request)
        }
        
        if hasTopNotch
        {
            if #available(iOS 13.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                {
                    let top = scene.windows.first?.safeAreaInsets.top ?? 0
                    let navbar = UINavigationBar(frame: CGRect(x: 0, y: top, width: UIScreen.main.bounds.width, height: 44))
                    navbar.backgroundColor = UIColor.white

                    let navItem = UINavigationItem()
                    navItem.title = self.url
                    navItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(self.dismiss(sender:)))

                    navbar.items = [navItem]

                    self.view.addSubview(navbar)
                    
                    self.Activity = UIActivityIndicatorView()
                    self.Activity.center = self.view.center
                    self.Activity.startAnimating()
                    self.Activity.hidesWhenStopped = true
                    self.Activity.style = .gray
                    self.viewSource.webView.addSubview(self.Activity)

                    self.viewSource.webView.navigationDelegate = self

                    viewSource.webView.frame = .init(x: 0, y:44 + top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44 - top)
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(sender:)))
                    self.view.addGestureRecognizer(tapGesture)

                }
                else
                {
                    // Fallback on earlier versions
                    
                    let top = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
                    let navbar = UINavigationBar(frame: CGRect(x: 0, y: top, width: UIScreen.main.bounds.width, height: 44))
                    navbar.backgroundColor = UIColor.white

                    let navItem = UINavigationItem()
                    navItem.title = self.url
                    navItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(self.dismiss(sender:)))

                    navbar.items = [navItem]

                    self.view.addSubview(navbar)
                    
                    self.Activity = UIActivityIndicatorView()
                    self.Activity.center = self.view.center
                    self.Activity.startAnimating()
                    self.Activity.hidesWhenStopped = true
                    self.Activity.style = .gray
                    self.viewSource.webView.addSubview(self.Activity)

                    self.viewSource.webView.navigationDelegate = self

                    viewSource.webView.frame = .init(x: 0, y:44 + top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44 - top)
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(sender:)))
                    self.view.addGestureRecognizer(tapGesture)
                }
               
            } else {
                // Fallback on earlier versions
                
                let top = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
                let navbar = UINavigationBar(frame: CGRect(x: 0, y: top, width: UIScreen.main.bounds.width, height: 44))
                navbar.backgroundColor = UIColor.white

                let navItem = UINavigationItem()
                navItem.title = self.url
                navItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(self.dismiss(sender:)))

                navbar.items = [navItem]

                self.view.addSubview(navbar)
                
                self.Activity = UIActivityIndicatorView()
                self.Activity.center = self.view.center
                self.Activity.startAnimating()
                self.Activity.hidesWhenStopped = true
                self.Activity.style = .gray
                self.viewSource.webView.addSubview(self.Activity)

                self.viewSource.webView.navigationDelegate = self

                viewSource.webView.frame = .init(x: 0, y: 44 + top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44 - top)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(sender:)))
                self.view.addGestureRecognizer(tapGesture)
            }
           
        }
        else
        {
            let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            navbar.backgroundColor = UIColor.white

            let navItem = UINavigationItem()
            navItem.title = self.url
            navItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(self.dismiss(sender:)))

            navbar.items = [navItem]

            self.view.addSubview(navbar)
            self.Activity = UIActivityIndicatorView()
            self.Activity.center = self.view.center
            self.Activity.startAnimating()
            self.Activity.hidesWhenStopped = true
            self.Activity.style = .gray
            self.viewSource.webView.addSubview(self.Activity)

            self.viewSource.webView.navigationDelegate = self

            viewSource.webView.frame = .init(x: 0, y:44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(sender:)))
            self.view.addGestureRecognizer(tapGesture)
        }
     
        
    
        
     
    }
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
     
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
           self.viewSource.webView.alpha = 0.0
            
        },completion: { (finished: Bool) in
            self.delegate?.closeInAppBrowser()
        })
        
     }
    
    @objc func dismiss(sender: UIButton) {
     
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
           self.viewSource.webView.alpha = 0.0
            
        },completion: { (finished: Bool) in
            self.delegate?.closeInAppBrowser()
        })
        
     }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Activity.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Activity.stopAnimating()
    }
}


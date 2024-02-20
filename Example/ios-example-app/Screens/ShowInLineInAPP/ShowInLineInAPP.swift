
import UIKit
import Dengage
import WebKit
import Dengage
class ShowInLineInAPP: UIViewController, WKUIDelegate, WKNavigationDelegate {


    private lazy var screenNameTextField1:UITextField = {
        let view = UITextField.init(frame: CGRect.init(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: 50))
        view.placeholder = "Property ID 1"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        return view
    }()
    
    private lazy var navigationButton1: UIButton = {
        let view = UIButton.init(frame: CGRect.init(x: 20, y: 158, width: UIScreen.main.bounds.width - 40, height: 50))
        view.setTitle("Show InLineInAPP 1", for: .normal)
        view.addTarget(self, action: #selector(didTapNavigationButton1), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
     
    var webView1: InAppInlineElementView = {
        let wv = InAppInlineElementView.init(frame: CGRect.init(x: 20, y: 216, width: UIScreen.main.bounds.width - 40, height: 100))
         wv.translatesAutoresizingMaskIntoConstraints = false
         wv.contentMode = .scaleAspectFit
         wv.sizeToFit()
         wv.autoresizesSubviews = true
         wv.backgroundColor = .green

         return wv
     }()
     
     private lazy var screenNameTextField2:UITextField = {
         let view = UITextField.init(frame: CGRect.init(x: 20, y: 340, width: UIScreen.main.bounds.width - 40, height: 50))
         view.placeholder = "Property ID 2"
         view.textAlignment = .center
         view.borderStyle = .roundedRect
         view.autocapitalizationType = .none
         return view
     }()
     
     private lazy var navigationButton2: UIButton = {
         let view = UIButton.init(frame: CGRect.init(x: 20, y: 398, width: UIScreen.main.bounds.width - 40, height: 50))
         view.setTitle("Show InLineInAPP 2", for: .normal)
         view.addTarget(self, action: #selector(didTapNavigationButton2), for: .touchUpInside)
         view.setTitleColor(.blue, for: .normal)
         return view
     }()
    
    var webView2: InAppInlineElementView = {
        let wv = InAppInlineElementView.init(frame: CGRect.init(x: 20, y: 456, width: UIScreen.main.bounds.width - 40, height: 100))
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.contentMode = .scaleAspectFit
        wv.sizeToFit()
        wv.autoresizesSubviews = true
        wv.backgroundColor = .yellow
        return wv
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       // Dengage.setInAppUIElement(vwController: self)
        
    }
     
     override func viewDidAppear(_ animated: Bool) {
         
         super.viewDidAppear(animated)
         
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         
         super.viewWillDisappear(animated)
         
     }
    
    private func setupUI(){
        title = "InLineInAPP"
        view.backgroundColor = .gray
        
        
       
        self.view.addSubview(screenNameTextField1)
        self.view.addSubview(navigationButton1)
        self.view.addSubview(webView1)
        
        self.view.addSubview(screenNameTextField2)
        self.view.addSubview(navigationButton2)
        self.view.addSubview(webView2)

        
    }
    
    @objc private func didTapNavigationButton1(){
        guard let text = screenNameTextField1.text else {return}
       
        
        view.endEditing(true)

        Dengage.setNavigation(screenName: "", propertyID: "1", webView: webView1)
    }
    
    @objc private func didTapNavigationButton2(){
        guard let text = screenNameTextField1.text else {return}
       
        
        view.endEditing(true)

        Dengage.setNavigation(screenName: "", propertyID: "2", webView: webView2)

    }
}





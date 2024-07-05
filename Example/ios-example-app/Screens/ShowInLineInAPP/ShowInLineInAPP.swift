
import UIKit
import Dengage
import WebKit
import Dengage
class ShowInLineInAPP: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    
    private lazy var screenNameTextField1:UITextField = {
        let view = UITextField.init(frame: CGRect.init(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: 50))
        view.placeholder = "Property ID"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        return view
    }()
    
    private lazy var screenNameTextField2:UITextField = {
        let view = UITextField.init(frame: CGRect.init(x: 20, y: 158, width: UIScreen.main.bounds.width - 40, height: 50))
        view.placeholder = "Enter Screen Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        return view
    }()
    
    var customVw1: UIView = {
        
        let customView = EventViewController.EventParameterItemView()
        customView.frame = CGRect.init(x: 20, y: 216, width: UIScreen.main.bounds.width - 40, height: 40)
         return customView
     }()
     
    var customVw2: UIView = {
        
        let customView = EventViewController.EventParameterItemView()
        customView.frame = CGRect.init(x: 20, y: 270, width: UIScreen.main.bounds.width - 40, height: 40)
         return customView
     }()
    
    private lazy var navigationButton1: UIButton = {
        let view = UIButton.init(frame: CGRect.init(x: 20, y: 320, width: UIScreen.main.bounds.width - 40, height: 50))
        view.backgroundColor = .white
        view.setTitle("Show InLineInAPP", for: .normal)
        view.addTarget(self, action: #selector(didTapNavigationButton1), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
     
    var webView1: InAppInlineElementView = {
        let wv = InAppInlineElementView.init(frame: CGRect.init(x: 20, y: 380, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 420))
         wv.translatesAutoresizingMaskIntoConstraints = false
         wv.contentMode = .scaleAspectFit
         wv.sizeToFit()
         wv.autoresizesSubviews = true
         wv.backgroundColor = .green

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
        
        self.view.addSubview(screenNameTextField2)
        self.view.addSubview(screenNameTextField1)
        self.view.addSubview(customVw1)
        self.view.addSubview(customVw2)
        self.view.addSubview(navigationButton1)
        self.view.addSubview(webView1)
        

        
    }
    
    @objc private func didTapNavigationButton1(){
        
        view.endEditing(true)

        
        guard let propertyid = screenNameTextField1.text else {return}
       
        guard let screenName = screenNameTextField2.text else {return}

     
        let parameters:Dictionary = self.view.subviews
            .compactMap{$0 as? EventViewController.EventParameterItemView}
            .compactMap{$0.values}
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        

        Dengage.showInAppInLine(propertyID: propertyid, inAppInlineElement: webView1, screenName: screenName, customParams: parameters, hideIfNotFound: true)

    }
   
}





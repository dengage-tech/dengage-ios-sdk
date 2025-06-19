//
//  File.swift
//  
//
//  Created by Priya Agarwal on 20/02/24.
//

import Foundation

import UIKit
import WebKit

open class InAppInlineElementView: WKWebView, WKScriptMessageHandler{
    

    var delegate: InAppMessagesActionsDelegate?

    var message:InAppMessage?

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        
        super.init(frame: frame, configuration: configuration)
        
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true 
        contentMode = .scaleAspectFit
        sizeToFit()
        autoresizesSubviews = true
        
        setUpUI()

    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func setUpUI()
    {
       
        let userScript = WKUserScript(source: javascriptInterface,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
       configuration.userContentController.addUserScript(userScript)
        
        if #available(iOS 14.0, *) {
            self.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            self.configuration.preferences.javaScriptEnabled = true
        }
        
        configuration.userContentController.add(self, name: "dismiss")
        configuration.userContentController.add(self, name: "close")
        configuration.userContentController.add(self, name: "closeN")
        configuration.userContentController.add(self, name: "iosUrl")
        configuration.userContentController.add(self, name: "iosUrlN")
        configuration.userContentController.add(self, name: "sendClick")
        configuration.userContentController.add(self, name: "promptPushPermission")
        configuration.userContentController.add(self, name: "setTags")
        loadHTMLString(message?.data.content.props.html ?? "", baseURL: nil)
        
        self.contentMode = .scaleAspectFit
        self.sizeToFit()
        self.autoresizesSubviews = true
                
       
        
        
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        run(message: message)
    }
    
    private func run(message: WKScriptMessage){
        
        switch message.name {
            
        case "sendClick":
            let buttonId = message.body as? String
            if let msg = self.message
            {
                self.delegate?.sendClickEvent(message: msg,
                                              buttonId: buttonId,
                                              buttonType: "")
            }
  
            
        case "iosUrl":
            
            guard let url = message.body as? String else {return}
            self.delegate?.open(url: url)
         
        case "setTags":
            guard let tagItemData = message.body as? [Dictionary<String,String>] else {return}
            let tagItems = tagItemData.map{TagItem.init(with: $0)}
            self.delegate?.setTags(tags: tagItems)
        default:
            break
        }
    }
}


extension InAppInlineElementView{
    
    fileprivate var javascriptInterface:String{
        return """
        var Dn =  {
            iosUrl: (url) => {
                window.webkit.messageHandlers.iosUrl.postMessage(url);
            },
            androidUrl: (url) => {},
            sendClick: (eventName) => {
                window.webkit.messageHandlers.sendClick.postMessage(eventName);
            },
            setTags: (tags) => {
                window.webkit.messageHandlers.setTags.postMessage(tags);
            }
        }
        """
    }
}

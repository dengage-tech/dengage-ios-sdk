//
//  File.swift
//  
//
//  Created by Priya Agarwal on 20/02/24.
//

import Foundation

import UIKit
import WebKit

public class InAppInlineElementView: WKWebView{
    

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        
        super.init(frame: frame, configuration: configuration)

        
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true 
        contentMode = .scaleAspectFit
        sizeToFit()
        autoresizesSubviews = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



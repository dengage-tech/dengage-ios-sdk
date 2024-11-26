//
//  SceneDelegate.swift
//  ios-example-app
//
//  Created by Priya Agarwal on 02/02/24.
//

import Foundation
import UIKit

@available(iOS 13.0, *)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // ...
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            let rootViewController = RootViewController()
            let navigationController = UINavigationController(rootViewController: rootViewController)
            window?.rootViewController = navigationController
            self.window!.makeKeyAndVisible()
            window?.overrideUserInterfaceStyle = .light

        }
        
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        // Handle the URL here
        print("URL received: \(url)")
    }
    
    
}

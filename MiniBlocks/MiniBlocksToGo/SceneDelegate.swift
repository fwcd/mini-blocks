//
//  SceneDelegate.swift
//  MiniBlocksToGo
//
//  Created by Fredrik on 10.01.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        
        // Set up window
        let window = UIWindow(windowScene: scene)
        window.rootViewController = MiniBlocksViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}

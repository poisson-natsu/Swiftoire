//
//  AppDelegate.swift
//  Swiftoire
//
//  Created by 付文华 on 2021/6/11.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        PTApplication.shared.presentInitialScreen()
        
        initToast()
        
        return true
    }
    
    private func initToast() {
        ToastManager.shared.position = .center
        ToastManager.shared.duration = 1.0
        ToastManager.shared.isTapToDismissEnabled = true
        var style = ToastStyle()
        style.backgroundColor = .themeBackground
        style.titleColor = .themeBlack
        style.messageColor = .themeBlack
        ToastManager.shared.style = style
    }


}


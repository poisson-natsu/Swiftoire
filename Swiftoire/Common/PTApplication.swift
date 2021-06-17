//
//  PTApplication.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import UIKit

final class PTApplication: NSObject {
    static let shared = PTApplication()
        
    private override init() {
        super.init()
        updateProvider()
    }
    
    func presentTabBarView(at index: Int) {
        guard let tabBarVC = window?.rootViewController as? PTTabBarController else {
            return
        }
        tabBarVC.selectedIndex = index
    }
    
    func presentLoginPage() {
        guard let provider = provider else {return}
        
        UserDefaults.standard.removeObject(forKey: TokenUserDefaultPath)
        let viewModel = LoginViewModel(provider: provider)
        let vc = LoginViewController(viewModel: viewModel)
        window?.rootViewController = PTNavigationController(rootViewController: vc)
    }
    
    func presentInitialScreen(msg: String? = nil) {
        guard let provider = provider else {return}
        
        if !PTUser.shared.token.isEmpty {
            let viewModel = TabBarViewModel(provider: provider)
            window?.rootViewController = PTTabBarController(viewModel: viewModel)
        }else {
            presentLoginPage()
        }
    }
    
    private func updateProvider() {
        let driverProvider = NetApi(defaultProvider: DriverNetworking.defaultNetworking())
        self.provider = driverProvider
    }
    
    var window: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    var provider: DriverService?
    
    // MARK: - 播放相关
    private var taskIdentifier: UIBackgroundTaskIdentifier?
    
//    func startVoc() {
//        let soundPath = Bundle.main.path(forResource: "sound", ofType: "wav")
//        var soundId: SystemSoundID = 0
//        if let soundPath = soundPath, let url = NSURL(string: soundPath) {
//            print("===========================has soundpath")
//            taskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
//
//            })
//            AudioServicesCreateSystemSoundID(url, &soundId)
//            AudioServicesPlaySystemSound(soundId)
//            UIApplication.shared.endBackgroundTask(taskIdentifier!)
//        }else {
//            print("===========================has no soundpath")
//        }
//        UIApplication.shared.endBackgroundTask(taskIdentifier!)
//    }
}

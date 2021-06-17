//
//  PTNavigationController.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import UIKit

class PTNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .white
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        // 去掉文字显示
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        super.pushViewController(viewController, animated: animated)
//        setNavigationBarHidden(false, animated: true)
    }

}

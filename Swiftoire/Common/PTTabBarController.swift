//
//  PTTabBarController.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import UIKit

enum TabBarItem: Int {
    case home, find, dispatch, me
    
    func controller(with viewModel: ViewModel) -> UIViewController {
        switch self {
        case .home: return HomeViewController(viewModel: viewModel)
        case .find: return HomeViewController(viewModel: viewModel)
        case .dispatch: return HomeViewController(viewModel: viewModel)
        case .me: return HomeViewController(viewModel: viewModel)
        }
    }
}

class PTTabBarController: UITabBarController {

    var viewModel: TabBarViewModel?
    
    init(viewModel: ViewModel?) {
        self.viewModel = viewModel as? TabBarViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .themeMain
        guard let viewModel = viewModel else {return}
        let output = viewModel.transform(input: TabBarViewModel.Input())
        output.tabBarItems.drive(onNext: {[weak self] (tabBarItems) in
            if let strongSelf = self {
                tabBarItems.forEach { (tabBarItem) in
                    switch tabBarItem {
                    case .home:
                        strongSelf.setChildViewController(tabBarItem.controller(with: viewModel.viewModel(for: tabBarItem)), title: "首页", imageName: "tabbar_home_normal", selectedImageName: "tabbar_home_selected")
                    case .find:
                        strongSelf.setChildViewController(tabBarItem.controller(with: viewModel.viewModel(for: tabBarItem)), title: "找货", imageName: "tabbar_find_normal", selectedImageName: "tabbar_find_selected")
                    case .dispatch:
                        strongSelf.setChildViewController(tabBarItem.controller(with: viewModel.viewModel(for: tabBarItem)), title: "配货", imageName: "tabbar_dispatch_normal", selectedImageName: "tabbar_dispatch_selected")
                    case .me:
                        strongSelf.setChildViewController(tabBarItem.controller(with: viewModel.viewModel(for: tabBarItem)), title: "我的", imageName: "tabbar_me_normal", selectedImageName: "tabbar_me_selected")
                    }
                }
                
            }
        }).disposed(by: rx.disposeBag)
    }
    
    private func setChildViewController(_ childVC: UIViewController, title: String, imageName: String, selectedImageName: String) {
        // 添加导航控制器为 TabBarController 的子控制器
        
        childVC.title = title
        childVC.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
//        childVC.tabBarItem.badgeValue = "99+"
        let navVC = PTNavigationController(rootViewController: childVC)
        
        addChild(navVC)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

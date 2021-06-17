//
//  TabBarViewModel.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation

class TabBarViewModel: ViewModel, ViewModelType {
    
    struct Input {}
    struct Output {
        let tabBarItems: RxCocoa.Driver<[TabBarItem]>
    }
    
    override init(provider: DriverService) {
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        
        let tabBarItems = Observable.just([TabBarItem.home, TabBarItem.find, TabBarItem.dispatch, TabBarItem.me]).asDriver(onErrorJustReturn: [])
        
        return Output(tabBarItems: tabBarItems)
    }
    // 从tabbarviewmodel获取每个tab的viewmodel，其实就是获取tabbarviewmodel中的provider
    func viewModel(for tabBarItem: TabBarItem) -> ViewModel {
        switch tabBarItem {
        case .home:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .find:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .dispatch:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .me:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        }
    }
}

//
//  HomeViewController.swift
//  PowerTransport
//
//  Created by ไปๆๅ on 2021/4/2.
//

import UIKit

class HomeViewController: RxViewController {
    
    override func bindViewModel() {
        super.bindViewModel()
//        guard let viewModel = viewModel as? HomeViewModel else {return}
//        let output = viewModel.transform(input: HomeViewModel.Input())
    }
    
    override func makeUI() {
        super.makeUI()
        
        // makeui here
        view.backgroundColor = .magenta
    }
    
}


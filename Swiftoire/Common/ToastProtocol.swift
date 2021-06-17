//
//  ToastProtocol.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation

protocol ToastProtocol {
    
    func showWaitingHUD()
    func hideWaitingHUD()
    
    func showHUD(_ msg: String?)
}

extension UIViewController: ToastProtocol {
    
    func showWaitingHUD() {
        self.view.makeToastActivity(.center)
    }
    
    func hideWaitingHUD() {
        self.view.hideToastActivity()
    }
    
    func showHUD(_ msg: String?) {
        self.view.showHUD(msg)
    }
    
    
}

extension UIView : ToastProtocol {
    
    
    func showWaitingHUD() {
        self.makeToastActivity(.center)
    }
    
    func hideWaitingHUD() {
        self.hideToastActivity()
    }
    
    func showHUD(_ msg: String?) {
        self.makeToast(msg)
    }
}

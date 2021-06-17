//
//  RegularTextField.swift
//  LogisticsCargoOwner
//
//  Created by 付文华 on 2020/7/31.
//  Copyright © 2020 qiluys. All rights reserved.
//  使用场景有局限(textfield需要用到其他代理方法时)

import UIKit

public class RegularTextField: UITextField {
    
    var textChanged: ((String) -> Void)?
    
    var regularLimitCb: (() -> String)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
}

extension RegularTextField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        print("range:\(range)")
        
        if let reg = regularLimitCb?() {
            let predicate = NSPredicate(format: "SELF MATCHES %@", reg)
            let currentText = NSString(string: textField.text ?? "")
            let result = currentText.replacingCharacters(in: range, with: string) as NSString
            
            let isValid = predicate.evaluate(with: (result as String))
            if isValid {
                textChanged?(result as String)
            }
            return isValid
        }else {
            textChanged?(textField.text ?? "")
        }
        
        return true
    }
    
}

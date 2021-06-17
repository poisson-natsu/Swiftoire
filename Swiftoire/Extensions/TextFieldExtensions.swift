//
//  TextFieldExtensions.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/5/12.
//

import UIKit

extension UITextField {
    
    func addLeftImage(_ image: UIImage?, with padding: CGFloat) {

        let imageView = UIImageView(image: image)
        imageView.contentMode = .left
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.addSubview(imageView)
        view.frame.size = CGSize(width: (image?.size.width ?? 0) + padding, height: image?.size.height ?? 0)
        leftView = view
        leftView?.frame.size = CGSize(width: (image?.size.width ?? 0) + padding, height: image?.size.height ?? 0)
        leftViewMode = .always
    }
}

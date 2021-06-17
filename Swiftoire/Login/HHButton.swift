//
//  HHButton.swift
//  PowerDelivery
//
//  Created by 付文华 on 2021/4/6.
//  解决用selected不能很好的设置图片问题

import UIKit

class HHButton: UIButton {

    var selectedImage: UIImage?
    var normalImage: UIImage?
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        if state == .selected {
            selectedImage = image
        }else {
            if state == .normal {
                if normalImage == nil {
                    normalImage = image
                }
            }
            super.setImage(image, for: state)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setImage(selectedImage, for: .normal)
            }else {
                setImage(normalImage, for: .normal)
            }
        }
    }
    
}

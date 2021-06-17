//
//  BundleLoad.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation

class BundleLoad {
    public static func loadImage(bundle: String, imageName: String, _ imageType: String = "png") -> UIImage? {
        
        if let path = Bundle(for: self).path(forResource: bundle, ofType: "bundle"),
            let bundle = Bundle.init(path: path),
            let imagePath = bundle.path(forResource: imageName, ofType: "png") {
       
            return UIImage.init(contentsOfFile: imagePath)
        }
        return nil
    }
}


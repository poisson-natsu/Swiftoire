//
//  PTUser.swift
//  Swiftoire
//
//  Created by ไปๆๅ on 2021/6/17.
//

import UIKit

class PTUser: HandyJSON {
    
    var token = ""
    var name = ""
    var phone = ""
    
    required init() {}
    
    static var shared = PTUser()

}

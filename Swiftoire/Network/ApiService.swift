//
//  ApiService.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

protocol DriverService {
    
    func login(userName: String, verCode: String) -> Single<PTUser>
    
    
}

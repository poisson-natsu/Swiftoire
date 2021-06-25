//
//  PTPreference.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation

private let ReleaseUrl = "http://www.baidu.com"
private let DebugUrl = "http://www.baidu.com"


#if DEBUG
let BaseURL = ReleaseUrl
#else
let BaseURL = ReleaseUrl
#endif

let imageUrl = "https://image.baidu.com/"

// 网络请求成功标识
let NetSuccessCode = 200

// ui

let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

// userdefault
let TokenUserDefaultPath = "TokenUserDefaultPath"
let PolicyUserDefaultPath = "PolicyUserDefaultPath"

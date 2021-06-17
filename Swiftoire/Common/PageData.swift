//
//  PageData.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation

protocol PageCompatible: HandyJSON {
    var noMoreData: Bool { get }
}


struct PageData<T>: PageCompatible where T: HandyJSON {
    
    
    /// 详细数据数组
    private var records: [[String: Any]] = []
    
    var items: [T] {
        get {
            return records.compactMap { T.deserialize(from: $0) }
        }
        set {
            records = newValue.compactMap { $0.toJSON() }
        }
    }
    
    /// 当前在第几页
    var current = 1
    
    /// 每页要请求的条数
    var size = 20
    
    /// 当前页第一个元素下标
    //var startRow = ""
    
    /// 当前页最后一个元素下标
    //var endRow = ""
    
    /// 所有数据需要完全展示所需的页数
    var pages = 0
    
    /// 所有数据总条数
    var total = 0
    
    ///是否无更多数据
    var noMoreData: Bool {
        if pages == 0 {
            // 为了在空数据时隐藏 “没有更多数据啦” footerView，此处返回false
            return false
        }
        return current >= pages
    }
}

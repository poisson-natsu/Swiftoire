//
//  NetApi.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import HandyJSON
import Moya


typealias MoyaError = Moya.MoyaError

enum ApiError: Error {
    case serverError(response: NetBody)
    
    var title: String {
        switch self {
        case .serverError(let response): return response.msg
        }
    }
    
    var description: String {
        switch self {
        case .serverError(let response): return response.msg
        }
    }
}

struct NetBody: HandyJSON {
    var msg = ""
    var flag = true
    var code = 0
    var data: Any?
}

class NetApi: DriverService {
    
    
    let defaultProvider: DriverNetworking
    
    init(defaultProvider: DriverNetworking) {
        self.defaultProvider = defaultProvider
    }

}

extension NetApi {
    
    func login(userName: String, verCode: String) -> Single<PTUser> {
        return requestObject(.login(userName: userName, passwd: verCode), type: PTUser.self)
    }
    
}

extension NetApi {
    private func request(_ target: DriverAPI) -> Single<Any> {
        return defaultProvider.request(target)
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    private func requestWithoutMapping(_ target: DriverAPI) -> Single<Moya.Response> {
        return defaultProvider.request(target)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    private func requestObject<T: HandyJSON>(_ target: DriverAPI, type: T.Type) -> Single<T> {
        return defaultProvider.request(target)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    private func requestArray<T: HandyJSON>(_ target: DriverAPI, type: T.Type) -> Single<[T]> {
        return defaultProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    
}









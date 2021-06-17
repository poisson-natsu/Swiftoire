//
//  Observable+Operators.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import RxSwift
import Moya
import HandyJSON

extension SharedSequenceConvertibleType {
    
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalType {
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            }else {
                return .empty()
            }
        }
    }
}

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}

extension Observable where Element: Moya.Response {
    
    func mapNoEmpty<T: Any>(_ type: T.Type) -> Observable<T> {
        return flatMap { (response) -> Observable<T> in
            guard let str = String(data: response.data, encoding: .utf8) as? T else {
                throw MoyaError.jsonMapping(response)
            }
            return .just(str)
        }
    }
    
    func mapObject<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { (response) -> Observable<T> in
            guard let result = try response.mapJSON() as? [String: Any] else {
                throw MoyaError.jsonMapping(response)
            }
            
            guard let netBody = NetBody.deserialize(from: result) else {
                throw MoyaError.jsonMapping(response)
            }
            
            guard netBody.code == 200 else {
                throw MoyaError.jsonMapping(response)
            }
            
            if netBody is T {
                return .just(netBody as! T)
            }
            
            guard let data = netBody.data as? [String: Any], let ret = T.deserialize(from: data) else {
                throw MoyaError.jsonMapping(response)
            }
            return .just(ret)
        }
    }
    
    func mapArray<T: HandyJSON>(_ type: T.Type) -> Observable<[T]> {
        return flatMap { (response) -> Observable<[T]> in
            
            guard let result = try response.mapJSON() as? [String: Any] else {
                throw MoyaError.jsonMapping(response)
            }
            
            guard let netBody = NetBody.deserialize(from: result) else {
                throw MoyaError.jsonMapping(response)
            }
            
            guard netBody.code == 200 else {
                throw MoyaError.jsonMapping(response)
            }
            
            if let data = netBody.data as? [String: Any], let pageData = PageData<T>.deserialize(from: data) {
//                let ls = pageData.items.compactMap { (dict) -> T? in
//                    return T.deserialize(from: dict)
//                }
                let ls = pageData.items
                return .just(ls)
            }else if let data = netBody.data as? [Any], let ls = [T].deserialize(from: data) {
                return .just(ls.compactMap {$0})
            }
            throw MoyaError.jsonMapping(response)
        }
    }
    
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> RxCocoa.Driver<Element> {
        return asDriver { error in
//            assertionFailure("-----------------Error \(error)")
            return RxCocoa.Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    static func errorResponse(_ msg: String?) -> RxSwift.Observable<Self.Element> {
        return error(MoyaError.stringMapping(Response(statusCode: -1, data: (msg ?? "").data(using: .utf8)!)))
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response  {
    
    func mapNoEmptyString() -> Single<String> {
        return flatMap { (e) -> Single<String> in
            if let resp = String(data: e.data, encoding: .utf8), !resp.isEmpty {
                return .just(resp)
            }
            throw MoyaError.stringMapping(e)
        }
    }
}

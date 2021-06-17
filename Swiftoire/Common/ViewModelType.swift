//
//  ViewModelType.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Input
    
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class ViewModel: NSObject {
    
    let provider: DriverService

    var page = 1
    
    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = FooterTracker()
    
    let error = ErrorTracker()
    let toast = ToastTracker()
    let serverError = PublishSubject<Error>()
    let parsedError = PublishSubject<ApiError>()

    init(provider: DriverService) {
        self.provider = provider
        super.init()
        
        serverError.asObservable().map { (error) -> ApiError? in
            do {
                let errorResponse = error as? MoyaError
                if let body = try errorResponse?.response?.mapJSON() as? [String: Any],
                   let errorResponse = NetBody.deserialize(from: body) {
                    return ApiError.serverError(response: errorResponse)
                }
                return nil
            } catch {
                print("serverError:-----------------------------\n\(error)")
                return nil
            }
        }.filterNil().bind(to: parsedError).disposed(by: rx.disposeBag)
        
        parsedError.subscribe(onNext: { (error) in
            print("------------------parseError:\(error)")
        }).disposed(by: rx.disposeBag)
    }
}

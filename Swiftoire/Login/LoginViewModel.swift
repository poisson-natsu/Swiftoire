//
//  LoginViewModel.swift
//  PowerDelivery
//
//  Created by 付文华 on 2021/4/6.
//

import UIKit

class LoginViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let loginTrigger: Driver<Void>
        let phoneTrigger: Driver<String>
        let passwdTrigger: Driver<String>
    }
    
    let negotiateChecked = BehaviorRelay(value: false)
    
    struct Output {
//        let loginEnabled: Driver<Bool>
        let userInfo: Driver<PTUser>
        let beginCount: Driver<Bool>
//        let testLogin: Driver<Bool>
    }
    
    private let phone = BehaviorRelay(value: "")
    private let passwd = BehaviorRelay(value: "")
    
    func transform(input: Input) -> Output {
        
        let userInfo = PublishSubject<PTUser>()
        let beginCount = BehaviorRelay<Bool>(value: false)
        
        input.phoneTrigger.skip(1).asObservable().bind(to: phone).disposed(by: rx.disposeBag)
        input.passwdTrigger.skip(1).asObservable().bind(to: passwd).disposed(by: rx.disposeBag)
        
        input.loginTrigger.asObservable().flatMapLatest { () -> Observable<Event<PTUser>> in
            if self.phone.value.count != 11 {
                return Observable.errorResponse("请输入手机号").trackError(self.error).materialize()
            }else if self.passwd.value.isEmpty {
                return Observable.errorResponse("请输入密码").trackError(self.error).materialize()
            }else if !self.negotiateChecked.value {
                return Observable.errorResponse("请同意服务协议").trackError(self.error).materialize()
            }
            else {
                return self.provider.login(userName: self.phone.value, verCode: self.passwd.value).trackError(self.error).trackActivity(self.loading).materialize()
            }
        }.subscribe(onNext: {event in
            if case let .next(user) = event {
                PTUser.shared = user
//                UserDefaults.standard.setValue(user.token, forKey: TokenUserDefaultPath)
                userInfo.onNext(user)
            }
        }).disposed(by: rx.disposeBag)
        
        return Output(userInfo: userInfo.asDriverOnErrorJustComplete(), beginCount: beginCount.asDriver())
    }

}

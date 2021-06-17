//
//  ErrorTracker.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation

final class ErrorTracker: SharedSequenceConvertibleType {
    
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<Error>()
    
    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do(onError: onError)
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }
    
    func asObservable() -> Observable<Error> {
        return _subject.asObserver()
    }
    
    private func onError(_ error: Error) {
        _subject.onNext(error)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    func trackError(_ errorTracker: ErrorTracker) -> Observable<Element> {
        return errorTracker.trackError(from: self)
    }
}

public class FooterTracker: SharedSequenceConvertibleType {
    
    public typealias Element = MJRefreshState
    public typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<MJRefreshState>()
    
    func trackState<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do { (element) in
            if let ele = element as? PageCompatible {
                self._subject.onNext(ele.noMoreData ? .noMoreData : .idle)
            }
        }
    }
    
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, MJRefreshState> {
        return _subject.asObservable().asDriver(onErrorJustReturn: .idle)
    }
    
    public func asObservable() -> Observable<MJRefreshState> {
        return _subject.asObserver()
    }
    
    private func onState(_ state: MJRefreshState) {
        _subject.onNext(state)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: FooterTracker) -> Observable<Element> {
        return activityIndicator.trackState(from: self)
    }
}

public class ToastTracker: SharedSequenceConvertibleType {
    
    public typealias Element = String
    public typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<String>()
    
    func trackState<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do { (element) in
            if let ele = element as? NetBody, ele.code == 200 {
                self._subject.onNext(ele.msg)
            }
        }
    }
    
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, String> {
        return _subject.asObservable().asDriver(onErrorJustReturn: "操作成功")
    }
    
    public func asObservable() -> Observable<String> {
        return _subject.asObserver()
    }
    
    private func onState(_ message: String) {
        _subject.onNext(message)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    public func trackToast(_ activityIndicator: ToastTracker) -> Observable<Element> {
        return activityIndicator.trackState(from: self)
    }
}

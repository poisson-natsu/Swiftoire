//
//  ActivityIndicator.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

private struct ActivityToken<Element> : ObservableConvertibleType, Disposable {
    private let _source: Observable<Element>
    private let _dispose: Cancelable
    
    init(source: Observable<Element>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }
    
    func dispose() {
        _dispose.dispose()
    }
    
    func asObservable() -> Observable<Element> {
        return _source
    }
}

/**
 Enables monitoring of sequence computation.
 
 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
public class ActivityIndicator: SharedSequenceConvertibleType {
    
    
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let lock = NSRecursiveLock()
    private let subject = PublishSubject<Int>()
    private var value = 0
    private let activity: SharedSequence<SharingStrategy, Bool>
    
    public init() {
        activity = subject.asDriver(onErrorJustReturn: 0)
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return Observable.using({ () -> ActivityToken<O.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { activity in
            return activity.asObservable()
        }
    }
    
    private func increment() {
        lock.lock()
        value += 1
        subject.onNext(value)
        lock.unlock()
    }
    
    private func decrement() {
        lock.lock()
        value -= 1
        subject.onNext(value)
        lock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return activity
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
    public func trackHasMoreActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
    public func trackActivity(_ activityIndicators: ActivityIndicator...) -> Observable<Element> {
        return activityIndicators.reduce(self.asObservable(), {$1.trackActivityOfObservable($0)})
    }
}

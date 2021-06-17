//
//  MJRefresh+Rx.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    public var isAnimating: Binder<Bool> {
        return Binder(self.base) { scrollView, active in
            if active {}
            else {
                scrollView.mj_header?.endRefreshing()
                scrollView.mj_footer?.endRefreshing()
            }
        }
    }
    
//    public var noMoreData: Binder<Bool> {
//        return Binder(self.base) { scrollView, hasMore in
//            if hasMore {
//                scrollView.mj_footer?.endRefreshing()
//            }else {
//                scrollView.mj_footer?.endRefreshingWithNoMoreData()
//            }
//        }
//    }
    
    public var refresh: Binder<MJRefreshState> {
        return Binder(self.base) { scrollView, state in
            switch state {
            case .idle:
                scrollView.mj_footer?.endRefreshing()
                break
            case .refreshing:
                break
            case .noMoreData:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.05) {
                    scrollView.mj_footer?.endRefreshingWithNoMoreData()
                }
                break
            case .pulling:
                break
            case .willRefresh:
                break
            default: break
            }
        }
    }
}

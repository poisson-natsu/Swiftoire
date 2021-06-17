//
//  Networking.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import Moya
import RxSwift
import Alamofire

class OnlineProvider<Target> where Target: Moya.TargetType {
    fileprivate let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>
    
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.neverStub,
        callbackQueue: DispatchQueue? = nil,
        session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
        plugins: [PluginType] = [],
        trackInflights: Bool = false,
        online: Observable<Bool> = connectedToInternet()) {
        self.online = online
        self.provider = MoyaProvider(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    func request(_ token: Target) -> Observable<Moya.Response> {
        let actualRequest = provider.rx.request(token)
        return online
            .ignore(value: false) // wait until we're online
            .take(1)
            .flatMap { _ in
                return actualRequest
                    .filterSuccessfulStatusCodes()
                    .do(onSuccess: {(response) in
                    }, onError: {(error) in
                        print("------------------------here is an error")
                        if let error = error as? MoyaError {
                            switch error {
                            case .statusCode(let response):
                                print("========------------=================statusCode:\(response.statusCode)")
                                guard let errorDict = try? response.mapJSON() as? [String: Any] else {
                                    print("--------------------no way to take response to dict")
                                    break
                                }
                                print("------------------errorDict: \(errorDict)")
                                if response.statusCode == 500, let message = errorDict["message"] as? String, message.contains("Token") {
                                    // 回到登录页面
                                    PTApplication.shared.presentLoginPage()
                                }
                            case .underlying(let error, _):
                                print("------------error:\(error.localizedDescription)")
                            default:
                                print("""
                                    ----------------------------error---------------------\n
                                    \(error)
                                    ----------------------------end error---------------------
                                    """)
                            }
                        }
                    })
            }
    }
}

protocol NetworkingType {
    associatedtype T: TargetType
    var provider: OnlineProvider<T> {get}
    
    static func defaultNetworking() -> Self
    static func stubbingNetworking() -> Self
}

struct DriverNetworking: NetworkingType {
    typealias T = DriverAPI
    let provider: OnlineProvider<T>
    
    static func defaultNetworking() -> Self {
        return DriverNetworking(provider: newProvider(plugins))
    }
    static func stubbingNetworking() -> DriverNetworking {
        return DriverNetworking(provider: OnlineProvider(endpointClosure: endpointsClosure(), requestClosure: DriverNetworking.endpointResolver(), stubClosure: MoyaProvider.immediatelyStub, callbackQueue: nil, session: MoyaProvider<T>.defaultAlamofireSession(), plugins: [], trackInflights: false, online: .just(true)))
    }
    
    func request(_ token: T) -> Observable<Moya.Response> {
        let actualRequest = self.provider.request(token)
        return actualRequest
    }
}

extension NetworkingType {
    
    static func endpointsClosure<T>() -> (T) -> Endpoint where T: TargetType {
        return { target in
            let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
            return endpoint.adding(newHTTPHeaderFields: ["token": PTUser.shared.token])
        }
    }

    static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
        // TODO: - 有服务器数据时要设为.never
//        return .never
        return .delayed(seconds: 2)
    }

    static var plugins: [PluginType] {
        var plugins: [PluginType] = []
//        if Configs.Network.loggingEnabled == true {
//            plugins.append(NetworkLoggerPlugin())
//        }
        plugins.append(SLPrintParameterAndJson())
        plugins.append(SingleShowState())
        return plugins
    }

    // (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
//                request.timeoutInterval = 5
                request.httpShouldHandleCookies = false
                closure(.success(request))
            } catch {
//                logError(error.localizedDescription)
                print("--------error:"+error.localizedDescription)
            }
        }
    }
}

private func newProvider<T>(_ plugins: [PluginType]) -> OnlineProvider<T> {
    return OnlineProvider(endpointClosure: DriverNetworking.endpointsClosure(), requestClosure: DriverNetworking.endpointResolver(), stubClosure: DriverNetworking.APIKeysBasedStubBehaviour, callbackQueue: nil, session: MoyaProvider<T>.defaultAlamofireSession(), plugins: plugins, trackInflights: false)
}


private func connectedToInternet() -> Observable<Bool> {
    return ReachabilityManager.shared.reach
}

private class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return reachSubject.asObservable()
    }
    
    override init() {
        super.init()
        
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { (status) in
            print("---------network status changed:\(status)")
            switch status {
            case .notReachable:
                self.reachSubject.onNext(false)
            case .reachable:
                self.reachSubject.onNext(true)
            case .unknown:
                self.reachSubject.onNext(false)
            }
        })
    }
}

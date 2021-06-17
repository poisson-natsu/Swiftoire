//
//  MoyaPlugin.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import UIKit
import Moya

internal final class SingleShowState: PluginType {
    
    /// 在发送之前调用来修改请求
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        var request = request
//        guard let target = target as? APIService else {
//            return request
//        }
//        switch target {
//        case .simple:
//            request.timeoutInterval = 15
//        default:
//            request.timeoutInterval = 30
//        }
        return request
    }
    
    /// 在通过网络发送请求（或存根）之前立即调用
    func willSend(_ request: RequestType, target: TargetType) {
//        guard let target = target as? DriverAPI else { return }
        /// 判断是否需要显示：网络请求之前，显示进度条或者菊花图
//        if target.showStats {
//            DispatchQueue.main.async {
//                if let keyWindow = UIApplication.shared.keyWindow {
//                    MBProgressHUD.showAdded(to: keyWindow, animated: true)
//                }
//            }
//        }
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        /// 移除进度条或者菊花图
//        guard let target = target as? APIService else { return }
//        if target.showStats {
//            DispatchQueue.main.async {
//                if let keyWindow = UIApplication.shared.keyWindow {
//                    MBProgressHUD.hide(for: keyWindow, animated: true)
//                }
//            }
//        }
    }
    
    /// 调用以在完成之前修改结果
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        guard let target = target as? DriverAPI else {
//            return result
//        }
//        if case .listBanner = target {
//            return .success(Response(statusCode: 200, data: "\"msg\":\"success\", \"code\":0, \"data\":\\[\\]".data(using: .utf8)!))
//        }else {
//            return result
//        }
        return result
    }
}

/// Moya插件：控制台打印请求参数和服务器返回的json数据
internal final class SLPrintParameterAndJson: PluginType {
    
    /// 发送请求
    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        if let httpBody = request.request?.httpBody {
            print("""
                >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                请求参数=======> \(target.path)
                \(String(data: httpBody, encoding: .utf8)?.removingPercentEncoding ?? "just null")

                """)
        }else {
            print("""
                >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                请求参数=======> \(target.path) null found
                token: \(request.request?.headers.value(for: "token") ?? "")
                """)
        }
        #endif
    }
    
    /// 接受数据
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            do {
                let jsonObject = try response.mapJSON()
                print("""
                    请求成功=====> \(target.path)
                    \(jsonObject)
                    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    """)
            } catch {
                print("""
                    请求成功=====> \(target.path) \(String(data: response.data, encoding: .utf8) ?? "")
                    无返回参数
                    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    """)
            }
            break
        case .failure(let error):
            print("""
            请求失败=====> \(target.path) \(error)
            <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            """)
            break
        }
        #endif
    }
}

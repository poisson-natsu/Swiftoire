//
//  API.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import Foundation
import Moya


private let assetDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

enum DriverAPI {
    
    case download(url: URL, fileName: String?)
    case login(userName: String, passwd: String)
}

extension DriverAPI: TargetType {
    
    public var baseURL: URL {
        return URL(string: BaseURL)!
    }
    
    public var path: String {
        switch self {
        case .download: return ""
        case .login: return "/app/user/login"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .download:
            return .get
        default:
            return .post
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .login:
            return "{\"code\":200,\"msg\":\"老弟，成功啦\",\"data\":{\"token\":\"123456789\",\"name\":\"xiaoming\",\"phone\":\"15555555555\"}}".data(using: .utf8)!
        default:
            return "test data".data(using: .utf8)!
        }
    }
    
    public var task: Task {
        switch self {
        case .download:
            return .downloadDestination(downloadDestination)
//        case .uploadImage(let imageData, let fileName):
//            let formData = MultipartFormData(provider: .data(imageData), name: "files", fileName: fileName, mimeType: "image/jpeg")
//            return .uploadMultipart([formData])
        default:
            if parameters.isEmpty {
                return .requestPlain
            }
            if let params = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
                return.requestData(params)
            }else {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
        }
    }
    
    public var headers: [String : String]? {
        switch self {
//        case .systemMapInfo():
//            return ["Content-Type":"application/x-www-form-urlencoded"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    //****************************自定义方法****************
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, .removePreviousFile) }
    }
    var localLocation: URL {
        switch self {
        case .download(_, let fileName):
            if let fileName = fileName {
                return assetDir.appendingPathComponent(fileName)
            }
        default: break
        }
        return assetDir
    }
    
    /// 参数
    public var parameters: [String: Any] {
        var params: [String: Any] = [:]
        switch self {
        case .login(let userName, let passwd):
            params["userName"] = userName
            params["passwd"] = passwd
        default:
            return params
        }
        //token add
        
        return params
    }
    /// 参数编码
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
}

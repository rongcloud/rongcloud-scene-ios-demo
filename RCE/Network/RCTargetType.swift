//
//  RCTargetType.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/1.
//

import Moya

/// 探究中，未实现

class RCTargetType: TargetType {
    var baseURL: URL {
        return Environment.current.url
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var headers: [String : String]? {
        return ["Authorization": UserDefaults.standard.authorizationKey() ?? ""]
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var validationType: ValidationType {
        return .none
    }
}

#if DEBUG
/// 如果不希望在Console中打印网络请求相关的log可以在把logPlugin移除。
private let logPlugin: NetworkLoggerPlugin = {
    let plgn = NetworkLoggerPlugin()
    plgn.configuration.logOptions = .verbose
    return plgn
}()
let networkPlugins: [PluginType] = [logPlugin]
#else
let networkPlugins: [PluginType] = []
#endif

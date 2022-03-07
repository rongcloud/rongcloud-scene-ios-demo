//
//  RCServiceType.swift
//  RCE
//
//  Created by xuefeng on 2022/1/28.
//

import Moya
import Foundation
import RCSceneFoundation

let RCServicePlugin: NetworkLoggerPlugin = {
    let plgn = NetworkLoggerPlugin()
    plgn.configuration.logOptions = .verbose
    return plgn
}()

protocol RCServiceType: TargetType {}

extension RCServiceType {
    
    public var baseURL: URL {
        return Environment.current.url
    }
    
    public var headers: [String : String]? {
        var header = [String: String]()
        if let auth = UserDefaults.standard.authorizationKey() {
            header["Authorization"] = auth
        }
        header["BusinessToken"] = Environment.businessToken
        return header
    }
    
    public var sampleData: Data {
        return Data()
    }
}

public typealias RCSceneServiceCompletion = Moya.Completion

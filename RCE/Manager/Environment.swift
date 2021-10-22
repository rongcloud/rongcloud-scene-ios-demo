//
//  AppEnvironment.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation

var isAppStoreAccount: Bool = false

enum Environment {
    case debug
    case production
    case release
}

extension Environment {
    var url: URL {
        switch self {
        case .debug:
            return URL(string: "您的测试服务器地址")!
        default:
            return URL(string: "您的正式服务器地址")!
        }
    }
    
    static var current: Environment {
        #if DEBUG
        return .debug
        #elseif PRODUCTION
        return .production
        #elseif RELEASE
        return .release
        #endif
    }
    
    static var currentUserId: String {
        return UserDefaults.standard.loginUser()?.userId ?? ""
    }
    
    var rcKey: String {
        switch self {
        case .debug:
            return "测试环境appKey"
        default:
            return "正式环境appKey"
        }
    }
    
    var umengKey: String {
        return "友盟key"
    }
    
    var buglyKey: String {
        return "bugly key"
    }
    
    static var currentUser: User? {
        return UserDefaults.standard.loginUser()
    }
}

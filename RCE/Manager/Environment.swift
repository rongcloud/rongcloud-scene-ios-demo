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
    case overseas
}


extension Environment {
    var url: URL {
        switch self {
        case .debug:
            return URL(string: "开发环境地址")!
        case .overseas:
            return URL(string: "海外环境地址")!
        default:
            return URL(string: "正式环境地址")!
        }
    }
    
    static var current: Environment {
        #if DEBUG
        return .debug
        #elseif PRODUCTION
        return .production
        #elseif RELEASE
        return .release
        #elseif OVERSEA
        return .overseas
        #endif
    }
    
    static var currentUserId: String {
        return UserDefaults.standard.loginUser()?.userId ?? ""
    }
    
    var rcKey: String {
        switch self {
        case .debug:
            return "开发环境 key"
        case .overseas:
            return "海外环境 key"
        default:
            return "正式环境 key"
        }
    }
    
    var umengKey: String {
        return "友盟 key"
    }
    
    var buglyKey: String {
        return "bugly key"
    }
    
    static var MHBeautyKey: String {
        let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        switch bundleID {
        default: return "美狐美颜 key"
        }
    }
    
    static var currentUser: User? {
        return UserDefaults.standard.loginUser()
    }
    
    /// 请申请您的 BusinessToken：https://rcrtc-api.rongcloud.net/code
    static var businessToken: String {
        return ""
    }
}

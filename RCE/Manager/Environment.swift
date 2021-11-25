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
            return URL(string: "https://rcrtc-api.rongcloud.net/")!
        default:
            return URL(string: "")!
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
            return "pvxdm17jpw7ar"
        default:
            return ""
        }
    }
    
    var umengKey: String {
        return ""
    }
    
    var buglyKey: String {
        return ""
    }
    
    static var MHBeautyKey: String {
        let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        switch bundleID {
        case "cn.rongcloud.rcrtc": return "29531f6d8b934a6e65ab7d86cad79fe9"
        case "cn.rongcloud.rcrtc.appstore": return ""
        default: return ""
        }
    }
    
    static var currentUser: User? {
        return UserDefaults.standard.loginUser()
    }
    
    static var businessToken: String {
        // 请通过https://rcrtc-api.rongcloud.net/from 申请获取
        return ""
    }
}

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
        return URL(string: "https://rcrtc-api.rongcloud.net/")!
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
    
    /// 融云 APP Key
    var rcKey: String {
        return "pvxdm17jpw7ar"
    }
    
    /// 友盟 Key
    var umengKey: String {
        return ""
    }
    
    /// crash 收集
    var buglyKey: String {
        return ""
    }
    
    /// 如果需要美颜，请再次配置 Key
    static var MHBeautyKey: String {
        return ""
    }
    
    static var currentUser: User? {
        return UserDefaults.standard.loginUser()
    }
    
    /// 请申请您的 BusinessToken：https://rcrtc-api.rongcloud.net/code
    static var businessToken: String {
        return ""
    }
}

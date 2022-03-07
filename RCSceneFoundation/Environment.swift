//
//  AppEnvironment.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation

public var isAppStoreAccount: Bool = false

public enum Environment {
    case debug
    case production
    case release
    case overseas
}


public extension Environment {
    var url: URL {
        // 您可以搭建自己的服务器，替换该地址
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
    
    /// 请申请您的 BusinessToken：https://rcrtc-api.rongcloud.net/code
    static var businessToken: String {
        return ""
    }
}

//
//  AppEnvironment.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation

enum Environment {
    case debug
    case production
    case release
}

extension Environment {
    var url: URL {
        switch self {
        case .debug:
            return URL(string: "")!
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
            return ""
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
    
    static var currentUser: User? {
        return UserDefaults.standard.loginUser()
    }
}

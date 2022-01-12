//
//  SettingItem.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import Foundation

enum SettingItem: CaseIterable {
    case registerTerm
    case privacyTerm
    case logoff
    case logout
}

extension SettingItem {
    var title: String {
        switch self {
        case .registerTerm:
            return "注册条款"
        case .privacyTerm:
            return "隐私政策"
        case .logoff:
            return "账号注销"
        case .logout:
            return "退出登录"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .registerTerm:
            return R.image.register_term()
        case .privacyTerm:
            return R.image.privacy_icon()
        case .logoff:
            return R.image.logoff_icon()
        case .logout:
            return R.image.logout_icon()
        }
    }
}

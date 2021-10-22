//
//  UMengEvent.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/22.
//

import Foundation

enum UMengEvent: String {
    case AppraisalBanner
    case SettingBanner
    case SettingPackage
    case SettingCallCM
    case SettingAboutUs
    case SettingCS
    case SettingDemoDownload
    case VoiceRoom
    case RadioRoom
    case VideoCall
    case AudioCall
    case LiveVideo
}

extension UMengEvent {
    var name: String {
        switch Environment.current {
        case .debug:
            switch self {
            case .AppraisalBanner: return "TestEvent001"
            case .SettingBanner: return "TestEvent002"
            default: return ""
            }
        default: return rawValue
        }
    }
    
    func trigger() {
        MobClick.event(name, attributes: ["userid": Environment.currentUserId])
    }
}

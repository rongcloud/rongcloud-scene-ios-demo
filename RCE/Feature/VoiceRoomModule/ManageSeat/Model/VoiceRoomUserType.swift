//
//  VoiceRoomUserType.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/10.
//

import Foundation

enum VoiceRoomUserType {
    case creator
    case manager
    case audience
    
    func toggler() -> VoiceRoomUserType {
        switch self {
        case .creator:
            return .creator
        case .audience:
            return .manager
        case .manager:
            return .audience
        }
    }
}

//
//  PKStateMachine.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/6.
//

import Foundation

enum PKCountdownState {
    case pkOngoing
    case punishOngoing
}

enum PKResult {
    case win
    case lose
    case tie
    
    var desc: String {
        switch self {
        case .win:
            return "我方 PK 胜利"
        case .lose:
            return "我方 PK 失败"
        default:
            return "平局"
        }
    }
}



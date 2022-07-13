//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation
import RCSceneRoom

extension RCScene {
    var umengEvent: UMengEvent {
        switch self {
        case .audioRoom: return .VoiceRoom
        case .radioRoom: return .RadioRoom
        case .audioCall: return .AudioCall
        case .videoCall: return .VideoCall
        case .liveVideo: return .LiveVideo
        case .gameRoom:  return .GameRoom
        default: return .LiveVideo
        }
    }
    
    func sensorTrigger() {
        let name: String = {
            switch self {
            case .audioRoom: return "语聊房"
            case .radioRoom: return "语音电台"
            case .audioCall: return "音频通话"
            case .videoCall: return "视频通话"
            case .liveVideo: return "视频直播"
            case .gameRoom:  return  "游戏房"
            default: return "视频直播"
            }
        }()
        RCSensorAction.functionModuleView(name).trigger()
    }
}

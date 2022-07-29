//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import RCSceneRoom

enum RCRoomType: Int, CaseIterable {
    case audioRoom  = 1
    case audioCall  = 11
    case videoCall  = 10
    case liveVideo  = 3
    case radioRoom  = 2
    case gameRoom   = 4
    case community  = 20
    case musicKTV   = 30
    case privateCall = 40
}

extension RCRoomType {
    var name: String {
        switch self {
        case .audioRoom:
            return "语聊房"
        case .radioRoom:
            return "语音电台"
        case .videoCall:
            return "视频通话"
        case .audioCall:
            return "语音通话"
        case .liveVideo:
            return "视频直播"
        case .gameRoom:
            return "游戏房"
        case .musicKTV:
            return "Coming Soon"
        default: return ""
        }
    }
    
    var desc: String {
        switch self {
        case .audioRoom:
            return  "支持连麦、PK"  //"超大聊天室，支持麦位、麦序\n管理，涵盖KTV等多种玩法"
        case .radioRoom:
            return  "单主播语音推流" //"听众端采用CDN链路 支持人数无上限"
        case .videoCall:
            return "低延迟、高清晰" //"低延迟、高清晰度视频通话"
        case .audioCall:
            return "低延迟、智能降噪" //"拥有智能降噪的无差别 电话体验"
        case .liveVideo:
            return  "多种布局，支持美颜、PK" //"视频直播间，支持高级美颜、观众连麦互动"
        case .gameRoom:
            return "多种游戏 | 快速匹配"  //"多种游戏，快速匹配"
        case .musicKTV:
            return "新功能正在打磨中..."
        default: return ""
        }
    }
}

extension RCRoomType {
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

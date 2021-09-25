//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation

enum HomeItem: Int, CaseIterable {
    case audioRoom = 1
    case videoCall = 2
    case audioCall = 3
    case radioRoom = 4
}

extension HomeItem {
    var name: String {
        switch self {
        case .audioRoom:
            return "语聊房"
        case .radioRoom:
            return "电台"
        case .videoCall:
            return "视频聊天"
        case .audioCall:
            return "语音聊天"
        }
    }
    
    var desc: String {
        switch self {
        case .audioRoom:
            return "超大聊天室，支持麦位、麦序\n管理，涵盖KTV等多种玩法"
        case .radioRoom:
            return "听众端采用CDN链路 支持人数无上限"
        case .videoCall:
            return "低延迟、高清晰度视频通话"
        case .audioCall:
            return "拥有智能降噪的无差别 电话体验"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .audioRoom:
            return R.image.voice_room_background()
        case .videoCall:
            return R.image.video_live_room_background()
        case .audioCall:
            return R.image.voice_call_room_background()
        case .radioRoom:
            return R.image.home_radio_room()
        }
    }
    
    var enabled: Bool {
        return true
    }
}

extension HomeItem {
    var umengEvent: UMengEvent {
        switch self {
        case .audioRoom: return .VoiceRoom
        case .radioRoom: return .RadioRoom
        case .audioCall: return .AudioCall
        case .videoCall: return .VideoCall
        }
    }
}

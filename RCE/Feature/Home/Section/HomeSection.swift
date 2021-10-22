//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation

public enum HomeItem: Int, CaseIterable {
    case audioRoom = 1
    case videoCall = 10
    case audioCall = 11
    case radioRoom = 2
    case liveVideo = 3
}

public extension HomeItem {
    var name: String {
        switch self {
        case .audioRoom:
            return "语聊房"
        case .radioRoom:
            return "电台"
        case .videoCall:
            return "视频通话"
        case .audioCall:
            return "语音通话"
        case .liveVideo:
            return "视频直播"
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
        case .liveVideo:
            return "低延迟、高清晰度视频通话"
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
        case .liveVideo:
            return R.image.live_video_home_bg()
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
        case .liveVideo: return .LiveVideo
        }
    }
}

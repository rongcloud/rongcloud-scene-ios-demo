//
//  VoiceRoomManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import RCSceneService

public enum PKStatus: Int {
    case begin = 0
    case pause
    case close
    
    public var name: String {
        switch self {
        case .begin:
            return "开始"
        case .pause:
            return "暂停"
        case .close:
            return "结束"
        }
    }
}

public enum HomeItem: Int, CaseIterable {
    case audioRoom = 1
    case audioCall = 11
    case videoCall = 10
    case liveVideo = 3
    case radioRoom = 2
    
    public var name: String {
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
        }
    }
    
    public var desc: String {
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
            return "视频直播间，支持高级美颜、观众连麦互动"
        }
    }
}

public class SceneRoomManager {
    public static let shared = SceneRoomManager()
    
    public let queue = DispatchQueue(label: "voice_room_join_or_leave")
    
    /// 当前场景类型，进入room时，用room.roomType
    public static var scene = HomeItem.audioRoom
    /// 当前所在房间
    public var currentRoom: VoiceRoom?
    /// 管理员
    public var managers = [String]()
    /// 房间背景
    public var backgroundlist = [String]()
    /// 屏蔽词
    public var forbiddenWordlist = [String]()
    /// 麦位信息
    public var seatlist = [String]()
    
    public func clear() {
        seatlist.removeAll()
        managers.removeAll()
        backgroundlist.removeAll()
        forbiddenWordlist.removeAll()
    }
}

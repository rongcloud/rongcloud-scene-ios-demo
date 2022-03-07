//
//  VoiceRoom.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/27.
//

import UIKit
import RCSceneFoundation

public var kSceneServiceCurrentRoomId = ""

public struct VoiceRoomListWrapper: Codable {
    let code: Int
    public let data: VoiceRoomList?
}

public struct VoiceRoomList: Codable {
    public let totalCount: Int
    public let rooms: [VoiceRoom]
    public let images: [String]
}

public struct CreateVoiceRoomWrapper: Codable {
    let code: Int
    public let msg: String?
    public let data: VoiceRoom?
    
    public func isCreated() -> Bool {
        return code == 30016
    }
    
    public func needLogin() -> Bool {
        return code == 30017
    }
}

public struct VoiceRoom: Codable, Identifiable, Equatable {
    public let id: Int
    public let roomId: String
    public var roomName: String
    public var themePictureUrl: String
    public var backgroundUrl: String?
    public var isPrivate: Int
    public var password: String?
    public let userId: String
    let updateDt: TimeInterval
    public let createUser: VoiceRoomUser?
    public var userTotal: Int
    public let roomType: Int?  /// (1 || null):语聊房,2:电台,3:直播
    public let stop: Bool
    public var notice: String?
}

public extension VoiceRoom {
    var accessible: Bool {
        return isPrivate == 0 ||
            userId == Environment.currentUserId ||
            roomId == kSceneServiceCurrentRoomId
    }
    
    var switchable: Bool {
        return isPrivate == 0 && userId != Environment.currentUserId
    }
    
    var isOwner: Bool {
        return userId == Environment.currentUserId
    }
}

public enum SceneRoomUserType {
    case creator
    case manager
    case audience
}

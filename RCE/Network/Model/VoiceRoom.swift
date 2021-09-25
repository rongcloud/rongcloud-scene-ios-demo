//
//  VoiceRoom.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/27.
//

import Foundation

struct VoiceRoomListWrapper: Codable {
    let code: Int
    let data: VoiceRoomList?
}

struct VoiceRoomList: Codable {
    let totalCount: Int
    let rooms: [VoiceRoom]
    let images: [String]
}

struct CreateVoiceRoomWrapper: Codable {
    let code: Int
    let data: VoiceRoom?
    
    func isCreated() -> Bool {
        return code == 30016
    }
    
    func needLogin() -> Bool {
        return code == 30017
    }
}

struct VoiceRoom: Codable, Identifiable, Equatable {
    let id: Int
    let roomId: String
    var roomName: String
    var themePictureUrl: String
    var backgroundUrl: String?
    var isPrivate: Int
    var password: String?
    let userId: String
    let updateDt: TimeInterval
    let createUser: VoiceRoomUser?
    var userTotal: Int
    let roomType: Int?
    let stop: Bool
}

extension VoiceRoom {
    func defaultAvatarImage() -> UIImage? {
        return R.image.room_background_image1()
    }
}

extension VoiceRoom {
    var accessible: Bool {
        return isPrivate == 0 ||
            userId == Environment.currentUserId ||
            roomId == RCRoomFloatingManager.shared.currentRoomId
    }
    
    var switchable: Bool {
        return isPrivate == 0 && userId != Environment.currentUserId
    }
    
    var isOwner: Bool {
        return userId == Environment.currentUserId
    }
}

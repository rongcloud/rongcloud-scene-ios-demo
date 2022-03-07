//
//  SceneRoomUserOperation.swift
//  RCSceneModular
//
//  Created by shaoshuai on 2022/2/26.
//

import Foundation

public struct UserOperationDependency {
    public let room: VoiceRoom
    
    public let userId: String
    public let userRole: SceneRoomUserType
    
    public let userSeatIndex: Int?
    public let userSeatMute: Bool?
    public let userSeatLock: Bool?
    
    public var isSeating: Bool {
        return userSeatIndex != nil
    }
    
    public var currentUserId: String {
        Environment.currentUserId
    }
    
    public var currentUserRole: SceneRoomUserType {
        if Environment.currentUserId == room.userId {
            return .creator
        }
        if SceneRoomManager.shared.managers.contains(currentUserId) {
            return .manager
        }
        return .audience
    }
    
    public init(room: VoiceRoom,
                userId: String,
                userRole: SceneRoomUserType = .audience,
                userSeatIndex: Int? = nil,
                userSeatMute: Bool? = false,
                userSeatLock: Bool? = false) {
        self.room = room
        self.userId = userId
        self.userRole = userRole
        self.userSeatIndex = userSeatIndex
        self.userSeatMute = userSeatMute
        self.userSeatLock = userSeatLock
    }
}

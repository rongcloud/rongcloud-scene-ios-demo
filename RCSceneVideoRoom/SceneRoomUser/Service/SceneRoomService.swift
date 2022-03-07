//
//  SceneRoomService.swift
//  RCSceneVoiceRoom
//
//  Created by shaoshuai on 2022/2/26.
//

import RCSceneService

let userService = SceneRoomService()

class SceneRoomService {
    func roomUsers(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.roomUsers(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func follow(userId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCUserService.follow(userId: userId)
        userProvider.request(api, completion: completion)
    }
    
    func followList(page: Int, type: Int, completion: @escaping RCSceneServiceCompletion) {
        let api = RCUserService.followList(page: page, type: type)
        userProvider.request(api, completion: completion)
    }
    
    func roomManagers(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.roomManagers(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func setRoomManager(roomId: String, userId: String, isManager: Bool, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.setRoomManager(roomId: roomId, userId: userId, isManager: isManager)
        roomProvider.request(api, completion: completion)
    }
}

//
//  VoiceRoomService.swift
//  RCSceneVoiceRoom
//
//  Created by hanxiaoqing on 2022/2/11.
//

import Foundation
import RCSceneService
import RCSceneFoundation

let radioRoomService = RadioRoomService()

class RadioRoomService {
    // room service
    func createRoom(name: String,
                    themePictureUrl: String,
                    backgroundUrl: String,
                    kv: [[String : String]],
                    isPrivate: Int,
                    password: String?,
                    roomType: Int,
                    completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.createRoom(name: name, themePictureUrl: themePictureUrl, backgroundUrl: backgroundUrl, kv: kv, isPrivate: isPrivate, password: password, roomType: roomType)
        roomProvider.request(api, completion: completion)
    }

    func roomBroadcast(userId: String, objectName: String, content: String) {
        let api = RCRoomService.roomBroadcast(userId: userId, objectName: objectName, content: content)
        roomProvider.request(api) { _ in }
    }
    
    func userUpdateCurrentRoom(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.userUpdateCurrentRoom(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func roomInfo(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.roomInfo(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func roomManagers(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.roomManagers(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func setRoomType(roomId: String, isPrivate: Bool, password: String?, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.setRoomType(roomId: roomId, isPrivate: isPrivate, password: password)
        roomProvider.request(api, completion: completion)
    }

    func setRoomName(roomId: String, name: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.setRoomName(roomId: roomId, name: name)
        roomProvider.request(api, completion: completion)
    }
    
    func closeRoom(roomId: String, completion: @escaping RCSceneServiceCompletion) {
       let api = RCRoomService.closeRoom(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func setRoomManager(roomId: String, userId: String, isManager: Bool, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.setRoomManager(roomId: roomId, userId: userId, isManager: isManager)
        roomProvider.request(api, completion: completion)
    }
    
    func roomUsers(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.roomUsers(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func updateRoomBackground(roomId: String, backgroundUrl: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.updateRoomBackgroundUrl(roomId: roomId, backgroundUrl: backgroundUrl)
        roomProvider.request(api, completion: completion)
    }
    
    func resumeRoom(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.resumeRoom(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func suspendRoom(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.suspendRoom(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func roomList(type: Int = 1, page: Int, size: Int, completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.roomList(type: type, page: page, size: size)
        roomProvider.request(api, completion: completion)
    }
    
    func checkCreatedRoom(completion: @escaping RCSceneServiceCompletion) {
        let api = RCRoomService.checkCreatedRoom
        roomProvider.request(api, completion: completion)
    }
    
    func usersInfo(id: [String], completion: @escaping RCSceneServiceCompletion) {
        let api = RCUserService.usersInfo(id: id)
        userProvider.request(api, completion: completion)
    }

    func follow(userId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCUserService.follow(userId: userId)
        userProvider.request(api, completion: completion)
    }

    func onlineCreator(completion: @escaping RCSceneServiceCompletion) {
        let api = RCUserService.onlineCreator
        userProvider.request(api, completion: completion)
    }
    
    
    func followList(page: Int, type: Int, completion: @escaping RCSceneServiceCompletion) {
        let api = RCUserService.followList(page: page, type: type)
        userProvider.request(api, completion: completion)
    }
    
    func checkText(text: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCChoreService.checkText(text: text)
        choreProvider.request(api, completion: completion)
    }

    func giftList(roomId: String, completion: @escaping RCSceneServiceCompletion) {
       let api = RCGiftService.giftList(roomId: roomId)
       giftProvider.request(api, completion: completion)
    }
    
    
    func setPKStatus(roomId: String, toRoomId: String, status: Int, completion: @escaping RCSceneServiceCompletion) {
        let api = RCPKService.setPKState(roomId: roomId, toRoomId: toRoomId, status: status)
        pkProvider.request(api, completion: completion)
    }

    func pkDetail(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCPKService.pkDetail(roomId: roomId)
        pkProvider.request(api, completion: completion)
    }

    func isPK(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCPKService.isPK(roomId: roomId)
        pkProvider.request(api, completion: completion)
    }
    
    func uploadAudio(data: Data, extensions: String?, completion: @escaping RCSceneServiceCompletion) {
        let api = RCUploadService.uploadAudio(data: data, extensions: extensions)
        uploadProvider.request(api, completion: completion)
    }
    
    func appendForbidden(roomId: String, name: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCForbiddenService.appendForbidden(roomId: roomId, name: name)
        forbiddenProvider.request(api, completion: completion)
    }

    func deleteForbidden(id: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCForbiddenService.deleteForbidden(id: id)
        forbiddenProvider.request(api, completion: completion)
    }
    
    func forbiddenList(roomId: String, completion: @escaping RCSceneServiceCompletion) {
        let api = RCForbiddenService.forbiddenList(roomId: roomId)
        forbiddenProvider.request(api, completion: completion)
    }
}

extension VoiceRoomUser {
    var rcUser: RCUserInfo {
        return RCUserInfo(userId: userId, name: userName, portrait: portraitUrl)
    }
}

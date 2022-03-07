//
//  VoiceRoomService.swift
//  RCSceneVoiceRoom
//
//  Created by hanxiaoqing on 2022/2/11.
//

import Foundation
import Moya

let videoRoomService = VideoRoomService()

class VideoRoomService {
    // room service
    func createRoom(name: String,
                    themePictureUrl: String,
                    backgroundUrl: String,
                    kv: [[String : String]],
                    isPrivate: Int,
                    password: String?,
                    roomType: Int,
                    completion: @escaping Completion) {
        let api = RCRoomService.createRoom(name: name, themePictureUrl: themePictureUrl, backgroundUrl: backgroundUrl, kv: kv, isPrivate: isPrivate, password: password, roomType: roomType)
        roomProvider.request(api, completion: completion)
    }

    func roomBroadcast(userId: String, objectName: String, content: String) {
        let api = RCRoomService.roomBroadcast(userId: userId, objectName: objectName, content: content)
        roomProvider.request(api) { _ in }
    }
    
    func userUpdateCurrentRoom(roomId: String, completion: @escaping Completion) {
        let api = RCRoomService.userUpdateCurrentRoom(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func roomInfo(roomId: String, completion: @escaping Completion) {
        let api = RCRoomService.roomInfo(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func roomManagers(roomId: String, completion: @escaping Completion) {
        let api = RCRoomService.roomManagers(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func setRoomType(roomId: String, isPrivate: Bool, password: String?, completion: @escaping Completion) {
        let api = RCRoomService.setRoomType(roomId: roomId, isPrivate: isPrivate, password: password)
        roomProvider.request(api, completion: completion)
    }

    func setRoomName(roomId: String, name: String, completion: @escaping Completion) {
        let api = RCRoomService.setRoomName(roomId: roomId, name: name)
        roomProvider.request(api, completion: completion)
    }
    
    func closeRoom(roomId: String, completion: @escaping Completion) {
       let api = RCRoomService.closeRoom(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func setRoomManager(roomId: String, userId: String, isManager: Bool, completion: @escaping Completion) {
        let api = RCRoomService.setRoomManager(roomId: roomId, userId: userId, isManager: isManager)
        roomProvider.request(api, completion: completion)
    }
    
    func roomUsers(roomId: String, completion: @escaping Completion) {
        let api = RCRoomService.roomUsers(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }

    func usersInfo(id: [String], completion: @escaping Completion) {
        let api = RCUserService.usersInfo(id: id)
        userProvider.request(api, completion: completion)
    }

    func follow(userId: String, completion: @escaping Completion) {
        let api = RCUserService.follow(userId: userId)
        userProvider.request(api, completion: completion)
    }

    func onlineCreator(completion: @escaping Completion) {
        let api = RCUserService.onlineCreator
        userProvider.request(api, completion: completion)
    }
    
    func checkText(text: String, completion: @escaping Completion) {
        let api = RCChoreService.checkText(text: text)
        choreProvider.request(api, completion: completion)
    }
    func appendForbidden(roomId: String, name: String, completion: @escaping Completion) {
        let api = RCForbiddenService.appendForbidden(roomId: roomId, name: name)
        forbiddenProvider.request(api, completion: completion)
    }

    func deleteForbidden(id: String, completion: @escaping Completion) {
        let api = RCForbiddenService.deleteForbidden(id: id)
        forbiddenProvider.request(api, completion: completion)
    }

    func forbiddenList(roomId: String, completion: @escaping Completion) {
        let api = RCForbiddenService.forbiddenList(roomId: roomId)
        forbiddenProvider.request(api, completion: completion)
    }
    
    func giftList(roomId: String, completion: @escaping Completion) {
       let api = RCGiftService.giftList(roomId: roomId)
       giftProvider.request(api, completion: completion)
    }
    
    func setPKStatus(roomId: String, toRoomId: String, status: Int, completion: @escaping Completion) {
        let api = RCPKService.setPKState(roomId: roomId, toRoomId: toRoomId, status: status)
        pkProvider.request(api, completion: completion)
    }

    func pkDetail(roomId: String, completion: @escaping Completion) {
        let api = RCPKService.pkDetail(roomId: roomId)
        pkProvider.request(api, completion: completion)
    }

    func isPK(roomId: String, completion: @escaping Completion) {
        let api = RCPKService.isPK(roomId: roomId)
        pkProvider.request(api, completion: completion)
    }

    func uploadAudio(data: Data, extensions: String?, completion: @escaping Completion) {
        let api = RCUploadService.uploadAudio(data: data, extensions: extensions)
        uploadProvider.request(api, completion: completion)
    }

    func upload(data: Data, completion: @escaping Completion) {
        let api = RCUploadService.upload(data: data)
        uploadProvider.request(api, completion: completion)
    }
    
    /// 是否在麦位上：支持语聊房、直播
    func setPKStatus(roomId: String, toRoomId: String, status: PKStatus, completion: ((Bool) -> Void)? = nil) {
        self.setPKStatus(roomId: roomId, toRoomId: toRoomId, status: status.rawValue) { result in
            switch result {
            case .success(_): completion?(true)
            case .failure(_): completion?(false)
            }
        }
    }
    
    func getCurrentPKInfo(roomId: String, completion: @escaping ((PKStatusModel?) -> Void)) {
        self.pkDetail(roomId: roomId) { result in
            switch result {
            case let .success(response):
                let pkInfo = try? JSONDecoder().decode(PKStatusModel.self, from: response.data, keyPath: "data")
                completion(pkInfo)
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
}

import RCSceneService

extension VoiceRoomUser {
    var rcUser: RCUserInfo {
        return RCUserInfo(userId: userId, name: userName, portrait: portraitUrl)
    }
}

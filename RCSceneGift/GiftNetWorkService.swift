//
//  GiftNetWorkService.swift
//  RCSceneGift
//
//  Created by hanxiaoqing on 2022/2/14.
//


import Foundation
import RCSceneService
import RCSceneFoundation
import Moya

let giftNetWorkService = GiftNetWorkService()

class GiftNetWorkService {
    func roomInfo(roomId: String, completion: @escaping Completion) {
        let api = RCRoomService.roomInfo(roomId: roomId)
        roomProvider.request(api, completion: completion)
    }
    
    func roomBroadcast(userId: String, objectName: String, content: String) {
        let api = RCRoomService.roomBroadcast(userId: userId, objectName: objectName, content: content)
        roomProvider.request(api) { _ in }
    }
    
    func sendGift(roomId: String, giftId: String, toUid: String, num: Int, completion: @escaping Completion) {
        let api = RCGiftService.sendGift(roomId: roomId, giftId: giftId, toUid: toUid, num: num)
        giftProvider.request(api, completion: completion)
    }    
}


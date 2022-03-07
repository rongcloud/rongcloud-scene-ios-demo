//
//  VoiceRoomService.swift
//  RCSceneVoiceRoom
//
//  Created by hanxiaoqing on 2022/2/11.
//

import Foundation
import RCSceneService
import RCSceneFoundation
import Moya

let giftService = GiftService()

class GiftService {
    func giftList(roomId: String, completion: @escaping Completion) {
       let api = RCGiftService.giftList(roomId: roomId)
       giftProvider.request(api, completion: completion)
    }
    
    func sendGift(roomId: String, giftId: String, toUid: String, num: Int, completion: @escaping Completion) {
        let api = RCGiftService.sendGift(roomId: roomId, giftId: giftId, toUid: toUid, num: num)
        giftProvider.request(api, completion: completion)
    }
}


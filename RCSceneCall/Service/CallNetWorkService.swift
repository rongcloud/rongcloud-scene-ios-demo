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

let callService = CallService()

class CallService {
    func usersInfo(id: [String], completion: @escaping Completion) {
        let api = RCUserService.usersInfo(id: id)
        userProvider.request(api, completion: completion)
    }
}


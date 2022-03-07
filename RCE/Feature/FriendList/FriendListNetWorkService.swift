//
//  FriendListNetWorkService.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/2/16.
//

import Foundation
import RCSceneService
import RCSceneFoundation
import Moya

let friendListNetService = FriendListNetWorkService()

class FriendListNetWorkService {
    func follow(userId: String, completion: @escaping Completion) {
        let api = RCUserService.follow(userId: userId)
        userProvider.request(api, completion: completion)
    }
    
    func followList(page: Int, type: Int, completion: @escaping Completion) {
        let api = RCUserService.followList(page: page, type: type)
        userProvider.request(api, completion: completion)
    }
}

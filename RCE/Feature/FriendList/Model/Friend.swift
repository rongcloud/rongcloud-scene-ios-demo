//
//  Friend.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/9.
//

import Foundation


struct FriendListWrapper: Codable {
    let code: Int
    let data: FriendList
}

struct FriendList: Codable {
    let total: Int
    let list: [RCSceneRoomUser]
}

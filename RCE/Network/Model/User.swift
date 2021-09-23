//
//  User.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String {
        return userId
    }
    let userId: String
    let userName: String
    let portrait: String?
    var imToken: String
    let authorization: String
    let type: Int
    
    var portraitUrl: String {
        return Environment.current.url.absoluteString + "/file/show?path=" + (portrait ?? "")
    }
}

struct VoiceRoomUserWrapper: Codable {
    let code: Int
    let data: [VoiceRoomUser]?
}

struct VoiceRoomUser: Codable, Equatable {
    let userId: String
    let userName: String
    let portrait: String?
    let status: Int?
    
    var portraitUrl: String {
        if let portrait = portrait, portrait.count > 0 {
            return Environment.current.url.absoluteString + "/file/show?path=" + portrait
        }
        return "https://cdn.ronghub.com/demo/default/rce_default_avatar.png"
    }
    
    var isFollow: Bool {
        return status == 1
    }
    
    var relation: Int?
    mutating func set(_ relation: Int) {
        self.relation = relation
    }
}

extension VoiceRoomUser {
    var rcUser: RCUserInfo {
        return RCUserInfo(userId: userId, name: userName, portrait: portraitUrl)
    }
}

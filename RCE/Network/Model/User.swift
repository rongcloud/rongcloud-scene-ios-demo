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

struct VoiceRoomUser: Codable, Equatable {
    let userId: String
    let userName: String
    let portrait: String?
    
    var portraitUrl: String {
        if let portrait = portrait, portrait.count > 0 {
            return Environment.current.url.absoluteString + "/file/show?path=" + portrait
        }
        return "https://cdn.ronghub.com/demo/default/rce_default_avatar.png"
    }
}

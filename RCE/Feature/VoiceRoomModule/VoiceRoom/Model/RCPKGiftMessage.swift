//
//  RCPKGiftMessage.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/19.
//

import UIKit

struct PKGiftModel: Codable {
    let score: Int
    let userInfoList: [RespRoomUser]
    let pkTime: Int?
}

struct PKGiftContent: Codable {
    let score: Int?
    let roomId: String?
    var userList: [RespRoomUser] = []
}

struct RespRoomUser: Codable {
    let userId: String
    let userName: String
    let portrait: String
}

class RCPKGiftMessage: RCMessageContent {
    
    var content: PKGiftContent?
    
    override func encode() -> Data! {
        guard let content = content else { return Data() }
        do {
            let data = try JSONEncoder().encode(content)
            return data
        } catch {
            fatalError("RCPKGift encode failed")
        }
    }
    
    override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(PKGiftContent.self, from: data)
        } catch {
            fatalError("RCPKGift decode failed: \(error.localizedDescription)")
        }
    }
    
    override class func getObjectName() -> String! { "RCMic:chrmPkMsg" }
    override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
    
    override func getSearchableWords() -> [String]! {
        return []
    }
}

//
//  RCGiftBroadcastMessage.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/19.
//

import UIKit

let broadcastGifts = ["7", "8"]

struct RCGiftBroadcast: Codable {
    let userId: String
    let userName: String
    
    let targetId: String?
    let targetName: String?
    
    let giftId: String
    let giftName: String
    let giftValue: String
    let giftCount: String
    
    let roomId: String
    let roomType: String
    
    let isPrivate: String?
}

class RCGiftBroadcastMessage: RCMessageContent {
    
    var content: RCGiftBroadcast?
    
    override func encode() -> Data! {
        guard let content = content else { return Data() }
        do {
            let userId = content.userId
            let data = try JSONEncoder().encode(content)
            let content = String(data: data, encoding: .utf8) ?? ""
            let json = ["content": content, "fromUserId": userId]
            return try JSONEncoder().encode(json)
        } catch {
            fatalError("RCGiftBroadcastMessage encode failed")
        }
    }
    override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCGiftBroadcast.self, from: data)
        } catch {
            debugPrint("RCGiftBroadcastMessage decode failed: \(error.localizedDescription)")
        }
    }
    override class func getObjectName() -> String! { "RC:RCGiftBroadcastMsg" }
    override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
}

extension RCGiftBroadcastMessage {
    static func sendMessageIfNeeded(_ gift: RCChatroomGift, room: VoiceRoom) {
        guard broadcastGifts.contains(gift.giftId) else { return }
        sendMessage(gift.broadcast(room))
    }
    
    static func sendMessageAllIfNeeded(_ gift: RCChatroomGiftAll, room: VoiceRoom) {
        guard broadcastGifts.contains(gift.giftId) else { return }
        sendMessage(gift.broadcast(room))
    }
    
    static func sendMessage(_ content: String) {
        let api = RCNetworkAPI.roomBroadcast(userId: Environment.currentUserId,
                                             objectName: "RC:RCGiftBroadcastMsg",
                                             content: content)
        networkProvider.request(api) { _ in }
        if let data = content.data(using: .utf8) {
            do {
                let message = RCGiftBroadcastMessage()
                message.content = try JSONDecoder().decode(RCGiftBroadcast.self, from: data)
                RCBroadcastManager.shared.add(message)
            } catch {
                debugPrint("broadcast message error: \(error.localizedDescription)")
            }
        }
    }
}

extension RCChatroomGift {
    func broadcast(_ room: VoiceRoom) -> String {
        let json: [String: String] = [
            "userId": userId,
            "userName": userName,
            "targetId": targetId,
            "targetName": targetName,
            "giftId": giftId,
            "giftName": giftName,
            "giftValue": "\(price)",
            "giftCount": "\(number)",
            "roomId": room.roomId,
            "roomType": "\(room.roomType ?? 1)",
            "isPrivate": "\(room.isPrivate)",
        ]
        let data = try! JSONEncoder().encode(json)
        return String(data: data, encoding: .utf8)!
    }
}

extension RCChatroomGiftAll {
    func broadcast(_ room: VoiceRoom) -> String {
        let json: [String: String] = [
            "userId": userId,
            "userName": userName,
            "giftId": giftId,
            "giftName": giftName,
            "giftValue": "\(price)",
            "giftCount": "\(number)",
            "roomId": room.roomId,
            "roomType": "\(room.roomType ?? 1)",
            "isPrivate": "\(room.isPrivate)",
        ]
        let data = try! JSONEncoder().encode(json)
        return String(data: data, encoding: .utf8)!
    }
}

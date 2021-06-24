//
//  VoiceRoomChatEvent.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/24.
//

import Foundation

typealias VoiceRoomEventTrack = (id: String, range: NSRange)

final class VoiceRoomChatEventManger {
    static let shared = VoiceRoomChatEventManger()
    
    var managerUsers: [VoiceRoomUser] = []
    var roomUserId: String = ""
    
    static func addRoleIfNeeded(_ userId: String, mutableAttributeString: NSMutableAttributedString) {
        if userId == shared.roomUserId {
            let textAttachment = NSTextAttachment()
            textAttachment.image = R.image.room_owner()
            textAttachment.bounds = CGRect(x: 0, y: -2.5, width: 14.resize, height: 14.resize)
            mutableAttributeString.append(NSAttributedString(attachment: textAttachment))
            mutableAttributeString.append(NSAttributedString(string: " "))
        } else if shared.managerUsers.contains(where: { $0.userId == userId }) {
            let textAttachment = NSTextAttachment()
            textAttachment.image = R.image.full_star()
            textAttachment.bounds = CGRect(x: 0, y: -1.5, width: 13.resize, height: 13.resize)
            mutableAttributeString.append(NSAttributedString(attachment: textAttachment))
            mutableAttributeString.append(NSAttributedString(string: " "))
        }
    }
}

protocol VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] { get }
    var attributeString: NSAttributedString { get }
    var backgroundColor: UIColor { get }
    var nameAttributes: [NSAttributedString.Key: Any] { get }
    var messageAttributes: [NSAttributedString.Key: Any] { get }
}

extension VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] { return [] }
    var backgroundColor: UIColor { return UIColor.black.withAlphaComponent(0.3) }
    var nameAttributes: [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 12.resize),
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
    }
    var messageAttributes: [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 12.resize),
            .foregroundColor: UIColor.white
        ]
    }
}

struct VoiceRoomChatEventWelcome: VoiceRoomChatEvent {
    var attributeString: NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.resize),
            .foregroundColor: UIColor(hexString: "#6A9FFF")
        ]
        return NSAttributedString(string: "欢迎来到\(roomName)", attributes: attributes)
    }
    let roomName: String
}

struct VoiceRoomChatEventStatement: VoiceRoomChatEvent {
    var attributeString: NSAttributedString {
        let content = "感谢使用融云RTC语音房，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.resize),
            .foregroundColor: UIColor(hexString: "#6A9FFF")
        ]
        return NSAttributedString(string: content, attributes: attributes)
    }
}

extension RCChatroomEnter: VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] {
        get {
            return [(userId, NSRange(location: 0, length: userName.count))]
        }
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        VoiceRoomChatEventManger.addRoleIfNeeded(userId, mutableAttributeString: result)
        let nameAttributeString = NSAttributedString(string: userName + " ", attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: "进来了", attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomBarrage: VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] {
        get {
            return [(userId, NSRange(location: 0, length: userName.count))]
        }
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        VoiceRoomChatEventManger.addRoleIfNeeded(userId, mutableAttributeString: result)
        let nameAttributeString = NSAttributedString(string: userName + "：", attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: content, attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomKickOut: VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] {
        get {
            return [
                (targetId, NSRange(location: 0, length: targetName.count)),
                (userId, NSRange(location: targetName.count + 3, length: userName.count)),
            ]
        }
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        VoiceRoomChatEventManger.addRoleIfNeeded(targetId, mutableAttributeString: result)
        let targetNameAttributeString = NSAttributedString(string: targetName, attributes: nameAttributes)
        result.append(targetNameAttributeString)
        let preAttributeString = NSAttributedString(string: " 被 ", attributes: messageAttributes)
        result.append(preAttributeString)
        VoiceRoomChatEventManger.addRoleIfNeeded(userId, mutableAttributeString: result)
        let userNameAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(userNameAttributeString)
        let sufAttributeString = NSAttributedString(string: " 踢出了房间", attributes: messageAttributes)
        result.append(sufAttributeString)
        return result
    }
}

extension RCChatroomGift: VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] {
        get {
            return [
                (userId, NSRange(location: 0, length: userName.count)),
                (targetId, NSRange(location: userName.count + 4, length: targetName.count)),
            ]
        }
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        VoiceRoomChatEventManger.addRoleIfNeeded(userId, mutableAttributeString: result)
        let sendAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(sendAttributeString)
        let giveAttributeString = NSAttributedString(string: " 送给 ", attributes: messageAttributes)
        result.append(giveAttributeString)
        VoiceRoomChatEventManger.addRoleIfNeeded(targetId, mutableAttributeString: result)
        let anchorAttributeString = NSAttributedString(string: targetName, attributes: nameAttributes)
        result.append(anchorAttributeString)
        let gifAttributeString = NSAttributedString(string: " " + giftName + "x\(number)", attributes: messageAttributes)
        result.append(gifAttributeString)
        return result
    }
    var backgroundColor: UIColor { return UIColor(hexString: "#FF74B8").withAlphaComponent(0.24) }
}

extension RCChatroomGiftAll: VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] {
        get {
            return [(userId, NSRange(location: 0, length: userName.count))]
        }
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        VoiceRoomChatEventManger.addRoleIfNeeded(userId, mutableAttributeString: result)
        let sendAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(sendAttributeString)
        let giveAttributeString = NSAttributedString(string: " 全麦打赏 " + giftName + "x\(number)", attributes: messageAttributes)
        result.append(giveAttributeString)
        return result
    }
    var backgroundColor: UIColor { return UIColor(hexString: "#FF74B8").withAlphaComponent(0.24) }
}

extension RCChatroomAdmin: VoiceRoomChatEvent {
    var tracks: [VoiceRoomEventTrack] {
        get {
            return [(userId, NSRange(location: 0, length: userName.count))]
        }
    }
    
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        VoiceRoomChatEventManger.addRoleIfNeeded(userId, mutableAttributeString: result)
        let nameAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(nameAttributeString)
        let message = isAdmin ? " 成为管理员" : " 被撤回管理员"
        let messageAttributeString = NSAttributedString(string: message, attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomSeats: VoiceRoomChatEvent {
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        let messageAttributeString = NSAttributedString(string: "更换为\(count)座模式，请重新上麦",
                                                        attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

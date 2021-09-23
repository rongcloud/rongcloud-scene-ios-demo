//
//  RCVRMMessageProtocol.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/10.
//

import Foundation

typealias RCVRMMessageTrack = (id: String, range: NSRange)

protocol RCVRMMessage {
    var backgroundColor: UIColor { get }
    var nameAttributes: [NSAttributedString.Key: Any] { get }
    var messageAttributes: [NSAttributedString.Key: Any] { get }
    
    var tracks: [RCVRMMessageTrack] { get }
    var attributeString: NSAttributedString { get }
}

extension RCVRMMessage {
    var backgroundColor: UIColor { return UIColor.black.withAlphaComponent(0.3) }
    var nameAttributes: [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
    }
    var messageAttributes: [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
    }
    var tracks: [RCVRMMessageTrack] { [] }
}

extension RCTextMessage: RCVRMMessage {
    var attributeString: NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(red: 106 / 255.0, green: 159 / 255.0, blue: 1, alpha: 1)
        ]
        return NSAttributedString(string: content, attributes: attributes)
    }
}

extension RCChatroomEnter: RCVRMMessage {
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        return [(userId, NSRange(location: userIndex, length: userName.count))]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName + " ", attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: "进来了", attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomBarrage: RCVRMMessage {
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        return [(userId, NSRange(location: userIndex, length: userName.count))]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName + "：", attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: content, attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomKickOut: RCVRMMessage {
    var tracks: [RCVRMMessageTrack] {
        let targetIndex = targetId.isMarked ? 2 : 0
        let userIndex = userId.isMarked ? 2 : 0
        let userLocation = targetIndex + targetName.count + 3 + userIndex
        return [
            (targetId, NSRange(location: targetIndex, length: targetName.count)),
            (userId, NSRange(location: userLocation, length: userName.count)),
        ]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(targetId)
        let targetNameAttributeString = NSAttributedString(string: targetName, attributes: nameAttributes)
        result.append(targetNameAttributeString)
        let preAttributeString = NSAttributedString(string: " 被 ", attributes: messageAttributes)
        result.append(preAttributeString)
        result.appendRoleIfNeeded(userId)
        let userNameAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(userNameAttributeString)
        let sufAttributeString = NSAttributedString(string: " 踢出了房间", attributes: messageAttributes)
        result.append(sufAttributeString)
        return result
    }
}

extension RCChatroomGift: RCVRMMessage {
    var backgroundColor: UIColor {
        return UIColor(red: 1, green: 116 / 255.0, blue: 184 / 255.0, alpha: 0.24)
    }
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        let targetIndex = targetId.isMarked ? 2 : 0
        let targetLocation = userIndex + userName.count + 4 + targetIndex
        return [
            (userId, NSRange(location: userIndex, length: userName.count)),
            (targetId, NSRange(location: targetLocation, length: targetName.count)),
        ]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let sendAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(sendAttributeString)
        let giveAttributeString = NSAttributedString(string: " 送给 ", attributes: messageAttributes)
        result.append(giveAttributeString)
        result.appendRoleIfNeeded(targetId)
        let anchorAttributeString = NSAttributedString(string: targetName, attributes: nameAttributes)
        result.append(anchorAttributeString)
        let gifAttributeString = NSAttributedString(string: " " + giftName + "x\(number)", attributes: messageAttributes)
        result.append(gifAttributeString)
        return result
    }
}

extension RCChatroomGiftAll: RCVRMMessage {
    var backgroundColor: UIColor {
        return UIColor(red: 1, green: 116 / 255.0, blue: 184 / 255.0, alpha: 0.24)
    }
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        return [(userId, NSRange(location: userIndex, length: userName.count))]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let sendAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(sendAttributeString)
        let giveAttributeString = NSAttributedString(string: " 全麦打赏 " + giftName + "x\(number)", attributes: messageAttributes)
        result.append(giveAttributeString)
        return result
    }
}

extension RCChatroomAdmin: RCVRMMessage {
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        return [(userId, NSRange(location: userIndex, length: userName.count))]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(nameAttributeString)
        let message = isAdmin ? " 成为管理员" : " 被撤回管理员"
        let messageAttributeString = NSAttributedString(string: message, attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomSeats: RCVRMMessage {
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        let messageAttributeString = NSAttributedString(string: "更换为\(count)座模式，请重新上麦",
                                                        attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCVRVoiceMessage: RCVRMMessage {
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        return [(userId, NSRange(location: userIndex, length: userName.count))]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let sendAttributeString = NSAttributedString(string: userName + "：", attributes: nameAttributes)
        result.append(sendAttributeString)
        return result
    }
}

extension RCChatroomFollow: RCVRMMessage {
    var userId: String { userInfo.userId }
    var userName: String { userId.isCurrentUser ? "你": userInfo.name }
    var targetUserId: String { targetUserInfo.userId }
    var targetUserName: String { targetUserId.isCurrentUser ? "你": targetUserInfo.name }
    var tracks: [RCVRMMessageTrack] {
        let userIndex = userId.isMarked ? 2 : 0
        let targetIndex = targetUserId.isMarked ? 2 : 0
        let targetLocation = userIndex + userName.count + 4 + targetIndex
        return [
            (userId, NSRange(location: userIndex, length: userName.count)),
            (targetUserId, NSRange(location: targetLocation, length: targetUserName.count)),
        ]
    }
    var attributeString: NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: " 关注了 ", attributes: messageAttributes)
        result.append(messageAttributeString)
        let targetAttributeString = NSAttributedString(string: targetUserName, attributes: nameAttributes)
        result.append(targetAttributeString)
        return result
    }
}

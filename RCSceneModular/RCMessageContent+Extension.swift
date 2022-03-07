//
//  RCMessageContent+Extension.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/11.
//

import RCSceneMessage
import RCSceneFoundation
import RCChatroomSceneKit

/// 当前所在房间的创建者id
fileprivate var roomUserId: String {
    SceneRoomManager.shared.currentRoom?.userId ?? ""
}
/// 管理员ids
fileprivate var mIds_E: [String] {
    SceneRoomManager.shared.managers
}

fileprivate var nameAttributes: [NSAttributedString.Key: Any] {
    return [
        .font: UIFont.systemFont(ofSize: 12),
        .foregroundColor: UIColor.white.withAlphaComponent(0.5)
    ]
}

fileprivate var messageAttributes: [NSAttributedString.Key: Any] {
    return [
        .font: UIFont.systemFont(ofSize: 12),
        .foregroundColor: UIColor.white
    ]
}

fileprivate extension String {
    var isMarked: Bool {
        return isOwner || isManager
    }
    
    var isOwner: Bool {
        return self == roomUserId
    }
    
    var isManager: Bool {
        return mIds_E.contains(self)
    }
}

fileprivate extension NSMutableAttributedString {
    func appendRoleIfNeeded(_ uId: String) {
        appendOwnerIconIfNeeded(uId)
        appendManagerIconIfNeeded(uId)
    }
    private func appendOwnerIconIfNeeded(_ uId: String) {
        guard uId.isOwner else { return }
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "chatroom_message_creator")
        textAttachment.bounds = CGRect(x: 0, y: -2.5, width: 14, height: 14)
        append(NSAttributedString(attachment: textAttachment))
        append(NSAttributedString(string: " "))
    }
    private func appendManagerIconIfNeeded(_ uId: String) {
        guard uId.isManager else { return }
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "chatroom_message_manager")
        textAttachment.bounds = CGRect(x: 0, y: -1.5, width: 13, height: 13)
        append(NSAttributedString(attachment: textAttachment))
        append(NSAttributedString(string: " "))
    }
}

extension RCTextMessage: RCChatroomSceneMessageProtocol {
    public func attributeString() -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(hexString: "#6A9FFF")
        ]
        if extra == "mixTypeChange" {
            attributes[.foregroundColor] = UIColor(hexString: "#F83F99")
        }
        return NSAttributedString(string: content, attributes: attributes)
    }
}

extension RCChatroomEnter: RCChatroomSceneMessageProtocol {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let range = NSRange(location: userIndex, length: userName.count)
        return [NSValue(range: range): userId]
    }
    
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName + " ", attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: "进来了", attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomBarrage: RCChatroomSceneMessageProtocol {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let range = NSRange(location: userIndex, length: userName.count)
        return [NSValue(range: range): userId]
    }
    
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName + "：", attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: content, attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCChatroomKickOut: RCChatroomSceneMessageProtocol {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let targetIndex = targetId.isMarked ? 2 : 0
        let userLocation = targetIndex + targetName.count + 3 + userIndex
        let userRange = NSRange(location: userLocation, length: userName.count)
        let targetUserRange = NSRange(location: targetIndex, length: targetName.count)
        return [
            NSValue(range: userRange): userId,
            NSValue(range: targetUserRange): targetId
        ]
    }
    public func attributeString() -> NSAttributedString {
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

extension RCChatroomGift: RCChatroomSceneMessageProtocol {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let targetIndex = targetId.isMarked ? 2 : 0
        let targetLocation = userIndex + userName.count + 4 + targetIndex
        let userRange = NSRange(location: userIndex, length: userName.count)
        let targetUserRange = NSRange(location: targetLocation, length: targetName.count)
        return [
            NSValue(range: userRange): userId,
            NSValue(range: targetUserRange): targetId
        ]
    }
    
    public func attributeString() -> NSAttributedString {
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

extension RCChatroomGiftAll: RCChatroomSceneMessageProtocol {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let range = NSRange(location: userIndex, length: userName.count)
        return [NSValue(range: range): userId]
    }
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let sendAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(sendAttributeString)
        let giveAttributeString = NSAttributedString(string: " 全麦打赏 " + giftName + "x\(number)", attributes: messageAttributes)
        result.append(giveAttributeString)
        return result
    }
}

extension RCChatroomAdmin: RCChatroomSceneMessageProtocol {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let range = NSRange(location: userIndex, length: userName.count)
        return [NSValue(range: range): userId]
    }
    public func attributeString() -> NSAttributedString {
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

extension RCChatroomSeats: RCChatroomSceneMessageProtocol {
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        let messageAttributeString = NSAttributedString(string: "更换为\(count)座模式，请重新上麦",
                                                        attributes: messageAttributes)
        result.append(messageAttributeString)
        return result
    }
}

extension RCVRVoiceMessage: RCChatroomSceneVoiceMessage {
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let range = NSRange(location: userIndex, length: userName.count)
        return [NSValue(range: range): userId]
    }
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let sendAttributeString = NSAttributedString(string: userName + "：", attributes: nameAttributes)
        result.append(sendAttributeString)
        return result
    }
    public func voiceDuration() -> Int {
        return Int(duration)
    }
    public func voicePath() -> String {
        return path
    }
}

extension RCHQVoiceMessage: RCChatroomSceneVoiceMessage {
    var userId: String { senderUserInfo.userId }
    var userName: String { senderUserInfo.name ?? userId }
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let range = NSRange(location: userIndex, length: userName.count)
        return [NSValue(range: range): userId]
    }
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let sendAttributeString = NSAttributedString(string: userName + "：", attributes: nameAttributes)
        result.append(sendAttributeString)
        return result
    }
    public func voiceDuration() -> Int {
        return Int(duration)
    }
    public func voicePath() -> String {
        return localPath ?? remoteUrl ?? ""
    }
}

extension RCChatroomFollow: RCChatroomSceneMessageProtocol {
    var userId: String { userInfo.userId }
    var userName: String { userId == Environment.currentUserId ? "你": userInfo.name }
    var targetUserId: String { targetUserInfo.userId }
    var targetUserName: String { targetUserId == Environment.currentUserId ? "你": targetUserInfo.name }
    public func events() -> [NSValue : String] {
        let userIndex = userId.isMarked ? 2 : 0
        let userRange = NSRange(location: userIndex, length: userName.count)
        let targetIndex = targetUserId.isMarked ? 2 : 0
        let targetLocation = userIndex + userName.count + 4 + targetIndex
        let targetUserRange = NSRange(location: targetLocation, length: targetUserName.count)
        return [
            NSValue(range: userRange): userId,
            NSValue(range: targetUserRange): targetUserId
        ]
    }
    public func attributeString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.appendRoleIfNeeded(userId)
        let nameAttributeString = NSAttributedString(string: userName, attributes: nameAttributes)
        result.append(nameAttributeString)
        let messageAttributeString = NSAttributedString(string: " 关注了 ", attributes: messageAttributes)
        result.append(messageAttributeString)
        result.appendRoleIfNeeded(targetUserId)
        let targetAttributeString = NSAttributedString(string: targetUserName, attributes: nameAttributes)
        result.append(targetAttributeString)
        return result
    }
}

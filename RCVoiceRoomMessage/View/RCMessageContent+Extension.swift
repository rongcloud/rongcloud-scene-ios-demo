//
//  RCMessageContent+Extension.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/11.
//

import Foundation

/// 当前用户id
var cId_E: String = ""
/// 当前所在房间的创建者id
var oId_E: String = ""
/// 当前所在房间的名字
var oName_E: String = ""
/// 管理员ids
var mIds_E: [String] = []

extension String {
    var isMarked: Bool {
        return self == oId_E || mIds_E.contains(self)
    }
    
    var isCurrentUser: Bool {
        return self == cId_E
    }
    
    var isOwner: Bool {
        return self == oId_E
    }
    
    var isManager: Bool {
        return mIds_E.contains(self)
    }
}

extension NSMutableAttributedString {
    func appendRoleIfNeeded(_ uId: String) {
        if uId == oId_E {
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage.creatorImage()
            textAttachment.bounds = CGRect(x: 0, y: -2.5, width: 14, height: 14)
            append(NSAttributedString(attachment: textAttachment))
            append(NSAttributedString(string: " "))
        } else if mIds_E.contains(uId) {
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage.managerImage()
            textAttachment.bounds = CGRect(x: 0, y: -1.5, width: 13, height: 13)
            append(NSAttributedString(attachment: textAttachment))
            append(NSAttributedString(string: " "))
        }
    }
}

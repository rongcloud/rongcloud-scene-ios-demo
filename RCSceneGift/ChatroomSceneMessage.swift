//
//  ChatroomSceneMessage.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/27.
//

import Foundation
import SVProgressHUD

import RCSceneService
import RCSceneMessage
import RCSceneFoundation

import RongIMLib

struct ChatroomError: Error, LocalizedError {
    let msg: String
    
    init(_ msg: String) {
        self.msg = msg
    }
    
    var errorDescription: String? {
        return msg
    }
}

func ChatroomSendMessage(_ content: RCMessageContent,_ roomId: String?,
                         result:((Result<Int, ChatroomError>) -> Void)? = nil)
{
    guard let roomId = roomId else {
        result?(.failure(ChatroomError("没有加入房间")))
        return
    }
    RCChatroomMessageCenter.sendChatMessage(roomId, content: content) { code, mId in
        if code == .RC_SUCCESS {
            result?(.success(mId))
        } else {
            result?(.failure(ChatroomError("消息发送失败：\(code.rawValue)")))
        }
    }
}

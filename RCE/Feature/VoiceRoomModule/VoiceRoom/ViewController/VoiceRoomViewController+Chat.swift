//
//  VoiceRoomViewController+Chat.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/18.
//

import UIKit

extension VoiceRoomViewController {
    @_dynamicReplacement(for: managerlist)
    private var chat_managerlist: [VoiceRoomUser] {
        get {
            return managerlist
        }
        set {
            managerlist = newValue
            messageView.reloadMessages()
        }
    }
    
    @_dynamicReplacement(for: setupModules)
    private func setupChatModule() {
        setupModules()
        toolBarView.add(chat: self, action: #selector(handleInputButtonClick))
        messageView.delegate = self
        messageView.dataSource = self
        messageView.update(cId: voiceRoomInfo.userId,
                           rName: voiceRoomInfo.roomName,
                           uId: Environment.currentUserId)
        addConstMessages()
    }
    
    @objc private func handleInputButtonClick() {
        navigator(.inputMessage(roomId: voiceRoomInfo.roomId, delegate: self))
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func chat_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard message.conversationType == .ConversationType_CHATROOM else { return }
        messageView.add(message.content)
    }
    
    private func addConstMessages() {
        let welcome = RCTextMessage(content: "欢迎来到\(voiceRoomInfo.roomName)")!
        welcome.extra = "welcome"
        messageView.add(welcome)
        let statement = RCTextMessage(content: "感谢使用融云RTC语音房，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。")!
        statement.extra = "statement"
        messageView.add(statement)
    }
}

extension VoiceRoomViewController {
    func sendJoinRoomMessage() {
        let roomId = voiceRoomInfo.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] mId in
                self?.messageView.add(event)
            } error: { code, mId in }
        }
    }
}

extension VoiceRoomViewController: VoiceRoomInputMessageProtocol {
    func onSendMessage(_ userId: String, userName: String, content: String) {
        let event = RCChatroomBarrage()
        event.userId = userId
        event.userName = userName
        event.content = content
        messageView.add(event)
    }
}

extension VoiceRoomViewController: RCVRMViewDelegate {
    func voiceRoomView(_ view: RCVRMView, didClick userId: String) {
        let currentUserId = Environment.currentUserId
        if userId == currentUserId { return }
        let dependency = VoiceRoomUserOperationDependency(room: voiceRoomInfo, presentUserId: userId)
        navigator(.manageUser(dependency: dependency, delegate: self))
    }
}

extension VoiceRoomViewController: RCVRMViewDataSource {
    func voiceRoomViewManagerIds(_ view: RCVRMView) -> [String] {
        return SceneRoomManager.shared.managerlist
    }
}

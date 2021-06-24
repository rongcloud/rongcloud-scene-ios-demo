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
            messageView.update(managerlist)
        }
    }
    
    @_dynamicReplacement(for: setupModules)
    private func setupChatModule() {
        setupModules()
        toolBarView.add(chat: self, action: #selector(handleInputButtonClick))
        messageView.delegate = self
    }
    
    @objc private func handleInputButtonClick() {
        navigator(.inputMessage(roomId: voiceRoomInfo.roomId, delegate: self))
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func chat_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        messageView.handle(message)
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

extension VoiceRoomViewController: ChatMessageViewProtocol {
    func onUserClicked(_ userId: String) {
        let currentUserId = Environment.currentUserId
        if userId == currentUserId { return }
        let dependency = ManageUserDependency(roomId: voiceRoomInfo.roomId, roomCreator: voiceRoomInfo.userId, presentUserId: userId)
        navigator(.manageUser(dependency: dependency, delegate: self))
    }
}

extension ChatMessageView {
    func onUserEnter(_ userId: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
            guard let self = self else { return }
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            self.add(event)
        }
    }
}

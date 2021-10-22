//
//  LiveVideoRoomHostController+Message.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewWillAppear(_:))
    private func broadcast_viewWillAppear(_ animated: Bool) {
        m_viewWillAppear(animated)
        if room != nil {
            toolBarView.refreshUnreadMessageCount()
        }
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func message_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard let content = message.content else { return }
        switch message.conversationType {
        case .ConversationType_CHATROOM:
            messageView.add(content)
        case .ConversationType_PRIVATE:
            toolBarView.refreshUnreadMessageCount()
        default: ()
        }
    }
    
    func setupMessageView() {
        messageView.delegate = self
        messageView.dataSource = self
        messageView.update(cId: room.userId,
                           rName: room.roomName,
                           uId: Environment.currentUserId)
        addConstMessages()
        messageView.reloadMessages()
        toolBarView.add(message: self, action: #selector(handleMessageButtonClick))
        toolBarView.add(chat: self, action: #selector(handleInputButtonClick))
    }
    
    private func addConstMessages() {
        let welcome = RCTextMessage(content: "欢迎来到\(room.roomName)")!
        welcome.extra = "welcome"
        messageView.add(welcome)
        let statement = RCTextMessage(content: "感谢使用融云 RTC 视频直播，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。")!
        statement.extra = "statement"
        messageView.add(statement)
    }
    
    @objc private func handleInputButtonClick() {
        navigator(.inputMessage(roomId: room.roomId, delegate: self))
    }
    
    @objc private func handleMessageButtonClick() {
        navigator(.messagelist)
    }
}

extension LiveVideoRoomHostController: RCVRMViewDataSource {
    func voiceRoomViewManagerIds(_ view: RCVRMView) -> [String] {
        return managers.map { $0.userId }
    }
}

extension LiveVideoRoomHostController: RCVRMViewDelegate {
    func voiceRoomView(_ view: RCVRMView, didClick userId: String) {
        let currentUserId = Environment.currentUserId
        if userId == currentUserId { return }
        let dependency = VoiceRoomUserOperationDependency(room: room,
                                                          presentUserId: userId)
        navigator(.manageUser(dependency: dependency, delegate: self))
    }
}

extension LiveVideoRoomHostController {
    func handleUserEnter(_ userId: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            self?.messageView.add(event)
        }
    }
    
    func handleUserExit(_ userId: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
            let event = RCChatroomLeave()
            event.userId = user.userId
            event.userName = user.userName
            self?.messageView.add(event)
        }
    }
    
    func handleKickOutRoom(_ userId: String, by operatorId: String) {
        UserInfoDownloaded.shared.fetch([operatorId, userId]) { [weak self] users in
            let event = RCChatroomKickOut()
            event.userId = users[0].userId
            event.userName = users[0].userName
            event.targetId = users[1].userId
            event.targetName = users[1].userName
            self?.messageView.add(event)
        }
    }
}

extension LiveVideoRoomHostController: VoiceRoomInputMessageProtocol {
    func onSendMessage(_ userId: String, userName: String, content: String) {
        let event = RCChatroomBarrage()
        event.userId = userId
        event.userName = userName
        event.content = content
        messageView.add(event)
    }
}


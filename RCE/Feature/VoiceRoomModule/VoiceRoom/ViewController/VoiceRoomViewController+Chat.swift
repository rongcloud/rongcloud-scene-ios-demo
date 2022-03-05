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
            messageView.tableView.reloadData()
        }
    }
    
    @_dynamicReplacement(for: setupModules)
    private func setupChatModule() {
        setupModules()
        messageView.setEventDelegate(self)
        addConstMessages()
    }
    
    @objc private func handleInputButtonClick() {
        navigator(.inputMessage(roomId: voiceRoomInfo.roomId, delegate: self))
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func chat_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard message.conversationType == .ConversationType_CHATROOM else { return }
        guard let message = message.content as? RCChatroomSceneMessageProtocol else { return }
        messageView.addMessage(message)
    }
    
    private func addConstMessages() {
        let welcome = RCTextMessage(content: "欢迎来到\(voiceRoomInfo.roomName)")!
        welcome.extra = "welcome"
        messageView.addMessage(welcome)
        let statement = RCTextMessage(content: "感谢使用融云RTC语音房，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。")!
        statement.extra = "statement"
        messageView.addMessage(statement)
    }
}

extension VoiceRoomViewController: RCChatroomSceneEventProtocol {
    func cell(_ cell: UITableViewCell, didClickEvent eventId: String) {
        let currentUserId = Environment.currentUserId
        if eventId == currentUserId { return }
        let alertController = RCLVRSeatAlertUserViewController(eventId)
        alertController.userDelegate = self
        present(alertController, animated: false)
    }
}

extension VoiceRoomViewController {
    func sendJoinRoomMessage() {
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            ChatroomSendMessage(event, messageView: self.messageView)
        }
    }
}

extension VoiceRoomViewController: VoiceRoomInputMessageProtocol {
    func onSendMessage(_ userId: String, userName: String, content: String) {
        let event = RCChatroomBarrage()
        event.userId = userId
        event.userName = userName
        event.content = content
        messageView.addMessage(event)
    }
}

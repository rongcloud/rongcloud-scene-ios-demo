//
//  LiveVideoRoomViewController+PublicMsg.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import UIKit

extension LiveVideoRoomViewController {
    
    var messageView: RCChatroomSceneMessageView {
        return chatroomView.messageView
    }
    
    @_dynamicReplacement(for: managers)
    private var publicMsg_managers: [VoiceRoomUser] {
        get { managers }
        set {
            managers = newValue
            messageView.tableView.reloadData()
        }
    }
    
    @_dynamicReplacement(for: m_viewWillAppear(_:))
    private func broadcast_viewWillAppear(_ animated: Bool) {
        m_viewWillAppear(animated)
        refreshUnreadMessageCount()
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func publicMsg_viewDidLoad() {
        m_viewDidLoad()
        messageView.setEventDelegate(self)
        addConstMessages()
        messageView.tableView.reloadData()
        messageButton.addTarget(self, action: #selector(handleMessageButtonClick), for: .touchUpInside)
        refreshUnreadMessageCount()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func message_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard let content = message.content else { return }
        switch message.conversationType {
        case .ConversationType_CHATROOM:
            if let msg = content as? RCChatroomSceneMessageProtocol {
                chatroomView.messageView.addMessage(msg)
            }
        case .ConversationType_PRIVATE:
            refreshUnreadMessageCount()
        default: ()
        }
    }
    
    private func addConstMessages() {
        let welcome = RCTextMessage(content: "欢迎来到\(room.roomName)")!
        welcome.extra = "welcome"
        chatroomView.messageView.addMessage(welcome)
        let statement = RCTextMessage(content: "感谢使用融云 RTC 视频直播，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。")!
        statement.extra = "statement"
        chatroomView.messageView.addMessage(statement)
    }
    
    @objc private func handleMessageButtonClick() {
        videoRouter.trigger(.chatList)
    }
    
    func refreshUnreadMessageCount() {
        let unreadCount = RCIMClient.shared()
            .getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        messageButton.setBadgeCount(Int(unreadCount))
    }
}

extension LiveVideoRoomViewController: RCChatroomSceneEventProtocol {
    func cell(_ cell: UITableViewCell, didClickEvent eventId: String) {
        let currentUserId = Environment.currentUserId
        if eventId == currentUserId { return }
        let alertController = RCLVRSeatAlertUserViewController(eventId)
        alertController.userDelegate = self
        present(alertController, animated: false)
    }
}

extension LiveVideoRoomViewController {
    func sendJoinRoomMessage() {
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            ChatroomSendMessage(event) { result in
                switch result {
                case .success:
                    self.messageView.addMessage(event)
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        }
    }
    
    func sendLeaveRoomMessage() {
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomLeave()
            event.userId = user.userId
            event.userName = user.userName
            ChatroomSendMessage(event)
        }
    }
    
    func handleUserEnter(_ userId: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            self?.messageView.addMessage(event)
        }
    }
    
    func handleKickOutRoom(_ userId: String, by operatorId: String) {
        UserInfoDownloaded.shared.fetch([operatorId, userId]) { [weak self] users in
            let event = RCChatroomKickOut()
            event.userId = users[0].userId
            event.userName = users[0].userName
            event.targetId = users[1].userId
            event.targetName = users[1].userName
            self?.messageView.addMessage(event)
        }
    }
}

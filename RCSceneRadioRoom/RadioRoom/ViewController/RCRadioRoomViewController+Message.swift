//
//  RCRadioRoomViewController+Message.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import SVProgressHUD
import RCSceneMessage
import RCSceneService
import RCSceneFoundation
import RCChatroomSceneKit
import RCSceneModular

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: managers)
    private var chat_managers: [VoiceRoomUser] {
        get { managers }
        set {
            managers = newValue
            messageView.tableView.reloadData()
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func message_viewDidLoad() {
        m_viewDidLoad()
        RCIM.shared().receiveMessageDelegate = self
        messageView.setEventDelegate(self)
        addConstMessages()
    }
    
    private func addConstMessages() {
        let welcome = RCTextMessage(content: "欢迎来到\(roomInfo.roomName)")!
        welcome.extra = "welcome"
        messageView.addMessage(welcome)
        let statement = RCTextMessage(content: "感谢使用融云RTC语音房，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。")!
        statement.extra = "statement"
        messageView.addMessage(statement)
    }
    
    @objc private func handlePrivateMessageButtonClick() {
        radioRouter.trigger(.messageList)
    }
}

extension RCRadioRoomViewController {
    func sendJoinRoomMessage() {
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            ChatroomSendMessage(event, messageView: self.messageView)
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
}

extension RCRadioRoomViewController: RCIMReceiveMessageDelegate {
    func onRCIMReceive(_ message: RCMessage!, left: Int32) {
        guard let _ = message.content else { return }
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
            self.handleMessage(message)
        }
    }
    
    func onRCIMCustomAlertSound(_ message: RCMessage!) -> Bool {
        return true
    }
    
    private func handleMessage(_ message: RCMessage) {
        switch message.conversationType {
        case .ConversationType_CHATROOM:
            if let message = message.content as? RCChatroomSceneMessageProtocol {
                messageView.addMessage(message)
            }
        case .ConversationType_PRIVATE:
            messageButton.refreshMessageCount()
        default: ()
        }
    }
}

extension RCRadioRoomViewController: RCChatroomSceneEventProtocol {
    func cell(_ cell: UITableViewCell, didClickEvent eventId: String) {
        let currentUserId = Environment.currentUserId
        if eventId == currentUserId { return }
        let userRole: SceneRoomUserType = {
            if roomInfo.isOwner { return .creator }
            if SceneRoomManager.shared.managers.contains(eventId) {
                return .manager
            }
            return .audience
        }()
        let userSeatIndex = userRole == .creator ? 0 : nil
        let userSeatMute = userRole == .creator ? roomKVState.mute : nil
        let dependency = UserOperationDependency(room: roomInfo,
                                                 userId: eventId,
                                                 userRole: userRole,
                                                 userSeatIndex: userSeatIndex,
                                                 userSeatMute: userSeatMute,
                                                 userSeatLock: false)
        let controller = UserOperationViewController(dependency: dependency, delegate: self)
        present(controller, animated: false)
    }
}

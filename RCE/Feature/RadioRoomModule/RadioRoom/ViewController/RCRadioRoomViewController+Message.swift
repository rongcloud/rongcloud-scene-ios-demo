//
//  RCRadioRoomViewController+Message.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import SVProgressHUD
import RCRTCAudio

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: managerlist)
    private var chat_managerlist: [VoiceRoomUser] {
        get { managerlist }
        set {
            managerlist = newValue
            messageView.reloadMessages()
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func message_viewDidLoad() {
        m_viewDidLoad()
        RCIM.shared().receiveMessageDelegate = self
        roomToolBarView.add(chat: self, action: #selector(handleInputButtonClick))
        roomToolBarView.add(message: self, action: #selector(handlePrivateMessageButtonClick))
        roomToolBarView.recordButton.recordDidSuccess = { [unowned self] result in
            recordDidSuccess(result)
        }
        messageView.delegate = self
        messageView.dataSource = self
        messageView.update(cId: roomInfo.userId,
                           rName: roomInfo.roomName,
                           uId: Environment.currentUserId)
        addConstMessages()
    }
    
    private func addConstMessages() {
        let welcome = RCTextMessage(content: "欢迎来到\(roomInfo.roomName)")!
        welcome.extra = "welcome"
        messageView.add(welcome)
        let statement = RCTextMessage(content: "感谢使用融云RTC语音房，请遵守相关法规，不要传播低俗、暴力等不良信息。欢迎您把使用过程中的感受反馈与我们。")!
        statement.extra = "statement"
        messageView.add(statement)
    }
    
    @objc private func handlePrivateMessageButtonClick() {
        navigator(.messagelist)
    }
    
    @objc private func handleInputButtonClick() {
        navigator(.inputMessage(roomId: roomInfo.roomId, delegate: self))
    }
        
    private func recordDidSuccess(_ result: (url: URL, time: TimeInterval)?) {
        guard let result = result else { return }
        let url = result.url
        let time = UInt(result.time)
        if time < 1 {
            return SVProgressHUD.showError(withStatus: "录音时间太短")
        }
        guard let data = try? Data(contentsOf: url) else {
            return SVProgressHUD.showError(withStatus: "录音文件错误")
        }
        let ext = url.pathExtension
        networkProvider.request(.uploadAudio(data: data, extension: ext)) { [weak self] result in
            switch result {
            case let .success(response):
                guard
                    let model = try? JSONDecoder().decode(UploadfileResponse.self, from: response.data)
                else { return }
                let urlString = Environment.current.url.absoluteString + "/file/show?path=" + model.data
                self?.sendMessage(urlString, time: time, url: url)
                self?.relisten()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func sendMessage(_ voice: String, time: UInt, url: URL) {
        let roomId = roomInfo.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let message = RCVRVoiceMessage()
            message.userId = user.userId
            message.userName = user.userName
            message.path = voice
            message.duration = time
            RCChatroomMessageCenter.sendChatMessage(roomId, content: message) { [weak self] mId in
                self?.messageView.add(message)
                RCRTCAudioRecorder.shared.remove(url)
            } error: { eCode, mId in
                RCRTCAudioRecorder.shared.remove(url)
            }
        }
    }
}

extension RCRadioRoomViewController {
    func sendJoinRoomMessage() {
        let roomId = roomInfo.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomEnter()
            event.userId = user.userId
            event.userName = user.userName
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] mId in
                self?.messageView.add(event)
            } error: { code, mId in }
        }
    }
    
    func sendLeaveRoomMessage() {
        let roomId = roomInfo.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let event = RCChatroomLeave()
            event.userId = user.userId
            event.userName = user.userName
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { _ in } error: { _, _ in }
        }
    }
}

extension RCRadioRoomViewController: VoiceRoomInputMessageProtocol {
    func onSendMessage(_ userId: String, userName: String, content: String) {
        let event = RCChatroomBarrage()
        event.userId = userId
        event.userName = userName
        event.content = content
        messageView.add(event)
    }
}

extension RCRadioRoomViewController: RCVRMViewDataSource {
    func voiceRoomViewManagerIds(_ view: RCVRMView) -> [String] {
        return managerlist.map { $0.userId }
    }
}

extension RCRadioRoomViewController: RCVRMViewDelegate {
    func voiceRoomView(_ view: RCVRMView, didClick userId: String) {
        let currentUserId = Environment.currentUserId
        if userId == currentUserId { return }
        let dependency = VoiceRoomUserOperationDependency(room: roomInfo,
                                                          presentUserId: userId)
        navigator(.manageUser(dependency: dependency, delegate: self))
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
            messageView.add(message.content)
        case .ConversationType_PRIVATE:
            roomToolBarView.refreshUnreadMessageCount()
        default: ()
        }
    }
}

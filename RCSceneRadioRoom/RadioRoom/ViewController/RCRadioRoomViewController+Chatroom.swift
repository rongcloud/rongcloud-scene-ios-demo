//
//  RCRadioRoomViewController+Chatroom.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/26.
//

import SVProgressHUD
import RCSceneFoundation
import RCSceneMessage
import RCSceneService
import RCChatroomSceneKit

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func toolBar_viewDidLoad() {
        m_viewDidLoad()
        giftButton.addTarget(self, action: #selector(handleGiftButtonClick), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessageButtonClick), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(handleSettingClick), for: .touchUpInside)
        setupToolBarView()
    }
    
    func setupToolBarView() {
        let config = RCChatroomSceneToolBarConfig.default()
        if roomInfo.isOwner {
            config.actions = [giftButton, messageButton, settingButton]
        } else {
            config.actions = [giftButton, messageButton]
        }
        config.recordButtonEnable = !roomInfo.isOwner
        chatroomView.toolBar.setConfig(config)
        chatroomView.toolBar.delegate = self
    }
    
    @objc func handleMessageButtonClick() {
        radioRouter.trigger(.messageList)
    }
}

extension RCRadioRoomViewController: RCChatroomSceneToolBarDelegate {
    func textInputViewSendText(_ text: String) {
        let roomId = roomInfo.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            let event = RCChatroomBarrage()
            event.userId = user.userId
            event.userName = user.userName
            event.content = text
            self?.chatroomView.messageView.addMessage(event)
            if text.isCivilized {
                RCChatroomMessageCenter.sendChatMessage(roomId,
                                                        content: event,
                                                        result: { _, _ in })
            }
        }
    }
    
    func audioRecordShouldBegin() -> Bool {
        if RCCoreClient.shared().isAudioHolding() {
            SVProgressHUD.showError(withStatus: "声音通道被占用，请下麦后使用")
            return false
        }
        return true
    }
    
    func audioRecordDidEnd(_ data: Data?, time: TimeInterval) {
        guard let data = data, time > 1 else { return SVProgressHUD.showError(withStatus: "录音时间太短") }
        radioRoomService.uploadAudio(data: data, extensions: "wav") { [weak self] result in
            switch result.map(UploadfileResponse.self) {
            case let .success(response):
                let urlString = Environment.current.url.absoluteString + "/file/show?path=" + response.data
                self?.sendMessage(urlString, time: Int(time) + 1)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func sendMessage(_ URLString: String, time: Int) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let message = RCVRVoiceMessage()
            message.userId = user.userId
            message.userName = user.userName
            message.path = URLString
            message.duration = UInt(time)
            ChatroomSendMessage(message, messageView: self.messageView)
        }
    }
    
}

extension String {
    var civilized: String {
        return SceneRoomManager.shared.forbiddenWordlist.reduce(self) { $0.replacingOccurrences(of: $1, with: String(repeating: "*", count: $1.count)) }
    }
    
    var isCivilized: Bool {
        return SceneRoomManager.shared.forbiddenWordlist.first(where: { contains($0) }) == nil
    }
}

//
//  LiveVideoRoomViewController+ToolBar.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/2.
//

import SVProgressHUD
import Foundation

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var message_role: RCRTCLiveRoleType {
        get { role }
        set {
            let same = newValue == role
            role = newValue
            if same { return }
            let config = RCChatroomSceneToolBarConfig.default()
            config.actions = [micButton, giftButton, messageButton]
            config.recordButtonEnable = role == .audience
            chatroomView.toolBar.setConfig(config)
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func chatroom_viewDidLoad() {
        m_viewDidLoad()
        
        micButton.micState = .request
        chatroomView.toolBar.delegate = self
        let config = RCChatroomSceneToolBarConfig.default()
        config.actions = [micButton, giftButton, messageButton]
        config.recordButtonEnable = true
        chatroomView.toolBar.setConfig(config)
    }
}

extension LiveVideoRoomViewController: RCChatroomSceneToolBarDelegate {
    func textInputViewSendText(_ text: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            let event = RCChatroomBarrage()
            event.userId = user.userId
            event.userName = user.userName
            event.content = text
            self?.messageView.addMessage(event)
            if text.isCivilized {
                RCLiveVideoEngine.shared().sendMessage(event) { _ in }
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
    func audioRecordDidBegin() {
        
    }
    
    func audioRecordDidCancel() {
        
    }
    
    func audioRecordDidEnd(_ data: Data?, time: TimeInterval) {
        guard let data = data, time > 1 else { return SVProgressHUD.showError(withStatus: "录音时间太短") }
        networkProvider.request(.uploadAudio(data: data, extension: "wav")) { [weak self] result in
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
        let roomId = room.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let message = RCVRVoiceMessage()
            message.userId = user.userId
            message.userName = user.userName
            message.path = URLString
            message.duration = UInt(time)
            RCChatroomMessageCenter.sendChatMessage(roomId, content: message) { [weak self] mId in
                self?.messageView.addMessage(message)
            } error: { eCode, mId in
            }
        }
    }
}

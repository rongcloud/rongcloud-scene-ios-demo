//
//  LiveVideoRoomHostController+ToolBar.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/29.
//

import UIKit
import SVProgressHUD

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func toolBar_viewDidLoad() {
        m_viewDidLoad()
        micButton.addTarget(self, action: #selector(liveVideoRequestDidClick), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(handleGiftButtonClick), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessageButtonClick), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(handleSettingClick), for: .touchUpInside)
        messageButton.refreshMessageCount()
    }
    
    func setupToolBarView() {
        messageButton.refreshMessageCount()
        micButton.micState = .user
        chatroomView.toolBar.delegate = self
        let config = RCChatroomSceneToolBarConfig.default()
        config.commonActions = [micButton]
        config.actions = [giftButton, messageButton, settingButton]
        config.recordButtonEnable = false
        chatroomView.toolBar.setConfig(config)
    }
    
    @objc func handleMessageButtonClick() {
        navigator(.messagelist)
    }
}

extension LiveVideoRoomHostController: RCChatroomSceneToolBarDelegate {
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

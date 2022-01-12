//
//  VoiceRoomViewController+Setting.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/18.
//

import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        toolBarView.add(setting: self, action: #selector(handleSettingClick))
    }
    
    @objc private func handleSettingClick() {
        navigator(.roomSetting(roomState.settinglist(), self))
    }
    
    private func setRoomType(isPrivate: Bool, password: String?) {
        let title = isPrivate ? "设置房间密码" : "解锁"
        let api: RCNetworkAPI = .setRoomType(roomId: voiceRoomInfo.roomId,
                                             isPrivate: isPrivate,
                                             password: password)
        func onSuccess() {
            SVProgressHUD.showSuccess(withStatus: "已\(title)")
            roomState.isPrivate = isPrivate
        }
        func onError() {
            SVProgressHUD.showError(withStatus: title + "失败")
        }
        networkProvider.request(api) { result in
            switch result {
            case let .success(response):
                guard
                    let model = try? JSONDecoder().decode(AppResponse.self, from: response.data),
                    model.validate()
                else { return onError() }
                onSuccess()
            case .failure: onError()
            }
        }
    }
}

//MARK: - Voice Room Setting Delegate
extension VoiceRoomViewController: VoiceRoomSettingProtocol {
    /// 房间上锁&解锁
    func lockRoomDidClick(isLock: Bool) {
        if isLock {
            navigator(.inputPassword(type: .input, delegate: self))
        } else {
            setRoomType(isPrivate: false, password: nil)
        }
    }
    /// 全麦锁麦
    func muteAllSeatDidClick(isMute: Bool) {
        roomState.isMuteAll = isMute
        RCVoiceRoomEngine.sharedInstance().muteOtherSeats(isMute)
        SVProgressHUD.showSuccess(withStatus: isMute ? "全部麦位已静音" : "已解锁全麦")
    }
    /// 全麦锁座
    func lockAllSeatDidClick(isLock: Bool) {
        roomState.isLockAll = isLock
        RCVoiceRoomEngine.sharedInstance().lockOtherSeats(isLock)
        SVProgressHUD.showSuccess(withStatus: isLock ? "全部座位已锁定" : "已解锁全座")
    }
    /// 静音
    func silenceSelfDidClick(isSilence: Bool) {
        roomState.isSilence = isSilence
        RCVoiceRoomEngine.sharedInstance().muteAllRemoteStreams(isSilence)
        SVProgressHUD.showSuccess(withStatus: isSilence ? "扬声器已静音" : "已取消静音")
    }
    /// 音乐
    func musicDidClick() {
        presentMusicController()
    }
    /// 自由上麦
    func freeMicDidClick(isFree: Bool) {
        if let kvRoom = kvRoomInfo {
            kvRoom.isFreeEnterSeat = isFree
            RCVoiceRoomEngine.sharedInstance().setRoomInfo(kvRoom) {
                SVProgressHUD.showSuccess(withStatus: isFree ? "当前观众可自由上麦" : "当前观众上麦要申请")
            } error: { code, msg in
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
    /// 房间标题
    func modifyRoomTitleDidClick() {
        navigator(.inputText(name: voiceRoomInfo.roomName ,delegate: self))
    }
    /// 房间通知
    func noticeDidClick() {
        let notice = kvRoomInfo?.extra ?? "欢迎来到\(voiceRoomInfo.roomName)"
        navigator(.notice(modify: true, notice: notice, delegate: self))
    }
    /// 房间背景
    func modifyRoomBackgroundDidClick() {
        navigator(.changeBackground(imagelist: SceneRoomManager.shared.backgroundlist ,delegate: self))
    }
    /// 座位数量
    func lessSeatDidClick(isLess: Bool) {
        roomState.isSeatModeLess = isLess
        guard let kvRoom = kvRoomInfo else {
            return
        }
        if isLess {
            kvRoom.seatCount = 5
        } else {
            kvRoom.seatCount = 9
        }
        kvRoom.isMuteAll = false
        kvRoom.isLockAll = false
        let roomId = voiceRoomInfo.roomId
        RCVoiceRoomEngine.sharedInstance().setRoomInfo(kvRoom) {
            let content = RCChatroomSeats()
            content.count = kvRoom.seatCount - 1
            RCChatroomMessageCenter.sendChatMessage(roomId, content: content) { [weak self] mId in
                self?.messageView.add(content)
            } error: { eCode, mId in }
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: msg)
        }
    }
    
    func forbiddenDidClick() {
        navigator(.forbiddenList(roomId: voiceRoomInfo.roomId))
    }
}

// MARK: - Modify Room type Delegate
extension VoiceRoomViewController: VoiceRoomInputPasswordProtocol {
    func passwordDidEnter(password: String) {
        setRoomType(isPrivate: true, password: password)
    }
    
    func passwordDidVarify(_ room: VoiceRoom) {
    }
}

extension VoiceRoomViewController: ChangeBackgroundImageProtocol {
    func didConfirmImage(urlSuffix: String) {
        NotificationNameRoomBackgroundUpdated.post((voiceRoomInfo.roomId, urlSuffix))
        let api: RCNetworkAPI = .updateRoombackgroundUrl(roomId: voiceRoomInfo.roomId, backgroundUrl: urlSuffix)
        networkProvider.request(api) { result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "更新房间背景成功")
                } else {
                    SVProgressHUD.showError(withStatus: "更新房间背景失败")
                }
            case .failure:
                SVProgressHUD.showError(withStatus: "更新房间背景失败")
            }
        }
        VoiceRoomNotification.backgroundChanged.send(content: urlSuffix)
    }
}

// MARK: - Modify Room Name Delegate
extension VoiceRoomViewController: VoiceRoomInputTextProtocol {
    func textDidInput(text: String) {
        /// 接口合并
        let api: RCNetworkAPI = .setRoomName(roomId: voiceRoomInfo.roomId, name: text)
        networkProvider.request(api) { result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "更新房间名称成功")
                } else {
                    SVProgressHUD.showError(withStatus: "更新房间名称失败")
                }
            case .failure:
                SVProgressHUD.showError(withStatus: "更新房间名称失败")
            }
        }
        
        if let roomInfo = kvRoomInfo {
            roomInfo.roomName = text
            RCVoiceRoomEngine.sharedInstance().setRoomInfo(roomInfo) {
                
            } error: { code, msg in
                
            }
        }
    }
}

//
//  LiveVideoRoomHostController+Settings.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func settings_viewDidLoad() {
        m_viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNoticeDidTap))
        roomNoticeView.addGestureRecognizer(tap)
    }
    
    @objc func handleNoticeDidTap() {
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        navigator(.notice(notice: notice, delegate: self))
    }
    
    @objc func handleSettingClick() {
        var settinglist: [RoomSettingItem] {
            return [
                .lockRoom(room.isPrivate == 1),
                .roomTitle,
                .notice,
                .forbidden,
                .switchCamera,
                .sticker,
                .retouch,
                .makeup,
                .effect,
                .music,
            ]
        }
        navigator(.roomSetting(settinglist, self))
    }
    
    private func setRoomType(isPrivate: Bool, password: String?) {
        let title = isPrivate ? "设置房间密码" : "解锁"
        let api: RCNetworkAPI = .setRoomType(roomId: room.roomId,
                                             isPrivate: isPrivate,
                                             password: password)
        func onSuccess() {
            SVProgressHUD.showSuccess(withStatus: "已\(title)")
            room.isPrivate = isPrivate ? 1 : 0
        }
        func onError() {
            SVProgressHUD.showError(withStatus: title + "失败")
        }
        networkProvider.request(api) { result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    onSuccess()
                } else {
                    onError()
                }
            case .failure: onError()
            }
        }
    }
}

//MARK: - Voice Room Setting Delegate
extension LiveVideoRoomHostController: VoiceRoomSettingProtocol {
    /// 房间上锁&解锁
    func lockRoomDidClick(isLock: Bool) {
        if isLock {
            navigator(.inputPassword(type: .input, delegate: self))
        } else {
            setRoomType(isPrivate: false, password: nil)
        }
    }
    
    /// 房间标题
    func modifyRoomTitleDidClick() {
        navigator(.inputText(name: room.roomName ,delegate: self))
    }
    
    /// 公告
    func noticeDidClick() {
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        navigator(.notice(modify: true, notice: notice, delegate: self))
    }
    
    /// 屏蔽词
    func forbiddenDidClick() {
        navigator(.forbiddenList(roomId: room.roomId))
    }
    
    func switchCameraDidClick() {
        RCRTCEngine.sharedInstance().defaultVideoStream.switchCamera()
        let postion = RCRTCEngine.sharedInstance().defaultVideoStream.cameraPosition
        let needMirror = postion == .captureDeviceFront
        RCRTCEngine.sharedInstance().defaultVideoStream.isEncoderMirror = needMirror
    }
    
    func stickerDidClick() {
        present(sticker, animated: true)
    }
    
    func retouchDidClick() {
        present(retouch, animated: true)
    }
    
    func makeupDidClick() {
        present(makeup, animated: true)
    }
    
    func effectDidClick() {
        present(effect, animated: true)
    }
    
    /// 音乐
    func musicDidClick() {
        present(musicControlVC, animated: true)
    }
}

// MARK: - Modify Room type Delegate
extension LiveVideoRoomHostController: VoiceRoomInputPasswordProtocol {
    func passwordDidEnter(password: String) {
        setRoomType(isPrivate: true, password: password)
    }
}

// MARK: - Modify Room Name Delegate
extension LiveVideoRoomHostController: VoiceRoomInputTextProtocol {
    func textDidInput(text: String) {
        let api: RCNetworkAPI = .setRoomName(roomId: room.roomId, name: text)
        networkProvider.request(api) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    self?.didUpdateRoomName(text)
                    SVProgressHUD.showSuccess(withStatus: "更新房间名称成功")
                } else {
                    SVProgressHUD.showError(withStatus: "更新房间名称失败")
                }
            case .failure:
                SVProgressHUD.showError(withStatus: "更新房间名称失败")
            }
        }
    }
    
    private func didUpdateRoomName(_ name: String) {
        room.roomName = name
        roomInfoView.updateRoom(info: room)
        RCLiveVideoEngine.shared().setRoomInfo(["name": name])
    }
}

extension LiveVideoRoomHostController: VoiceRoomNoticeDelegate {
    func noticeDidModfied(notice: String) {
        /// 本地更新
        room.notice = notice
        /// 本地公屏消息
        messageView.add(RCTextMessage(content: "房间公告已更新")!)
        /// 远端更新
        RCLiveVideoEngine.shared().setRoomInfo(["notice": notice])
    }
}

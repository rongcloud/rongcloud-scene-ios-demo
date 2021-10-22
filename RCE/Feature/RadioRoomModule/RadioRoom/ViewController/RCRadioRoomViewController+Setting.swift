//
//  RCRadioRoomViewController+Setting.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func setting_viewDidLoad() {
        m_viewDidLoad()
        roomToolBarView.add(setting: self, action: #selector(handleSettingClick))
    }
    
    @objc private func handleSettingClick() {
        navigator(.roomSetting(settinglist, self))
    }
    
    var settinglist: [RoomSettingItem] {
        return [
            .lockRoom(roomInfo.isPrivate == 1),
            .roomTitle,
            .notice,
            .roomBackground,
            .forbidden,
            .music,
            .suspend,
        ]
    }
    
    private func setRoomType(isPrivate: Bool, password: String?) {
        let title = isPrivate ? "设置房间密码" : "解锁"
        let api: RCNetworkAPI = .setRoomType(roomId: roomInfo.roomId,
                                             isPrivate: isPrivate,
                                             password: password)
        func onSuccess() {
            SVProgressHUD.showSuccess(withStatus: "已\(title)")
            roomInfo.isPrivate = isPrivate ? 1 : 0
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
extension RCRadioRoomViewController: VoiceRoomSettingProtocol {
    /// 房间上锁&解锁
    func lockRoomDidClick(isLock: Bool) {
        if isLock {
            navigator(.inputPassword(type: .input, delegate: self))
        } else {
            setRoomType(isPrivate: false, password: nil)
        }
    }
    /// 音乐
    func musicDidClick() {
        present(musicControlVC, animated: true, completion: nil)
    }
    /// 房间标题
    func modifyRoomTitleDidClick() {
        navigator(.inputText(name: roomInfo.roomName ,delegate: self))
    }
    /// 房间背景
    func modifyRoomBackgroundDidClick() {
        navigator(.changeBackground(imagelist: SceneRoomManager.shared.backgroundlist ,delegate: self))
    }
    
    func forbiddenDidClick() {
        navigator(.forbiddenList(roomId: roomInfo.roomId))
    }
    
    func noticeDidClick() {
        let notice = roomKVState.notice.count == 0 ? "欢迎来到\(roomKVState.roomName)" : roomKVState.notice
        navigator(.notice(modify: true, notice: notice, delegate: self))
    }
    
    func suspendDidClick() {
        suspend()
    }
}

// MARK: - Modify Room type Delegate
extension RCRadioRoomViewController: VoiceRoomInputPasswordProtocol {
    func passwordDidEnter(password: String) {
        setRoomType(isPrivate: true, password: password)
    }
}

extension RCRadioRoomViewController: ChangeBackgroundImageProtocol {
    func didConfirmImage(urlSuffix: String) {
        roomKVState.update(roomBGName: urlSuffix)
        NotificationNameRoomBackgroundUpdated.post((roomInfo.roomId, urlSuffix))
        let api: RCNetworkAPI = .updateRoombackgroundUrl(roomId: roomInfo.roomId, backgroundUrl: urlSuffix)
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
    }
}

// MARK: - Modify Room Name Delegate
extension RCRadioRoomViewController: VoiceRoomInputTextProtocol {
    func textDidInput(text: String) {
        /// 接口合并
        let api: RCNetworkAPI = .setRoomName(roomId: roomInfo.roomId, name: text)
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
        roomKVState.update(roomName: text)
    }
}

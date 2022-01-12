//
//  LiveVideoRoomHostController+Settings.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD
import UIKit

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
                .videoSetting,
                .isFreeEnterSeat(isSeatFreeEnter)
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
        let items = SceneRoomManager.shared.forbiddenWordlist
        let controller = LiveVideoRoomForbiddenViewController(items, delegate: self)
        present(controller, animated: true)
    }
    
    func switchCameraDidClick() {
        RCRTCEngine.sharedInstance().defaultVideoStream.switchCamera()
        let postion = RCRTCEngine.sharedInstance().defaultVideoStream.cameraPosition
        let needMirror = postion == .captureDeviceFront
        RCRTCEngine.sharedInstance().defaultVideoStream.isEncoderMirror = needMirror
        RCRTCEngine.sharedInstance().defaultVideoStream.isPreviewMirror = needMirror
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
        presentMusicController()
    }
    
    /// 视频设置
    func videoSetItemClick() {
        present(videoPropsSetVc, animated: true)
    }
    func freeMicDidClick(isFree: Bool) {
        isSeatFreeEnter = isFree
        let value: String = isFree ? "1" : "0"
        RCLiveVideoEngine.shared().setRoomInfo(["FreeEnterSeat": value]) { code in
            debugPrint("setRoomInfo \(code.rawValue)")
        }
        if isSeatFreeEnter {
            SVProgressHUD.showSuccess(withStatus: "当前可自由上麦")
        } else {
            SVProgressHUD.showSuccess(withStatus: "当前需申请上麦")
        }
    }
}

extension LiveVideoRoomHostController: VideoPropertiesDelegate {
    func videoPropertiesDidChanged(_ resolutionRatio: ResolutionRatio, fps: Int, bitRate: Int) {
        let config = RCRTCVideoStreamConfig()
        config.videoSizePreset = {
            switch resolutionRatio {
            case .video640X480P:
                return .preset640x480
            case .video720X480P:
                return .preset720x480
            case .video1280X720P:
                return .preset1280x720
            case .video1920X1080P:
                return .preset1920x1080
            }
        }()
        config.videoFps = {
            switch fps {
            case 10: return .FPS10
            case 15: return .FPS15
            case 24: return .FPS24
            case 30: return .FPS30
            default: return .FPS15
            }
        }()
        config.minBitrate = UInt(bitRate / 10 * 7)
        config.maxBitrate = UInt(bitRate)
        RCRTCEngine.sharedInstance().defaultVideoStream.videoConfig = config
        
        let roomInfo: [String: String] = [
            "RCRTCVideoResolution": resolutionRatio.rawValue,
            "RCRTCVideoFps": "\(fps)"
        ]
        RCLiveVideoEngine.shared().setRoomInfo(roomInfo) { _ in }
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
        RCLiveVideoEngine.shared().setRoomInfo(["name": name]) { _ in }
    }
}

extension LiveVideoRoomHostController: VoiceRoomNoticeDelegate {
    func noticeDidModfied(notice: String) {
        /// 本地更新
        room.notice = notice
        /// 远端更新
        RCLiveVideoEngine.shared().setRoomInfo(["notice": notice]) { _ in }
        
        /// 本地公屏消息
        let message = RCTextMessage(content: "房间公告已更新")!
        messageView.addMessage(message)
        RCChatroomMessageCenter.sendChatMessage(room.roomId, content: message) { _ in } error: { _, _ in }
    }
}

extension LiveVideoRoomHostController: LiveVideoRoomForbiddenDelegate {
    func forbiddenListDidChange(_ items: [String]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: items, options: .fragmentsAllowed)
            if let json = String(data: jsonData, encoding: .utf8) {
                RCLiveVideoEngine.shared().setRoomInfo(["shields": json]) { code in
                    debugPrint("setRoomInfo \(code.rawValue)")
                }
            }
        } catch {
            debugPrint("setRoomInfo \(error.localizedDescription)")
        }
    }
}

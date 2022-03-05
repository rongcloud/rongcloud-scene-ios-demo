//
//  LiveVideoRoomHostController+Settings.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD
import RCSceneRoomSetting

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
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        let items: [Item] = {
            return [
                .roomLock(room.isPrivate == 0),
                .roomName(room.roomName),
                .roomNotice(notice),
                .forbidden,
                .cameraSwitch,
                .beautySticker,
                .beautyRetouch,
                .beautyMakeup,
                .beautyEffect,
                .music,
                .cameraSetting,
                .seatFree(!isSeatFreeEnter)
            ]
        }()
        let controller = RCSceneRoomSettingViewController(items: items, delegate: self)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
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

extension LiveVideoRoomHostController: RCSceneRoomSettingProtocol {
    func eventWillTrigger(_ item: Item) -> Bool {
        return false
    }
    
    func eventDidTrigger(_ item: Item, extra: String?) {
        switch item {
        case .roomLock(let lock):
            setRoomType(isPrivate: lock, password: extra)
        case .roomName(let name):
            roomUpdate(name: name)
        case .roomNotice(let notice):
            roomUpdate(notice: notice)
        case .music:
            presentMusicController()
        case .forbidden:
            forbiddenDidClick()
        case .seatFree(let free):
            freeMicDidClick(isFree: free)
        case .cameraSetting:
            present(videoPropsSetVc, animated: true)
        case .cameraSwitch:
            switchCameraDidClick()
        case .beautyRetouch:
            beautyPlugin.didClick(.retouch)
        case .beautySticker:
            beautyPlugin.didClick(.sticker)
        case .beautyMakeup:
            beautyPlugin.didClick(.makeup)
        case .beautyEffect:
            beautyPlugin.didClick(.effect)
        default: ()
        }
    }
}

//MARK: - Voice Room Setting Delegate
extension LiveVideoRoomHostController {
    
    /// 屏蔽词
    func forbiddenDidClick() {
        let items = SceneRoomManager.shared.forbiddenWordlist
        let controller = LiveVideoRoomForbiddenViewController(items, delegate: self)
        present(controller, animated: true)
    }
    
    func switchCameraDidClick() {
//        RCRTCEngine.sharedInstance().defaultVideoStream.switchCamera()
        let position = RCRTCEngine.sharedInstance().defaultVideoStream.cameraPosition
        let needMirror = position == .captureDeviceFront
        RCRTCEngine.sharedInstance().defaultVideoStream.isEncoderMirror = needMirror
        let mirror = RCRTCEngine.sharedInstance().defaultVideoStream.isPreviewMirror;
        RCRTCEngine.sharedInstance().defaultVideoStream.isPreviewMirror = !mirror;
        debugPrint("video stream mirror: \(mirror)")
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

// MARK: - Modify Room Name Delegate
extension LiveVideoRoomHostController {
    func roomUpdate(name: String) {
        let api: RCNetworkAPI = .setRoomName(roomId: room.roomId, name: name)
        networkProvider.request(api) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    self?.didUpdateRoomName(name)
                    SVProgressHUD.showSuccess(withStatus: "更新房间名称成功")
                } else {
                    SVProgressHUD.showError(withStatus: response.msg ?? "更新房间名称失败")
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
    
    func roomUpdate(notice: String) {
        LiveNoticeChecker.check(notice) { pass, msg in
            if (pass) {
                /// 本地更新
                self.room.notice = notice
                /// 远端更新
                RCLiveVideoEngine.shared().setRoomInfo(["notice": notice]) { _ in }
                
                /// 本地公屏消息
                let message = RCTextMessage(content: "房间公告已更新")!
                ChatroomSendMessage(message) { result in
                    switch result {
                    case .success:
                        self.messageView.addMessage(message)
                    case .failure(let error):
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: msg);
            }
        }
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

extension LiveVideoRoomHostController: VoiceRoomNoticeDelegate {
    func noticeDidModified(notice: String) {}
}

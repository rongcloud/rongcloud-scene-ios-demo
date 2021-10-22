//
//  LiveVideoRoomViewController+Audio.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import SVProgressHUD
import RCRTCAudio

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func audio_viewDidLoad() {
        m_viewDidLoad()
        toolBarView.recordButton.recordDidSuccess = { [weak self] in self?.recordDidSuccess($0) }
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onRouteChanged(_:)),
                         name: AVAudioSession.routeChangeNotification,
                         object: nil)
        RCVoiceRoomEngine.sharedInstance().enableSpeaker(true)
    }
    
    private func recordDidSuccess(_ result: (url: URL, time: TimeInterval)?) {
        RCRTCEngine.sharedInstance().defaultAudioStream.setMicrophoneDisable(false)
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
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func sendMessage(_ voice: String, time: UInt, url: URL) {
        let roomId = room.roomId
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

extension LiveVideoRoomViewController {
    @objc private func onRouteChanged(_ notification: Notification) {
        let route = AVAudioSession.sharedInstance().currentRoute
        let isHeadsetPluggedIn = route.outputs.contains { desc in
            switch desc.portType {
            case .bluetoothLE,
                 .bluetoothHFP,
                 .bluetoothA2DP,
                 .headphones:
                return true
            default: return false
            }
        }
        RCVoiceRoomEngine.sharedInstance().enableSpeaker(!isHeadsetPluggedIn)
    }
}

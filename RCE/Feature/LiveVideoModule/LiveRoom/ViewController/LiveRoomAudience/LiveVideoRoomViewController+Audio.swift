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
//        NotificationCenter.default
//            .addObserver(self,
//                         selector: #selector(onRouteChanged(_:)),
//                         name: AVAudioSession.routeChangeNotification,
//                         object: nil)
//        RCVoiceRoomEngine.sharedInstance().enableSpeaker(true)
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

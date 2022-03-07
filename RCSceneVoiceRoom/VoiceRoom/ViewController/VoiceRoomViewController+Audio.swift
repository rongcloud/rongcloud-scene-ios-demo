//
//  VoiceRoomViewController+Audio.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/22.
//

import UIKit

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupLikeModule() {
        setupModules()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onRouteChanged(_:)),
                         name: AVAudioSession.routeChangeNotification,
                         object: nil)
    }
    
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

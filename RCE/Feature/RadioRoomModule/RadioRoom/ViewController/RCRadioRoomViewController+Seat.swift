//
//  RCRadioRoomViewController+Seat.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import UIKit

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func seat_viewDidLoad() {
        m_viewDidLoad()
        RCVoiceRoomEngine.sharedInstance().enableSpeaker(true)
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

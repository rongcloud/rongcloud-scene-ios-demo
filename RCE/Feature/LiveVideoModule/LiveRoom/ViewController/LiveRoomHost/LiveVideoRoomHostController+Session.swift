//
//  LiveVideoRoomHostController+Session.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/9.
//

import UIKit

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func session_viewDidLoad() {
        m_viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillExit),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onRouteChanged(_:)),
                         name: AVAudioSession.routeChangeNotification,
                         object: nil)
        RCVoiceRoomEngine.sharedInstance().enableSpeaker(true)
    }
    
    @objc func appWillExit() {
        let api: RCNetworkAPI = .closeRoom(roomId: room.roomId)
        var id: UIBackgroundTaskIdentifier?
        id = UIApplication.shared.beginBackgroundTask {
            networkProvider.request(api) { _ in
                if let id = id {
                    UIApplication.shared.endBackgroundTask(id)
                }
            }
        }
    }
}

extension LiveVideoRoomHostController {
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

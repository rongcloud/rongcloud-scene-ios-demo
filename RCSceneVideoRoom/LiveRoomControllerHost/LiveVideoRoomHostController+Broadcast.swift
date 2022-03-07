//
//  LiveVideoRoomHostController+Broadcast.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/9.
//

import UIKit
import RCSceneMessage
import RCSceneService
import RCSceneGift

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func broadcast_viewDidLoad() {
        m_viewDidLoad()
        RCBroadcastManager.shared.delegate = self
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func broadcast_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard message.content.isKind(of: RCGiftBroadcastMessage.self) else { return }
        let content = message.content as! RCGiftBroadcastMessage
        RCBroadcastManager.shared.add(content)
    }
}

extension LiveVideoRoomHostController: RCRTCBroadcastDelegate {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(roomUserView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    
    func broadcastViewAccessible(_ room: VoiceRoom) -> Bool {
        return false
    }
    
    func broadcastViewDidClick(_ room: VoiceRoom) {
    }
}


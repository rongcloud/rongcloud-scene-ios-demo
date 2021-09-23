//
//  RCRadioRoomViewController+Broadcast.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/20.
//

import UIKit

extension RCRadioRoomViewController {
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

extension RCRadioRoomViewController: RCRTCBroadcastDelegate {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(roomInfoView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    
    func broadcastViewAccessible(_ room: VoiceRoom) -> Bool {
        return room.roomId != roomInfo.roomId && roomInfo.userId != Environment.currentUserId
    }
    
    func broadcastViewDidClick(_ room: VoiceRoom) {
        (parent as? RCRoomContainerViewController)?.switchRoom(room)
    }
}

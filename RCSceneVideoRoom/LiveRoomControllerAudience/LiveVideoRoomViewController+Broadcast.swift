//
//  LiveVideoRoomViewController+Broadcast.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/9.
//

import UIKit
import RCSceneService
import RCSceneGift
import RCSceneRoomSetting

extension LiveVideoRoomViewController {
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

extension LiveVideoRoomViewController: RCRTCBroadcastDelegate {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(roomUserView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    
    func broadcastViewAccessible(_ room: VoiceRoom) -> Bool {
        if role == .broadcaster { return false }
        if self.room.roomId == room.roomId { return false }
        return true
    }
    
    func broadcastViewDidClick(_ room: VoiceRoom) {
        if room.isPrivate == 1 {
            let controller = VoiceRoomPasswordViewController(type: .verify(room), delegate: self)
            present(controller, animated: true)
        } else {
            roomContainerAction?.switchRoom(room)
        }
    }
}

extension LiveVideoRoomViewController: InputPasswordProtocol {
    func passwordDidVerify(_ room: VoiceRoom) {
        if room.roomId == self.room.roomId { return }
        roomContainerAction?.switchRoom(room)
    }
}

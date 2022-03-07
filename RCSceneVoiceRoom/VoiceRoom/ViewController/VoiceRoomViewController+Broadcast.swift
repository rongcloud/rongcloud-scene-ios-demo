//
//  VoiceRoomViewController+Broadcast.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/20.
//

import UIKit
import RCSceneGift
import RCSceneService
import RCSceneFoundation

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupBroadcastModule() {
        setupModules()
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

extension VoiceRoomViewController: RCRTCBroadcastDelegate {
    
    func broadcastViewAccessible(_ room: VoiceRoom) -> Bool {
        if room.roomId == voiceRoomInfo.roomId { return false }
        if currentUserRole() == .creator { return false }
        if isSitting() { return false }
        return true
    }
    
    func broadcastViewDidClick(_ room: VoiceRoom) {
        if room.isPrivate == 1 {
            let controller = UIApplication.shared.keyWindow()?.rootViewController
            controller?.navigator(.inputPassword(type: .verify(room), delegate: self))
        } else {
            self.roomContainerSwitchRoom(room)
        }
    }
    
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(roomInfoView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    
    func broadcastViewWillAppear(_ view: RCRTCGiftBroadcastView) {
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }
    }
}

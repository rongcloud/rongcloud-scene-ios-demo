//
//  LiveVideoRoomHostController+Gift.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import UIKit

extension LiveVideoRoomHostController {
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func like_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        handleGiftMessage(message.content)
    }
    
    private func handleGiftMessage(_ content: RCMessageContent?) {
        guard
            let message = content as? RCChatroomGift,
            message.targetId == room.userId
            else { return }
        let value = message.price * message.number + roomGiftView.content.intValue
        roomGiftView.update("\(value)")
        RCLiveVideoEngine.shared().setRoomInfo(["gift": "\(value)"])
    }
    
    @objc func handleGiftButtonClick() {
        let seatInfo = RCVoiceSeatInfo()
        seatInfo.userId = room.userId
        seatInfo.isMuted = false
        let dependency = VoiceRoomGiftDependency(room: room,
                                                 seats: [seatInfo],
                                                 userIds: [room.userId])
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
}

extension LiveVideoRoomHostController: VoiceRoomGiftViewControllerDelegate {
    func didSendGift(message: RCMessageContent) {
        messageView.add(message)
        handleGiftMessage(message)
    }
}


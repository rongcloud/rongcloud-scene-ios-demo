//
//  LiveVideoRoomViewController+Gift.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import UIKit

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func gift_viewDidLoad() {
        m_viewDidLoad()
        toolBarView.add(gift: self, action: #selector(handleGiftButtonClick))
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

extension LiveVideoRoomViewController: VoiceRoomGiftViewControllerDelegate {
    func didSendGift(message: RCMessageContent) {
        messageView.add(message)
    }
}

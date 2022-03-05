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
        LiveVideoGiftManager.shared.refresh(room.roomId)
        giftButton.addTarget(self, action: #selector(handleGiftButtonClick), for: .touchUpInside)
        NotificationNameGiftUpdate.addObserver(self, selector: #selector(updateGiftInfo(_:)))
    }
    
    @objc func handleGiftButtonClick() {
        SceneRoomManager.updateLiveSeatList()
        let users: [String] = {
            if RCLiveVideoEngine.shared().pkInfo != nil {
                return [room.userId]
            }
            var users: [String] = SceneRoomManager.shared.seatlist
                .compactMap { $0.userId }
                .filter { $0.count > 0 }
            users.removeAll(where: { $0 == room.userId })
            users.insert(room.userId, at: 0)
            return users
        }()
        let dependency = VoiceRoomGiftDependency(room: room,
                                                 seats: SceneRoomManager.shared.seatlist,
                                                 userIds: users)
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func gift_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        handleGiftMessage(message.content)
    }
    
    @objc private func updateGiftInfo(_ notification: Notification) {
        let count = LiveVideoGiftManager.shared.giftInfo[room.userId] ?? 0
        roomGiftView.update("\(count)")
    }
}

extension LiveVideoRoomViewController: VoiceRoomGiftViewControllerDelegate {
    func didSendGift(message: RCMessageContent) {
        if let msg = message as? RCChatroomSceneMessageProtocol {
            messageView.addMessage(msg)
        }
        handleGiftMessage(message)
    }
    
    private func handleGiftMessage(_ content: RCMessageContent?) {
        if let message = content as? RCChatroomGift {
            let value = message.price * message.number
            LiveVideoGiftManager.shared.updateGift([message.targetId: value])
        } else if let message = content as? RCChatroomGiftAll {
            let value = message.price * message.number
            var items = [String: Int]()
            RCLiveVideoEngine.shared()
                .currentSeats
                .map { $0.userId }
                .filter { $0.count > 0 }
                .forEach { userId in
                    items[userId] = value
                }
            LiveVideoGiftManager.shared.updateGift(items)
        } else {
            return
        }
        
        let count = LiveVideoGiftManager.shared.giftInfo[room.userId]
        roomGiftView.update("\(count ?? 0)")
    }
}

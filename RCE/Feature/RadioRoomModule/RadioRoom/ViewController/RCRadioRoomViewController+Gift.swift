//
//  RCRadioRoomViewController+Gift.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import UIKit

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func gift_viewDidLoad() {
        m_viewDidLoad()
        fetchGiftInfo()
        roomToolBarView.add(gift: self, action: #selector(handleGiftButtonClick))
    }
}

extension RCRadioRoomViewController {
    private func fetchGiftInfo() {
        let api = RCNetworkAPI.giftList(roomId: roomInfo.roomId)
        networkProvider.request(api) { [weak self] result in
            switch result {
            case let .success(value):
                guard
                    let info = try? JSONSerialization
                        .jsonObject(with: value.data, options: .allowFragments),
                    let items = (info as? [String: Any])?["data"] as? [[String: Int]]
                else { return }
                self?.onFetchGiftInfo(items)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func onFetchGiftInfo(_ items: [[String: Int]]) {
        var tmpValues = [String: Int]()
        items.forEach { $0.forEach { key, value in tmpValues[key] = value } }
        roomOwnerView.update(gift: tmpValues[roomInfo.userId] ?? 0)
    }
    
    @objc func handleGiftButtonClick() {
        let seatInfo = RCVoiceSeatInfo()
        seatInfo.userId = roomInfo.userId
        seatInfo.isMuted = roomKVState.mute
        seatInfo.status = roomKVState.seating ? .using : .empty
        let dependency = VoiceRoomGiftDependency(room: roomInfo,
                                                 seats: [seatInfo],
                                                 userIds: [roomInfo.userId])
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func like_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        handleGiftMessage(message.content)
    }
    
    private func handleGiftMessage(_ content: RCMessageContent?) {
        guard
            let message = content as? RCChatroomGift,
            message.targetId == roomInfo.userId
            else { return }
        let value = message.price * message.number + roomOwnerView.giftValue
        roomOwnerView.update(gift: value)
    }
}

extension RCRadioRoomViewController: VoiceRoomGiftViewControllerDelegate {
    func didSendGift(message: RCMessageContent) {
        messageView.add(message)
        handleGiftMessage(message)
        fetchGiftInfo()
    }
}

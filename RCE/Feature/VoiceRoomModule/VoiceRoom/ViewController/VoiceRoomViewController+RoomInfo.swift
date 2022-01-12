//
//  VoiceRoomViewController+RoomInfo.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

import UIKit

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        roomInfoView.delegate = self
    }
    
    @_dynamicReplacement(for: kvRoomInfo)
    private var inner_kvRoomInfo: RCVoiceRoomInfo? {
        get {
            return kvRoomInfo
        }
        set {
            kvRoomInfo = newValue
            if let info = newValue {
                updateRoomInfo(info: info)
            }
        }
    }
    
    private func updateRoomInfo(info: RCVoiceRoomInfo) {
        voiceRoomInfo.roomName = info.roomName
        roomState.isFreeEnterSeat = info.isFreeEnterSeat
        roomState.isLockAll = info.isLockAll
        roomState.isMuteAll = info.isMuteAll
        roomState.isSeatModeLess = (info.seatCount < 9)
        roomInfoView.updateRoom(info: voiceRoomInfo)
    }
}

extension VoiceRoomViewController: RoomInfoViewClickProtocol {
    func didFollowRoomUser(_ follow: Bool) {
        let roomId = voiceRoomInfo.roomId
        UserInfoDownloaded.shared.refreshUserInfo(userId: voiceRoomInfo.userId) { followUser in
            guard follow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                self?.messageView.add(message)
                RCChatroomMessageCenter.sendChatMessage(roomId, content: message) { mId in
                    print("send message seccuss: \(mId)")
                } error: { eCode, mId in
                    print("send message fail: \(mId), code: \(eCode.rawValue)")
                }
                
            }
        }
    }
    
    func roomInfoDidClick() {
        let dependency = VoiceRoomUserOperationDependency(room: voiceRoomInfo,
                                              presentUserId: "")
        navigator(.userlist(dependency: dependency, delegate: self))
    }
}

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
    func roomInfoDidClick() {
        let dependency = ManageUserDependency(roomId: voiceRoomInfo.roomId,
                                              roomCreator: voiceRoomInfo.userId,
                                              presentUserId: "")
        navigator(.userlist(dependency: dependency, delegate: self))
    }
}

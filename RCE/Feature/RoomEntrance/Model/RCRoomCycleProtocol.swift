//
//  RCRoomCycleProtocol.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/24.
//

import Foundation

import RCSceneRoom
import RCSceneRadioRoom
import RCSceneVideoRoom
import RCSceneVoiceRoom
import RCSceneGameRoom

extension RCSceneRoom {
    func controller(_ isCreate: Bool = false) -> RCRoomCycleProtocol {
        if self.gameResp != nil {
            return RCGameRoomController(room: self, creation: isCreate)
        }
        switch roomType {
        case 1:
            return RCVoiceRoomController(room: self, creation: isCreate)
        case 2:
            return RCRadioRoomController(room: self, creation: isCreate)
        case 3:
            return RCVideoRoomController(room: self, beautyPlugin: RCBeautyPlugin())
        default:
            return RCVoiceRoomController(room: self, creation: isCreate)
        }
    }
}


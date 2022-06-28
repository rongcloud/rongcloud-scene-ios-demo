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


extension RCSceneRoom {
    func controller(_ isCreate: Bool = false) -> RCRoomCycleProtocol {
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

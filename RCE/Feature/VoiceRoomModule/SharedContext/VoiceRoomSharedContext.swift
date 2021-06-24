//
//  VoiceRoomSeatInfoManager.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/11.
//

import Foundation

class VoiceRoomSharedContext {
    static let shared = VoiceRoomSharedContext()

    var seatlist = [RCVoiceSeatInfo]()
    var managerlist = [String]()
    var backgroundlist = [String]()
}

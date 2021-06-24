//
//  VoiceRoomState.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/4.
//

import Foundation

struct VoiceRoomState: Codable {
    let roomId: String
    var applyOnMic: Bool
    var applyAllLockMic: Bool
    var applyAllLockSeat: Bool
    var setMute: Bool
    var setSeatNumber: Int
}

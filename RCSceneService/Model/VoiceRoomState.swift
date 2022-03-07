//
//  VoiceRoomState.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/4.
//

import Foundation

public struct VoiceRoomState: Codable {
    public let roomId: String
    public var applyOnMic: Bool
    public var applyAllLockMic: Bool
    public var applyAllLockSeat: Bool
    public var setMute: Bool
    public var setSeatNumber: Int
}

//
//  RCSceneRoomSeat.swift
//  RCSceneService
//
//  Created by shaoshuai on 2022/2/28.
//

import Foundation

public struct RCSceneRoomSeat {
    public let userId: String?
    public let extra: String?
    public let mute: Bool
    
    public init(userId: String?, extra: String?, mute: Bool) {
        self.userId = userId
        self.extra = extra
        self.mute = mute
    }
}

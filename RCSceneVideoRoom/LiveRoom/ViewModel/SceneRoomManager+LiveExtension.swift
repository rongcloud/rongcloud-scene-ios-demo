//
//  SceneRoomManager+LiveExtension.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/8.
//

import RCSceneModular

extension SceneRoomManager {
    static func updateLiveSeatList() {
        shared.seatlist = RCLiveVideoEngine
            .shared()
            .currentSeats
            .map { $0.userId }
    }
}

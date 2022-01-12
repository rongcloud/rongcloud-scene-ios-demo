//
//  SceneRoomManager+LiveExtension.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/8.
//

import Foundation

extension SceneRoomManager {
    static func updateLiveSeatList() {
        shared.seatlist = RCLiveVideoEngine.shared().currentSeats
            .map { item in
                let seat = RCVoiceSeatInfo()
                seat.userId = item.userId
                return seat
            }
    }
}

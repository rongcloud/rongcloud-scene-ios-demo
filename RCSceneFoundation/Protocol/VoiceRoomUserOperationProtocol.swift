//
//  UserOperationProtocol.swift
//  RCSceneFoundation
//
//  Created by xuefeng on 2022/2/22.
//

import Foundation

public protocol UserOperationProtocol: AnyObject {
    func kickUserOffSeat(seatIndex: UInt)
    func lockSeatDidClick(isLock: Bool, seatIndex: UInt)
    func muteSeat(isMute: Bool, seatIndex: UInt)
    func kickoutRoom(userId: String)
    func didSetManager(userId: String, isManager: Bool)
    func didClickedPrivateChat(userId: String)
    func didClickedSendGift(userId: String)
    func didClickedInvite(userId: String)
    func didFollow(userId: String, isFollow: Bool)
}

public extension UserOperationProtocol {
    func kickUserOffSeat(seatIndex: UInt) {}
    func lockSeatDidClick(isLock: Bool, seatIndex: UInt) {}
    func muteSeat(isMute: Bool, seatIndex: UInt) {}
    func kickoutRoom(userId: String) {}
    func didSetManager(userId: String, isManager: Bool) {}
    func didClickedPrivateChat(userId: String) {}
    func didClickedSendGift(userId: String) {}
    func didClickedInvite(userId: String) {}
    func didFollow(userId: String, isFollow: Bool) {}
}

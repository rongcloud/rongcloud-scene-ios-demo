//
//  RCRoomCycleProtocol.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/24.
//

import Foundation

protocol RCRoomCycleProtocol where Self: UIViewController {
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void)
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void)
    func descendantViews() -> [UIView]
}

extension RCRoomCycleProtocol {
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {}
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {}
    func descendantViews() -> [UIView] { [] }
}

extension VoiceRoom {
    func controller(_ isCreate: Bool = false) -> RCRoomCycleProtocol {
        switch roomType {
        case 1: return VoiceRoomViewController(roomInfo: self, isCreate: isCreate)
        case 2: return RCRadioRoomViewController(self, isCreate: isCreate)
        case 3:
            if isOwner {
                return LiveVideoRoomHostController(self)
            } else {
                return LiveVideoRoomViewController(self)
            }
        default: return VoiceRoomViewController(roomInfo: self, isCreate: isCreate)
        }
    }
}

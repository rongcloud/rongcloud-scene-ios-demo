//
//  RCSceneRadioRoom.swift
//  RCSceneRadioRoom
//
//  Created by shaoshuai on 2022/2/27.
//

import UIKit
import XCoordinator
import RCSceneModular
import RCSceneService


public func RCRadioRoomController(room: VoiceRoom, creation: Bool = false) -> RCRoomCycleProtocol {
    let controller = RCRadioRoomViewController(room, isCreate: creation)
    return controller
}

extension RCRadioRoomViewController: RCRoomCycleProtocol {
    func setRoomContainerAction(action: RCRoomContainerAction) {
        self.roomContainerAction = action
    }
    
    func setRoomFloatingAction(action: RCSceneRoomFloatingProtocol) {
        self.floatingManager = action
    }
    
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        self.radioJoinRoom(completion)
    }
    
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        self.radioLeaveRoom(completion)
    }
    
    func descendantViews() -> [UIView] {
        return self.radioDescendantViews()
    }
}

//
//  RCSceneVoiceRoom.swift
//  RCSceneVoiceRoom
//
//  Created by shaoshuai on 2022/2/26.
//

import UIKit
import XCoordinator
import RCSceneModular

//import RCSceneChat
//
//public enum VoiceRoomRouter: Route {
//    case initial
//    case messageList
//    case back
//}
//
//public class VoiceRoomCoordinator: NavigationCoordinator<VoiceRoomRouter> {
//    override func prepareTransition(for route: VoiceRoomRouter) -> NavigationTransition {
//        switch route {
//        case .initial:
//            let vc = RCRoomEntranceViewController(router: unownedRouter)
//            vc.hidesBottomBarWhenPushed = true
//            return .push(vc)
//        case .back:
//            return .pop()
//        case .messageList:
//            let vc = ChatListViewController(displayConversationTypes: [RCConversationType.ConversationType_PRIVATE.rawValue], collectionConversationType: [])
//            return .push(vc!)
//        }
//    }
//}

//init(roomInfo: VoiceRoom, isCreate: Bool = false, floatingManager: RCSceneRoomFloatingProtocol?)

public func RCVoiceRoomController(room: VoiceRoom, creation: Bool = false) -> RCRoomCycleProtocol {
    return VoiceRoomViewController(roomInfo: room,
                                   isCreate: creation)
}

extension VoiceRoomViewController: RCRoomCycleProtocol {
    func setRoomContainerAction(action: RCRoomContainerAction) {
        self.roomContainerAction = action
    }
    
    func setRoomFloatingAction(action: RCSceneRoomFloatingProtocol) {
        self.floatingManager = action
    }
    
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        SceneRoomManager.shared.voice_join(voiceRoomInfo.roomId, complation: completion)
    }
    
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        SceneRoomManager.shared.voice_leave(completion)
    }
    
    func descendantViews() -> [UIView] {
        return [messageView.tableView]
    }
}


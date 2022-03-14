//
//  VoiceRoomCoordinator.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/1/28.
//

import Foundation
import XCoordinator
import RCSceneRadioRoom
import RCSceneVideoRoom
import RCSceneChat

enum RCSeneRoomEntranceRoute: Route {
    case initial
    case chatList
    case chat(userId: String)
    case back
    case inputPassword(type: PasswordViewType, delegate: InputPasswordProtocol?)
    case createRoom(imagelist: [String], onRoomCreate: ((CreateVoiceRoomWrapper) -> Void))
}

class RCSeneRoomEntranceCoordinator: NavigationCoordinator<RCSeneRoomEntranceRoute> {
    
    init(rootViewController: UINavigationController) {
        super.init(rootViewController: rootViewController, initialRoute: nil)
        addChild(RadioRoomCoordinator(rootViewController: rootViewController))
        addChild(VideoRoomCoordinator(rootViewController: rootViewController))
    }
    
    override func prepareTransition(for route: RCSeneRoomEntranceRoute) -> NavigationTransition {
        switch route {
        case .initial:
            let vc = RCRoomEntranceViewController(router: self.unownedRouter)
            vc.hidesBottomBarWhenPushed = true
            return .push(vc)
        case .chatList:
            let vc = ChatListViewController(.ConversationType_PRIVATE)
            vc.canCallComing = false
            return .push(vc)
        case let .chat(userId):
            let vc = ChatViewController(.ConversationType_PRIVATE, userId: userId)
            vc.canCallComing = false
            return .push(vc)
        case .back:
            return .pop()
        case let .inputPassword(type, delegate):
            let vc = VoiceRoomPasswordViewController(type: type, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case let .createRoom(imagelist,onRoomCreate):
            let vc = CreateVoiceRoomViewController(imagelist: imagelist)
            vc.onRoomCreated = onRoomCreate
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return .present(vc)
        }
    }
}
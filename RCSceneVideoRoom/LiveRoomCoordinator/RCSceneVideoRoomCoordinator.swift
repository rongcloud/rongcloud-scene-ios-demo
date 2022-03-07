//
//  RCSceneVideoRoomCoordinator.swift
//  RCSceneVideoRoom
//
//  Created by xuefeng on 2022/2/22.
//

import UIKit
import XCoordinator

import RCSceneGift
import RCSceneChat
import RCSceneService
import RCSceneModular
import RCSceneFoundation
import RCSceneRoomSetting

public var videoRouter: StrongRouter<VideoRoomRouter>!

public enum VideoRoomRouter: Route {
    case inputPassword(delegate: RCSceneRoomSettingProtocol?)
    case notice(modify: Bool = false, notice: String, delegate: RCSceneRoomSettingProtocol)
    case userList(room: VoiceRoom, delegate: UserOperationProtocol)
    case manageUser(dependency: Any?, delegate: UserOperationProtocol?)
    case gift(dependency: VoiceRoomGiftDependency, delegate: VoiceRoomGiftViewControllerDelegate)
    case chatList
    case chat(userId: String)
}

public class VideoRoomCoordinator: NavigationCoordinator<VideoRoomRouter> {
    
    public init(rootViewController: UINavigationController) {
        super.init(rootViewController: rootViewController)
        videoRouter = strongRouter
    }
    
    public override func prepareTransition(for route: VideoRoomRouter) -> NavigationTransition {
        switch route {
        case let .inputPassword(delegate):
            let vc = PasswordViewController(delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case let .userList(room, delegate):
            let vc = SceneRoomUserListViewController(room: room, delegate: delegate)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            nav.modalTransitionStyle = .coverVertical
            nav.modalPresentationStyle = .overFullScreen
            return .present(nav)
        case let .manageUser(dependency, delegate):
            let vc = UserOperationViewController(dependency: dependency as! UserOperationDependency, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return .present(vc)
        case let .gift(dependency, delegate):
            let vc = VoiceRoomGiftViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case .chatList:
            let vc = ChatListViewController(.ConversationType_PRIVATE)
            vc.canCallComing = false
            return .show(vc)
        case let .chat(userId):
            let vc = ChatViewController(.ConversationType_PRIVATE, userId: userId)
            vc.canCallComing = false
            return .show(vc)
        case .notice(modify: let modify, notice: let notice, delegate: let delegate):
            let vc = NoticeViewController(modify, notice: notice, delegate: delegate)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.hidesBottomBarWhenPushed = true
            return .present(vc)
        }
    }
}

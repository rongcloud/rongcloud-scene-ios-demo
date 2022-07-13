//
//  HomeCoordinator.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/1.
//

import UIKit
import XCoordinator
import RCSceneCall
import MapKit

enum HomeRouter: Route {
    case home
    case roomEntrance(RCScene)
    case call(RCScene)
    case chatList
}

extension RCScene {
    func trigger(_ router: UnownedRouter<HomeRouter>) {
        switch self {
        case .audioRoom, .liveVideo, .radioRoom:
            router.trigger(.roomEntrance(self))
            
        case .audioCall, .videoCall:
            enterCallIfAvailable(self, router: router)
        case .musicKTV:
            SVProgressHUD.showInfo(withStatus: "新功能打磨中...")
        case .gameRoom:
            SVProgressHUD.showInfo(withStatus: "游戏待加入")
        default: ()
        }
    }
    
    private func enterCallIfAvailable(_ item: RCScene, router: UnownedRouter<HomeRouter>) {
        guard RCRoomFloatingManager.shared.controller == nil else {
            return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
        }
        router.trigger(.call(item))
    }
}

class HomeCoordinator: NavigationCoordinator<HomeRouter> {
    private lazy var entranceCoordinator: RCSeneRoomEntranceCoordinator = {
        let coordinator = RCSeneRoomEntranceCoordinator(rootViewController: rootViewController)
        addChild(coordinator)
        return coordinator
    }()
    
    private lazy var callRoomCoordinator: CallRoomCoordinator = {
        let coordinator = CallRoomCoordinator(rootViewController: rootViewController)
        addChild(coordinator)
        return coordinator
    }()
    
    init() {
        super.init(initialRoute: .home)
        rootViewController.view.backgroundColor = UIColor(red: 0.192, green: 0.192, blue: 0.192, alpha: 1)
    }
    
    override func prepareTransition(for route: HomeRouter) -> NavigationTransition {
        switch route {
        case .home:
            return .push(HomeViewController(router: unownedRouter))
        case let .roomEntrance(fromHomeItem):
            return .trigger(.initial(fromHomeItem), on: entranceCoordinator)
        case let .call(fromHomeItem):
            let callType: CallType = fromHomeItem == .videoCall ? .video : .audio
            return .trigger(.initial(type: callType), on: callRoomCoordinator)
        case .chatList:
            let vc = ChatListViewController(.ConversationType_PRIVATE)
            vc.hidesBottomBarWhenPushed = true
            return .push(vc)
        }
    }
}

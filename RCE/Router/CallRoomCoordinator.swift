//
//  CallRoomCoordinator.swift
//  RCE
//
//  Created by xuefeng on 2022/2/23.
//

import Foundation
import XCoordinator
import RCSceneCall

enum CallRoomRouter: Route {
    case initial(type: CallType)
    case feedback
}

class CallRoomCoordinator: NavigationCoordinator<CallRoomRouter> {
    
    override init(rootViewController: NavigationCoordinator<CallRoomRouter>.RootViewController = .init(), initialRoute: CallRoomRouter? = nil) {
        super.init(rootViewController: rootViewController, initialRoute: initialRoute)
        callRouter = CallRoomRouterImplementation(router: unownedRouter)
    }
    
    override func prepareTransition(for route: CallRoomRouter) -> NavigationTransition {
        switch route {
        case let .initial(type):
            let vc = DialViewController(type: type)
            vc.hidesBottomBarWhenPushed = true
            return .push(vc)
        case .feedback:
            let vc = FeelingFeedbackViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        }
    
    }
}

class CallRoomRouterImplementation: RCSceneCallRoomRouterProtocol {
    
    private var router: UnownedRouter<CallRoomRouter>?
    
    init(router: UnownedRouter<CallRoomRouter>) {
        self.router = router
    }
    
    func feedback() {
        self.router?.trigger(.feedback)
    }
}


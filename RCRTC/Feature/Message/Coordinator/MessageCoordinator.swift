//
//  MessageCoordinator.swift
//  RCE
//
//  Created by dev on 2022/5/19.
//

import XCoordinator


enum MessageRoute: Route {
    case message
}

class MessageCoordinator: NavigationCoordinator<MessageRoute> {
    public var navigationController: RCENavigationController
    init() {
        self.navigationController = RCENavigationController()
        super.init(rootViewController: navigationController, initialRoute: .message)
//        super.init(initialRoute: .message)
    }
    
    override func prepareTransition(for route: MessageRoute) -> NavigationTransition {
        switch route {
        case .message:
            return .push(RCEMsgListVC())
        }
    }
}

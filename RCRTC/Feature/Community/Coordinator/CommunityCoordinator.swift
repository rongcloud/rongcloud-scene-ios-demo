//
//  CommunityCoordinator.swift
//  RCE
//
//  Created by dev on 2022/5/19.
//

import XCoordinator
import RCSceneCommunity
import RCSceneRoom


enum CommunityRoute: Route {
    case community
}

class CommunityCoordinator: NavigationCoordinator<CommunityRoute> {
    public var navigationController: RCENavigationController
    init() {
        self.navigationController = RCENavigationController()
        super.init(rootViewController: navigationController, initialRoute: .community)
//        super.init(initialRoute: .community)
    }
  
    override func prepareTransition(for route: CommunityRoute) -> NavigationTransition {
        switch route {
        case .community:
            return .push(RCECommunityVC())
        }
    }
}

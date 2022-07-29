//
//  DiscoverNewCoordinator.swift
//  RCE
//
//  Created by dev on 2022/5/19.
//

import XCoordinator
import RCSceneCommunity

enum DiscoverNewRoute: Route {
    case discoverNew
}

class DiscoverNewCoordinator: NavigationCoordinator<DiscoverNewRoute> {
    public var navigationController: RCENavigationController
    init() {
        self.navigationController = RCENavigationController()
        super.init(rootViewController: navigationController, initialRoute: .discoverNew)
//        super.init(initialRoute: .discoverNew)
        rootViewController.view.backgroundColor = .white
    }
    
    override func prepareTransition(for route: DiscoverNewRoute) -> NavigationTransition {
        switch route {
        case .discoverNew:
            return .push(RCSCDiscoverViewController())
        }
    }
}

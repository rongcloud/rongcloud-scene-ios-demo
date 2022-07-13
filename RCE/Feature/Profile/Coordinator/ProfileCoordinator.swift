//
//  ProfileCoordinator.swift
//  RCE
//
//  Created by dev on 2022/5/19.
//


import XCoordinator
import RCSceneCommunity

enum ProfileRoute: Route {
    case profile
}

class ProfileCoordinator: NavigationCoordinator<ProfileRoute> {
    public var navigationController: RCENavigationController
    init() {
        self.navigationController = RCENavigationController()
        super.init(rootViewController: navigationController, initialRoute: .profile)
//        super.init(initialRoute: .profile)
    }
    
    override func prepareTransition(for route: ProfileRoute) -> NavigationTransition {
        switch route {
        case .profile:
            return .push(RCEProfileVC())
        }
    }
}

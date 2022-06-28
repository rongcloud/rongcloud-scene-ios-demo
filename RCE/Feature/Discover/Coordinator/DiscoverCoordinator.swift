//
//  DiscoverCoordinator.swift
//  RCE
//
//  Created by shaoshuai on 2022/2/22.
//

import XCoordinator

enum DiscoverRoute: Route {
    case discover
}

class DiscoverCoordinator: NavigationCoordinator<DiscoverRoute> {
    init() {
        super.init(initialRoute: .discover)
        rootViewController.view.backgroundColor = .white
    }
    
    override func prepareTransition(for route: DiscoverRoute) -> NavigationTransition {
        switch route {
        case .discover:
            return .push(DiscoverViewController())
        }
    }
}

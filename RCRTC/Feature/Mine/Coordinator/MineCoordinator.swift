//
//  MineCoordinator.swift
//  RCE
//
//  Created by shaoshuai on 2022/2/22.
//

import XCoordinator

enum MineRoute: Route {
    case mine
}

class MineCoordinator: NavigationCoordinator<MineRoute> {
    init() {
        super.init(initialRoute: .mine)
    }
    
    override func prepareTransition(for route: MineRoute) -> NavigationTransition {
        switch route {
        case .mine:
            return .push(MineViewController())
        }
    }
}

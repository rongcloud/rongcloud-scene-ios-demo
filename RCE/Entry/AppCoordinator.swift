//
//  AppCoordinator.swift
//  RCE
//
//  Created by shaoshuai on 2022/2/21.
//

import XCoordinator

enum AppRouter: Route {
    case home
    case discover
    case mine
}

class AppCoordinator: TabBarCoordinator<AppRouter> {
    private let home = HomeCoordinator()
    private let discover = DiscoverCoordinator()
    private let mine = MineCoordinator()
    init() {
        home.viewController.tabBarItem = UITabBarItem(title: "首页", image: R.image.tab_bar_home(), tag: 0)
        discover.viewController.tabBarItem = UITabBarItem(title: "发现", image: R.image.tab_bar_discover(), tag: 1)
        mine.viewController.tabBarItem = UITabBarItem(title: "我的", image: R.image.tab_bar_mine(), tag: 2)
        super.init(tabs:[home, discover, mine], select: home)
        rootViewController.tabBar.isTranslucent = false
        rootViewController.tabBar.barTintColor = .white
        rootViewController.tabBar.backgroundColor = .white
    }
    
    override func prepareTransition(for route: AppRouter) -> TabBarTransition {
        switch route {
        case .home:
            return .trigger(.home, on: home)
        case .discover:
            return .trigger(.discover, on: discover)
        case .mine:
            return .trigger(.mine, on: mine)
        }
    }
}

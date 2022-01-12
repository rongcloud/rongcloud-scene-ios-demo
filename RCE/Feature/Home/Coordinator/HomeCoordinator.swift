//
//  HomeCoordinator.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/1.
//

import Foundation
import XCoordinator

enum HomeRouter: Route {
    case home
    case voiceRoom
    case videoCall
    case audioCall
    case radioRoom
    case liveVideo
    case promotionDetail
}

class HomeCoordinator: NavigationCoordinator<HomeRouter> {
    init() {
        super.init(initialRoute: .home)
    }
    
    override func prepareTransition(for route: HomeRouter) -> NavigationTransition {
        switch route {
        case .home:
            let vc = HomeViewController(router: unownedRouter)
            return .push(vc)
        case .voiceRoom:
            let vc = RCRoomEntraceViewController()
            return .push(vc)
        case .videoCall:
            let vc = DialViewController(type: .video)
            return .push(vc)
        case .audioCall:
            let vc = DialViewController(type: .audio)
            return .push(vc)
        case .radioRoom:
            let vc = RCRoomEntraceViewController()
            return .push(vc)
        case .liveVideo:
            let vc = RCRoomEntraceViewController()
            return .push(vc)
        case .promotionDetail:
            let vc = UINavigationController(rootViewController: PromotionDetailViewController())
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc, animation: nil)
        }
    }
}

//
//  RCRouter.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import RCSceneFoundation

enum RCNavigation: Navigation {
    case giftCount(sendView: VoiceRoomGiftSendView)
}

struct RCAppNavigation: AppNavigation {
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController) {
        if let router = navigation as? RCNavigation {
            switch router {
            case .giftCount:
                from.present(to, animated: true, completion: nil)
            }
        }
    }
    
    func viewControllerForNavigation(navigation: Navigation) -> UIViewController {
        guard let router = navigation as? RCNavigation else {
            return UIViewController()
        }
        switch router {
        case let .giftCount(sendView):
            let vc = VoiceRoomGiftCountViewController(sendView)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
    }
}

extension UIViewController {
    @discardableResult
    func navigator(_ navigation: RCNavigation) -> UIViewController {
        return navigate(navigation as Navigation)
    }
}

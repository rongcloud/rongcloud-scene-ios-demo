//
//  RCENavigationController.swift
//  RCE
//
//  Created by dev on 2022/5/20.
//

import UIKit
import ReactorKit

class RCENavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}

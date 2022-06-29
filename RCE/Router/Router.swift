//
//  Router.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit

class Router {
    static let `default`:IsRouter = DefaultRouter()
}

protocol Navigation { }

protocol AppNavigation {
    func viewControllerForNavigation(navigation: Navigation) -> UIViewController
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController)
}

protocol IsRouter {
    func setupAppNavigation(appNavigation: AppNavigation)
    func navigate(_ navigation: Navigation, from: UIViewController) -> UIViewController
    func didNavigate(block: @escaping (Navigation) -> Void)
    var appNavigation: AppNavigation? { get }
}

extension UIViewController {
    func navigate(_ navigation: Navigation) -> UIViewController {
        return Router.default.navigate(navigation, from: self)
    }
}

class DefaultRouter: IsRouter {
    
    var appNavigation: AppNavigation?
    var didNavigateBlocks = [((Navigation) -> Void)] ()
    
    func setupAppNavigation(appNavigation: AppNavigation) {
        self.appNavigation = appNavigation
    }
    
    @discardableResult func navigate(_ navigation: Navigation, from: UIViewController) -> UIViewController {
        guard let toVC = appNavigation?.viewControllerForNavigation(navigation: navigation) else {
            fatalError("Init ViewController failed")
        }
        appNavigation?.navigate(navigation, from: from, to: toVC)
        for b in didNavigateBlocks {
            b(navigation)
        }
        return toVC
    }
    
    func didNavigate(block: @escaping (Navigation) -> Void) {
        didNavigateBlocks.append(block)
    }
}

// Injection helper
protocol Initializable { init() }
class RuntimeInjectable: NSObject, Initializable {
    required override init() {}
}

func appNavigationFromString(_ appNavigationClassString: String) -> AppNavigation {
    let appNavClass = NSClassFromString(appNavigationClassString) as! RuntimeInjectable.Type
    let appNav = appNavClass.init()
    return appNav as! AppNavigation
}

//
//  Router.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import Foundation
import UIKit

public class Router {
    public static let `default`:IsRouter = DefaultRouter()
}

public protocol Navigation { }

public protocol AppNavigation {
    func viewcontrollerForNavigation(navigation: Navigation) -> UIViewController
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController)
}

public protocol IsRouter {
    func setupAppNavigation(appNavigation: AppNavigation)
    func navigate(_ navigation: Navigation, from: UIViewController) -> UIViewController
    func didNavigate(block: @escaping (Navigation) -> Void)
    var appNavigation: AppNavigation? { get }
}

public extension UIViewController {
    func navigate(_ navigation: Navigation) -> UIViewController {
        return Router.default.navigate(navigation, from: self)
    }
}

public class DefaultRouter: IsRouter {
    
    public var appNavigation: AppNavigation?
    var didNavigateBlocks = [((Navigation) -> Void)] ()
    
    public func setupAppNavigation(appNavigation: AppNavigation) {
        self.appNavigation = appNavigation
    }
    
    @discardableResult public func navigate(_ navigation: Navigation, from: UIViewController) -> UIViewController {
        guard let toVC = appNavigation?.viewcontrollerForNavigation(navigation: navigation) else {
            fatalError("Init ViewController failed")
        }
        appNavigation?.navigate(navigation, from: from, to: toVC)
        for b in didNavigateBlocks {
            b(navigation)
        }
        return toVC
    }
    
    public func didNavigate(block: @escaping (Navigation) -> Void) {
        didNavigateBlocks.append(block)
    }
}

// Injection helper
public protocol Initializable { init() }
open class RuntimeInjectable: NSObject, Initializable {
    public required override init() {}
}

public func appNavigationFromString(_ appNavigationClassString: String) -> AppNavigation {
    let appNavClass = NSClassFromString(appNavigationClassString) as! RuntimeInjectable.Type
    let appNav = appNavClass.init()
    return appNav as! AppNavigation
}

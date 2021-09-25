import Foundation
import UIKit

extension UIViewController {
    func dismissCurrentPresent(completion: @escaping (() -> Void)) {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: {
            completion()
        })
    }
    
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    @objc func dismissCurrent() {
        dismiss(animated: true, completion: nil)
    }
    
    func currentVisableViewController() -> UIViewController? {
        if isKind(of: UINavigationController.self) {
            return (self as! UINavigationController).visibleViewController?.currentVisableViewController()
        }
        if isKind(of: UITabBarController.self) {
            return (self as! UITabBarController).selectedViewController?.currentVisableViewController()
        }
        return self
    }
    
    
    func safe_presentViewController(vc: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: animated) {
                [weak self] in
                self?.present(vc, animated: animated, completion: completion)
            }
        } else {
            present(vc, animated: animated, completion: completion)
        }
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return windows.first { $0.isKeyWindow }?.rootViewController?.topMostViewController()
    }
    
    func keyWindow() -> UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}

extension UINavigationController {
    func safe_popToViewController(animated: Bool) {
        if let presented = presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.safe_popToViewController(animated: animated)
            }
            return
        }
        popViewController(animated: animated)
    }
}

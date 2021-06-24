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
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return windows.first { $0.isKeyWindow }?.rootViewController?.topMostViewController()
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

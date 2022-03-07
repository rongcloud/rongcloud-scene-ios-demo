import Foundation
import UIKit

public extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return windows.first { $0.isKeyWindow }?.rootViewController?.topMostViewController()
    }
    
    func keyWindow() -> UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}


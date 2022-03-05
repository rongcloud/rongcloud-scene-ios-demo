//
//  UIView+Extension.swift
//  RCSceneRoomSettingKit
//
//  Created by shaoshuai on 2022/1/26.
//

import UIKit

extension UIView {
    static func autoSize() -> CGSize {
        let instance = self.init()
        return instance.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

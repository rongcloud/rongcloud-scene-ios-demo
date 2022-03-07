//
//  UIView+Extension.swift
//  RCSceneModular
//
//  Created by shaoshuai on 2022/2/26.
//

import UIKit

extension UIView {
    public func popMenuClip(corners: UIRectCorner, cornerRadius: CGFloat, centerCircleRadius: CGFloat) {
        let roundCornerBounds = CGRect(x: 0, y: centerCircleRadius, width: bounds.size.width, height: bounds.size.height - centerCircleRadius)
        let path = UIBezierPath(roundedRect: roundCornerBounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: (bounds.size.width/2) - centerCircleRadius, y: 0, width: centerCircleRadius * 2, height: centerCircleRadius * 2))
        path.append(ovalPath)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

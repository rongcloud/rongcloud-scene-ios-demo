//
//  UIView+Extension.swift
//  RCSceneRoomSettingKit
//
//  Created by shaoshuai on 2022/1/26.
//

import UIKit

public extension UIView {
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

/// MUST: UIViewController.UIView
public extension UIView {
    var controller: UIViewController? {
        var tmp = next
        while let responder = tmp {
            if responder.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
            tmp = tmp?.next
        }
        return UIApplication.shared.keyWindow()?.rootViewController
    }
    
    func enableTapEndEditing(_ index: Int = 0) {
        let tapView = UIView(frame: bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(tapView, at: index)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onEndEditingTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    func enableTapEndEditing(above view: UIView) {
        let tapView = UIView(frame: bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(tapView, aboveSubview: view)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onEndEditingTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    func enableTapEndEditing(below view: UIView) {
        let tapView = UIView(frame: bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(tapView, belowSubview: view)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onEndEditingTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    @objc private func onEndEditingTap() {
        endEditing(true)
    }
}

//
//  UIView+SelfSizing.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/7.
//

import Foundation

extension UIView {
    static func autoSize() -> CGSize {
        let instance = self.init()
        return instance.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

extension UIView {
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
}

/// MUST: UIViewController.UIView
extension UIView {
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

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

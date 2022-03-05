//
//  UIViewController+Extension.swift
//  RCSceneRoomSettingKit
//
//  Created by shaoshuai on 2022/1/26.
//

import UIKit

extension UIViewController {
    func enableClickingDismiss(_ index: Int = 0) {
        let tapView = UIView(frame: view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(tapView, at: index)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickingDismissTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    func enableClickingDismiss(above view: UIView) {
        let tapView = UIView(frame: self.view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(tapView, aboveSubview: view)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickingDismissTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    func enableClickingDismiss(below view: UIView) {
        let tapView = UIView(frame: self.view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(tapView, belowSubview: view)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickingDismissTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    @objc private func onClickingDismissTap() {
        dismiss(animated: true)
    }
}

//
//  RCTapGestureView.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/8.
//

import UIKit

final class RCTapGestureView: UIView {
    
    private weak var controller: UIViewController?

    init(_ controller: UIViewController) {
        self.controller = controller
        super.init(frame: .zero)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap() {
        controller?.dismiss(animated: true, completion: nil)
    }
}

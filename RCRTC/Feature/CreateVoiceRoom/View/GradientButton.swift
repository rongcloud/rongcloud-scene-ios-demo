//
//  GradientButton.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit
import RCSceneRoom

class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [
            RCSCAsset.Colors.hex505DFF.color.cgColor,
            RCSCAsset.Colors.hexE92B88.color.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        if let imageView = self.imageView {
            bringSubviewToFront(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  VoiceRoomLikeIconView.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/31.
//

import UIKit

fileprivate let iconNames: [String] = [
    "like_gift_1",
    "like_gift_2",
    "like_gift_3",
    "like_gift_4",
    "like_gift_5",
    "like_gift_6",
    "like_gift_7",
    "like_gift_8",
    "like_gift_9",
    "like_gift_10"
]

final class VoiceRoomLikeIconLayer: CALayer {
    private lazy var animtion: CAAnimation = {
        let postionAnimation: CABasicAnimation = {
            let dx = CGFloat((-8...8).randomElement() ?? 0).resize
            let dy = CGFloat((-20...20).randomElement() ?? 0).resize - 100.resize
            let animtion = CABasicAnimation(keyPath: "position")
            animtion.fromValue = position
            animtion.toValue = CGPoint(x: position.x + dx, y: position.y + dy)
            return animtion
        }()
        
        let opacityAnimation: CABasicAnimation = {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1
            animation.toValue = 0
            return animation
        }()
        
        let scaleAnimation: CABasicAnimation = {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1
            animation.toValue = 0.8
            return animation
        }()
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [postionAnimation, opacityAnimation]
        animationGroup.duration = 1.2
        animationGroup.fillMode = .forwards
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animationGroup.delegate = self
        animationGroup.isRemovedOnCompletion = false
        return animationGroup
    }()
    
    private lazy var tapAimation: CAAnimation = {
        let scaleAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [1, 1.3, 1, 1.3, 1]
            animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
            return animation
        }()
        let opacityAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = [1, 1, 0]
            animation.keyTimes = [0, 0.4, 1]
            return animation
        }()
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    init(_ name: String) {
        super.init()
        self.name = name
        setIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIcon() {
        let index = (0...9).randomElement() ?? 0
        guard let image = UIImage(named: iconNames[index]) else {
            return
        }
        contents = image.cgImage
    }
    
    func startAniamtion() {
        add(animtion, forKey: "animation")
    }
    
    func startTapAnimation() {
        add(tapAimation, forKey: "tapAnimation")
    }
}

extension VoiceRoomLikeIconLayer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        removeAllAnimations()
        removeFromSuperlayer()
    }
}

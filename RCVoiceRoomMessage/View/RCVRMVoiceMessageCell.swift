//
//  RCVRMVoiceMessageCell.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/10.
//

import UIKit
import RCRTCAudio

fileprivate var currentAudio: String?

final class RCVRMVoiceMessageCell: RCVRMMessageCell {
    private var message: RCVRVoiceMessage? {
        didSet {
            guard let message = message else { return }
            if RCRTCAudioPlayer.shared.isPlaying(message.path) {
                startAnimation()
                RCRTCAudioPlayer.shared.completion = stopAnimation
            }
        }
    }
    
    private lazy var voiceButton: UIButton = {
        let instance = UIButton()
        instance.setImage(UIImage.audio3Image(), for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        instance.setTitle("″", for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        instance.contentHorizontalAlignment = .left
        instance.addTarget(self, action: #selector(voiceClicked), for: .touchUpInside)
        instance.translatesAutoresizingMaskIntoConstraints = false
        return instance
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        containerView.addSubview(voiceButton)
        [
            NSLayoutConstraint(item: voiceButton, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: voiceButton, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: voiceButton, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: voiceButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
        ].forEach { $0.isActive = true }
        
        messageLableRightConstraint.isActive = false
        messageLabel.rightAnchor.constraint(equalTo: voiceButton.leftAnchor, constant: -2).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ message: RCVRVoiceMessage, delegate: RCVRMMessageCellProtocol) -> RCVRMMessageCell {
        self.message = message
        voiceButton.setTitle("\(message.duration)″", for: .normal)
        return super.update(message, delegate: delegate)
    }
    
    @objc private func voiceClicked() {
        guard let message = message else { return }
        RCRTCAudioPlayer.shared.play(URL(string: message.path)) { [weak self] in
            self?.stopAnimation()
        }
        startAnimation()
    }
    
    private func startAnimation() {
        let images: [UIImage?] = [
            UIImage.audio1Image(),
            UIImage.audio2Image(),
            UIImage.audio3Image(),
        ]
        voiceButton.imageView?.animationImages = images.compactMap { $0 }
        voiceButton.imageView?.animationDuration = 1
        voiceButton.imageView?.startAnimating()
    }
    
    private func stopAnimation() {
        voiceButton.imageView?.stopAnimating()
    }
}

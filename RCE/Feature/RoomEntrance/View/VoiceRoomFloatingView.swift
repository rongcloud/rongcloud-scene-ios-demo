//
//  VoiceRoomFloatingView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/7/2.
//

import UIKit
import Pulsator

protocol VoiceRoomFloatingViewDelegate: AnyObject {
    func floatingViewDidClick()
}

class VoiceRoomFloatingView: UIView {
    weak var delegate: VoiceRoomFloatingViewDelegate?
    private lazy var gradientLayer: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.colors = [
            UIColor(byteRed: 255, green: 105, blue: 253).cgColor,
            UIColor(byteRed: 42, green: 38, blue: 242).cgColor
        ]
        instance.startPoint = CGPoint(x: 0.25, y: 0.5)
        instance.endPoint = CGPoint(x: 0.75, y: 0.5)
        instance.borderWidth = 0.5
        instance.borderColor = UIColor(byteRed: 225, green: 222, blue: 255).cgColor
        instance.masksToBounds = true
        instance.opacity = 0.3
        return instance
    }()
    lazy var radarView: Pulsator = {
        let instance = Pulsator()
        instance.numPulse = 4
        instance.radius = 60.resize
        instance.animationDuration = 1.5
        instance.backgroundColor = UIColor(hexString: "#FF69FD").cgColor
        instance.repeatCount = 2
        return instance
    }()
    private(set) lazy var roomAvatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = R.image.floating_room_icon()
        instance.clipsToBounds = true
        return instance
    }()
    private(set) lazy var controlView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        layer.addSublayer(radarView)
        addSubview(roomAvatarImageView)
        addSubview(controlView)
        
        roomAvatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        controlView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hanldeTap))
        controlView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.width * 0.5
        radarView.position = roomAvatarImageView.center
        roomAvatarImageView.layer.cornerRadius = roomAvatarImageView.bounds.height * 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self)
            gesture.setTranslation(.zero, in: self)
            var position = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            if position.x + bounds.width/2 > UIScreen.main.bounds.width {
                position.x = UIScreen.main.bounds.width - bounds.width/2
            }
            if position.x - bounds.width/2 < 0 {
                position.x = bounds.width/2
            }
            if position.y + bounds.height/2 > UIScreen.main.bounds.height {
                position.y = UIScreen.main.bounds.height - bounds.height/2
            }
            if position.y - bounds.height/2 < 0 {
                position.y = bounds.height/2
            }
            center = position
        default:
            ()
        }
    }
    
    @objc func hanldeTap() {
        delegate?.floatingViewDidClick()
    }
    
    public func updateAvatar(url: URL?) {
        roomAvatarImageView.kf.setImage(with: url, placeholder: R.image.room_background_image1())
    }
}

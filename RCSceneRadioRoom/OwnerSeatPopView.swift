//
//  UsedSeatPopView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/10.
//

import UIKit
import RCSceneService
import Kingfisher

class OwnerSeatPopView: UIView {
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = R.image.default_avatar()
        instance.layer.cornerRadius = 28
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var leaveSeatButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        instance.setTitle("下麦围观", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.layer.cornerRadius = 4
        instance.addTarget(self, action: #selector(handleLeaveSeatClickAction), for: .touchUpInside)
        return instance
    }()
    lazy var muteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        instance.setTitle("关闭麦克风", for: .normal)
        instance.layer.cornerRadius = 4
        instance.addTarget(self, action: #selector(handleMuteSeatClickAction), for: .touchUpInside)
        return instance
    }()
    private let leaveButtonClick:(() -> Void)
    private let muteSeatClick:(() -> Void)
    
    init(leaveSeatCallback:@escaping (() -> Void), muteSeatCallback:@escaping (() -> Void)) {
        self.leaveButtonClick = leaveSeatCallback
        self.muteSeatClick = muteSeatCallback
        super.init(frame: .zero)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        popMenuClip(corners: [.topLeft, .topRight], cornerRadius: 22, centerCircleRadius: 37)
    }
    
    private func buildLayout() {
        addSubview(blurView)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(leaveSeatButton)
        addSubview(muteButton)
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.size.equalTo(CGSize(width: 56, height: 56))
            make.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        leaveSeatButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(28)
            make.height.equalTo(44)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
        }
        
        muteButton.snp.makeConstraints { make in
            make.top.equalTo(leaveSeatButton.snp.bottom).offset(15)
            make.size.equalTo(leaveSeatButton)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(25)
        }
    }
    
    @objc private func handleLeaveSeatClickAction() {
        leaveButtonClick()
    }
    
    @objc private func handleMuteSeatClickAction() {
        muteSeatClick()
    }
    
    func updateView(user: VoiceRoomUser) {
        avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: R.image.default_avatar())
    }
}

extension UIView {
    func popMenuClip(corners: UIRectCorner, cornerRadius: CGFloat, centerCircleRadius: CGFloat) {
        let roundCornerBounds = CGRect(x: 0, y: centerCircleRadius, width: bounds.size.width, height: bounds.size.height - centerCircleRadius)
        let path = UIBezierPath(roundedRect: roundCornerBounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: (bounds.size.width/2) - centerCircleRadius, y: 0, width: centerCircleRadius * 2, height: centerCircleRadius * 2))
        path.append(ovalPath)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

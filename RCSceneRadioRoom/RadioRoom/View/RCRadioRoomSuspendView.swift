//
//  RCRadioRoomSuspendView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import UIKit
import RCSceneService

final class RCRadioRoomSuspendView: UIView {
    
    var continueLive: (() -> Void)?
    
    init(_ roomInfo: VoiceRoom) {
        super.init(frame: .zero)
        let subView = roomInfo.isOwner ?
            RCRadioRoomSuspendBroadcasterView(onContinueButtonClicked) :
            RCRadioRoomSuspendAudienceView()
        addSubview(subView)
        subView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func onContinueButtonClicked() {
        continueLive?()
    }
}

final class RCRadioRoomSuspendBroadcasterView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white
        instance.text = "您已暂停直播，观众无法听到声音"
        instance.font = UIFont.systemFont(ofSize: 17.resize, weight: .medium)
        return instance
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white
        instance.font = UIFont.systemFont(ofSize: 17.resize, weight: .medium)
        return instance
    }()
    
    private lazy var continueButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("继续直播", for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.setTitleColor(.lightGray, for: .highlighted)
        instance.titleLabel?.font = UIFont.systemFont(ofSize: 14.resize, weight: .medium)
        instance.addTarget(self, action: #selector(continueRoom), for: .touchUpInside)
        return instance
    }()
    
    private let continueLive: () -> Void
    init(_ continueLive: @escaping () -> Void) {
        self.continueLive = continueLive
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        addSubview(titleLabel)
        addSubview(continueButton)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(safeAreaLayoutGuide.snp.top).offset(120.resize)
        }
        
        continueButton.setBackgroundImage(continueButtonBackgroundImage(), for: .normal)
        continueButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(22.resize)
            make.centerX.equalToSuperview()
            make.width.equalTo(180.resize)
            make.height.equalTo(36.resize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func continueRoom() {
        continueLive()
    }
    
    private func continueButtonBackgroundImage() -> UIImage {
        let size = CGSize(width: 180.resize, height: 36.resize)
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.75)
        gradientLayer.colors = [
            UIColor(byteRed: 73, green: 49, blue: 130, alpha: 0.4).cgColor,
            UIColor(byteRed: 186, green: 164, blue: 255, alpha: 0.4).cgColor
        ]
        gradientLayer.bounds = CGRect(origin: .zero, size: size)
        gradientLayer.borderWidth = 1
        gradientLayer.borderColor = UIColor(byteRed: 106, green: 89, blue: 168).cgColor
        gradientLayer.cornerRadius = 18.resize
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                gradientLayer.render(in: renderer.cgContext)
            }
    }
}

final class RCRadioRoomSuspendAudienceView: UIView {
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white
        instance.text = "房主暂时离开"
        instance.font = UIFont.systemFont(ofSize: 19.resize, weight: .medium)
        return instance
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let instance = UILabel()
        instance.text = "请耐心等待，马上回来"
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        instance.font = UIFont.systemFont(ofSize: 17.resize, weight: .medium)
        return instance
    }()
    
    private lazy var cupImageView = UIImageView(image: R.image.radio_room_leave_cup())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(cupImageView)
        
        cupImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(151.resize)
            make.width.height.equalTo(64.resize)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cupImageView.snp.bottom).offset(12.resize)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

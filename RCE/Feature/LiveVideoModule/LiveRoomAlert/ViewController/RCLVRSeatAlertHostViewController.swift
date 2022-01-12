//
//  RCLVRSeatAlertHostViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/25.
//

import UIKit

class RCLVRSeatAlertHostViewController: RCLVRAlertViewController {
    
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView(image: R.image.default_avatar())
        instance.layer.cornerRadius = 28.resize
        instance.layer.masksToBounds = true
        instance.contentMode = .scaleAspectFill
        return instance
    }()
    
    private lazy var avatarBorderImageView = {
        return UIImageView(image: R.image.gradient_border())
    }()
    
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.text = "- -"
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 17.resize, weight: .medium)
        return instance
    }()
    
    private lazy var seatLabel: UILabel = {
        let instance = UILabel()
        instance.text = "麦位"
        instance.textColor = UIColor(byteRed: 233, green: 233, blue: 233)
        instance.font = .systemFont(ofSize: 13.resize)
        return instance
    }()
    
    private lazy var switchVideoButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "切换到视频连线", type: .gradient))
        instance.addTarget(self, action: #selector(switchVideoButtonClicked), for: .touchUpInside)
        return instance
    }()
    private lazy var switchAudioButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "开启麦克风", type: .normal))
        instance.addTarget(self, action: #selector(switchAudioButtonClicked), for: .touchUpInside)
        return instance
    }()
    
    private let seat: RCLiveVideoSeat
    
    init(_ seat: RCLiveVideoSeat) {
        self.seat = seat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLayout()
        configUI()
    }
    
    private func setupLayout() {
        
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(9.resize)
            make.width.height.equalTo(56.resize)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(avatarImageView.snp.bottom).offset(22.resize)
        }
        
        contentView.addSubview(seatLabel)
        seatLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(nameLabel.snp.bottom).offset(12.resize)
        }
        
        contentView.addSubview(switchVideoButton)
        switchVideoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(150.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
        }
        
        contentView.addSubview(switchAudioButton)
        switchAudioButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(switchVideoButton)
            make.top.equalTo(switchVideoButton.snp.bottom).offset(14.resize)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-25.resize)
        }
    }
    
    private func configUI() {
        seatLabel.text = "\(seat.index)号麦位"
        
        UserInfoDownloaded.shared.refreshUserInfo(userId: seat.userId) { [weak self] user in
            guard let self = self else { return }
            self.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                             placeholder: R.image.default_avatar())
            self.nameLabel.text = "\(user.userName)"
        }
        
        let switchVideoTitle = seat.userEnableVideo ? "切换到音频连线" : "切换到视频连线"
        switchVideoButton.setTitle(switchVideoTitle, for: .normal)
        
        let switchAudioTitle = seat.userEnableAudio ? "关闭麦克风" : "开启麦克风"
        switchAudioButton.setTitle(switchAudioTitle, for: .normal)
    }
    
    override func contentHeight() -> CGFloat {
        return 270.resize
    }
    
    override func maskLayer() -> CAShapeLayer {
        let r: CGFloat = 15.resize
        let R: CGFloat = 37.5.resize
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: contentView.bounds.height))
            path.addArc(withCenter: CGPoint(x: r, y: r + R),
                        radius: r,
                        startAngle: .pi,
                        endAngle: .pi * 1.5,
                        clockwise: true)
            path.addArc(withCenter: CGPoint(x: contentView.bounds.width * 0.5, y: R),
                        radius: R,
                        startAngle: .pi,
                        endAngle: .pi * 2,
                        clockwise: true)
            path.addArc(withCenter: CGPoint(x: contentView.bounds.width - r, y: r + R),
                        radius: r,
                        startAngle: .pi * 1.5,
                        endAngle: .pi * 2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: contentView.bounds.width, y: contentView.bounds.height))
            path.close()
            return path.cgPath
        }()
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.frame = contentView.bounds
        return shapeLayer
    }

    @objc private func switchVideoButtonClicked() {
        dismiss(animated: false)
        seat.setUserEnableVideo(!seat.userEnableVideo) { code in
            debugPrint("setUserEnableVideo \(code.rawValue)")
        }
    }

    @objc private func switchAudioButtonClicked() {
        dismiss(animated: false)
        seat.setUserEnableAudio(!seat.userEnableAudio) { code in
            debugPrint("setUserEnableAudio \(code.rawValue)")
        }
    }
}

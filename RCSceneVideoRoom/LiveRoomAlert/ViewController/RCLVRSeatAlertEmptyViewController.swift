//
//  RCLVRSeatAlertEmptyViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/18.
//

import UIKit

class RCLVRSeatAlertEmptyViewController: RCLVRAlertViewController {
    private(set) lazy var actionView = UIView()
    private(set) lazy var stackView = UIStackView()
    
    private lazy var avatarImageView = UIImageView(image: R.image.live_seat_alert_add())
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.text = "麦位"
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 16.resize, weight: .medium)
        return instance
    }()
    private lazy var invitationButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "邀请用户上麦", type: .gradient))
        instance.addTarget(self, action: #selector(invitationButtonClicked), for: .touchUpInside)
        return instance
    }()
    private lazy var switchSeatButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "切换麦位", type: .normal))
        instance.addTarget(self, action: #selector(switchSeatButtonClicked), for: .touchUpInside)
        return instance
    }()
    private lazy var lockSeatButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("关闭座位", for: .normal)
        instance.setTitle("开启座位", for: .selected)
        instance.setImage(R.image.voiceroom_setting_lockallseat(), for: .normal)
        instance.setImage(R.image.voiceroom_setting_unlockallseat(), for: .selected)
        instance.addTarget(self, action: #selector(handleLockSeat), for: .touchUpInside)
        return instance
    }()
    private lazy var muteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("座位禁麦", for: .normal)
        instance.setTitle("座位开麦", for: .selected)
        instance.setImage(R.image.voiceroom_setting_muteall(), for: .normal)
        instance.setImage(R.image.voiceroom_setting_unmuteall(), for: .selected)
        instance.addTarget(self, action: #selector(handleMuteSeat), for: .touchUpInside)
        return instance
    }()
    
    private let seatInfo: RCLiveVideoSeat
    
    private var canSwitch: Bool {
        guard RCLiveVideoEngine.shared().currentMixType == .gridNine else { return false }
        guard let room = SceneRoomManager.shared.currentRoom else { return false }
        return room.userId == Environment.currentUserId
    }
    
    init(_ seatInfo: RCLiveVideoSeat) {
        self.seatInfo = seatInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLayout()
        titleLabel.text = "\(seatInfo.index)号麦位"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lockSeatButton.alignImageAndTitleVertically(padding: 8)
        muteButton.alignImageAndTitleVertically(padding: 8)
    }
    
    private func setupLayout() {
        actionView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        contentView.addSubview(actionView)
        actionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-114.resize)
        }
        
        stackView.distribution = .fillEqually
        actionView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(114.resize)
        }
        
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(9.resize)
            make.width.height.equalTo(56.resize)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(avatarImageView.snp.bottom).offset(21.resize)
        }
        
        contentView.addSubview(invitationButton)
        invitationButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(118.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
        }
        
        if canSwitch {
            contentView.addSubview(switchSeatButton)
            switchSeatButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.size.equalTo(invitationButton)
                make.top.equalTo(invitationButton.snp.bottom).offset(14.resize)
                make.bottom.equalTo(actionView.snp.top).offset(-25.resize)
            }
        } else {
            invitationButton.snp.makeConstraints { make in
                make.bottom.equalTo(actionView.snp.top).offset(-25.resize)
            }
        }
        
        stackView.addArrangedSubview(lockSeatButton)
        stackView.addArrangedSubview(muteButton)
        
        lockSeatButton.isSelected = seatInfo.lock
        muteButton.isSelected = seatInfo.mute
    }
    
    override func contentHeight() -> CGFloat {
        return canSwitch ? 360.resize : 302.resize
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

    @objc private func invitationButtonClicked() {
        dismiss(animated: false)
        if let liveViewController = presentingViewController {
            let controller = RCLVMicViewController(1, seatIndex: seatInfo.index)
            controller.delegate = delegate as? RCLVMicViewControllerDelegate
            liveViewController.present(controller, animated: true)
        }
    }
    
    @objc private func switchSeatButtonClicked() {
        dismiss(animated: false)
        let index = seatInfo.index
        RCLiveVideoEngine.shared().switchLiveVideo(to: seatInfo.index) { code in
            debugPrint("switchLiveVideo \(code.rawValue)")
            SceneRoomManager.updateLiveSeatList()
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "切换到\(index)号麦位成功")
            } else {
                SVProgressHUD.showError(withStatus: "切换麦位失败")
            }
        }
    }

    @objc private func handleLockSeat() {
        dismiss(animated: true)
        let lock = !seatInfo.lock
        let index = seatInfo.index
        seatInfo.setLock(lock) { code in
            debugPrint("result code: \(code.rawValue)")
            if lock {
                SVProgressHUD.showSuccess(withStatus: "关闭\(index)号麦位成功")
            } else {
                SVProgressHUD.showSuccess(withStatus: "开启\(index)号麦位成功")
            }
        }
    }
    
    @objc private func handleMuteSeat() {
        dismiss(animated: true)
        let mute = !seatInfo.mute
        seatInfo.setMute(mute) { code in
            debugPrint("result code: \(code.rawValue)")
            if mute {
                SVProgressHUD.showSuccess(withStatus: "此麦位已闭麦")
            } else {
                SVProgressHUD.showSuccess(withStatus: "闭麦已取消")
            }
        }
    }
}

//
//  OwnerClickEmptySeatViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import UIKit

protocol VoiceRoomEmptySeatOperationProtocol: AnyObject {
    func emptySeat(_ index: UInt, isLock: Bool)
    func emptySeat(_ index: UInt, isMute: Bool)
    func emptySeatInvitationDidClicked()
}

class VoiceRoomEmptySeatOperationViewController: UIViewController {
    private let seatInfo: RCVoiceSeatInfo
    private let seatIndex: UInt
    weak var delegate:VoiceRoomEmptySeatOperationProtocol?
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = R.image.plus_white_bg_icon()
        instance.layer.cornerRadius = 28
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var seatIndexLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .white
        instance.text = ""
        return instance
    }()
    private lazy var inviteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("邀请用户上麦", for: .normal)
        instance.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        instance.layer.cornerRadius = 6
        instance.addTarget(self, action: #selector(handleInviteDidClick), for: .touchUpInside)
        return instance
    }()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [lockSeatButton, muteButton])
        instance.alignment = .center
        instance.distribution = .fillEqually
        instance.backgroundColor = R.color.hex03062F()?.withAlphaComponent(0.16)
        return instance
    }()
    private lazy var lockSeatButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("关闭座位", for: .normal)
        instance.setImage(R.image.voiceroom_setting_lockallseat(), for: .normal)
        instance.addTarget(self, action: #selector(handleLockSeat), for: .touchUpInside)
        return instance
    }()
    private lazy var muteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("座位禁麦", for: .normal)
        instance.setImage(R.image.voiceroom_setting_muteall(), for: .normal)
        instance.addTarget(self, action: #selector(handleMuteSeat), for: .touchUpInside)
        return instance
    }()
    
    private lazy var tapGestureView = RCTapGestureView(self)
    
    init(seatInfo: RCVoiceSeatInfo, seatIndex: UInt, delegate: VoiceRoomEmptySeatOperationProtocol?) {
        self.seatInfo = seatInfo
        self.seatIndex = seatIndex
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        setupButtonState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.popMenuClip(corners: [.topLeft, .topRight], cornerRadius: 22, centerCircleRadius: 37)
        lockSeatButton.alignImageAndTitleVertically(padding: 8)
        muteButton.alignImageAndTitleVertically(padding: 8)
    }
    
    private func buildLayout() {
        view.addSubview(tapGestureView)
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(avatarImageView)
        container.addSubview(seatIndexLabel)
        container.addSubview(inviteButton)
        container.addSubview(stackView)
        
        tapGestureView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(container.snp.top).offset(-20)
        }
        
        container.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
        }
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.size.equalTo(CGSize(width: 56, height: 56))
            make.centerX.equalToSuperview()
        }
        
        seatIndexLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        inviteButton.snp.makeConstraints {
            $0.top.equalTo(seatIndexLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(28)
            $0.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(inviteButton.snp.bottom).offset(25)
            $0.height.equalTo(135)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupButtonState() {
        let isLockSeat = seatInfo.status == .locking
        if isLockSeat {
            lockSeatButton.setTitle("打开座位", for: .normal)
            lockSeatButton.setImage(R.image.voiceroom_setting_unlockallseat(), for: .normal)
        } else {
            lockSeatButton.setTitle("关闭座位", for: .normal)
            lockSeatButton.setImage(R.image.voiceroom_setting_lockallseat(), for: .normal)
        }
        if seatInfo.isMuted {
            muteButton.setTitle("座位开麦", for: .normal)
            muteButton.setImage(R.image.voiceroom_setting_unmuteall(), for: .normal)
        } else {
            muteButton.setTitle("座位禁麦", for: .normal)
            muteButton.setImage(R.image.voiceroom_setting_muteall(), for: .normal)
        }
        seatIndexLabel.text = "\(seatIndex)号麦位"
    }
    
    @objc func handleLockSeat() {
        let isLock = seatInfo.status == .locking
        delegate?.emptySeat(seatIndex, isLock: !isLock)
        setupButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleMuteSeat() {
        delegate?.emptySeat(seatIndex, isMute: !seatInfo.isMuted)
        setupButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleInviteDidClick() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.emptySeatInvitationDidClicked()
        }
    }
}


//
//  UserSeatPopViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import UIKit
import SVProgressHUD

protocol ManageOwnSeatProtocol: AnyObject {
    func userSeatSilenceButtonDidClick(seatIndex: UInt, isMute: Bool)
    func userSeatDidLeaveClick(seatIndex: UInt)
}

class ManageOwnSeatViewController: UIViewController {
    weak var delegate:ManageOwnSeatProtocol?
    private let isMute: Bool
    private let seatIndex: UInt
    private let isSeatMute: Bool
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
        instance.setTitle("断开连接", for: .normal)
        instance.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        instance.layer.cornerRadius = 4
        instance.addTarget(self, action: #selector(handleLeaveSeatClickAction), for: .touchUpInside)
        return instance
    }()
    private lazy var muteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        instance.setTitle("关闭麦克风", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.layer.cornerRadius = 4
        instance.addTarget(self, action: #selector(handleMuteSeatClickAction), for: .touchUpInside)
        return instance
    }()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var tapGestureView = RCTapGestureView(self)
    
    init(seatIndex: UInt, isMute: Bool, delegate: ManageOwnSeatProtocol?, isSeatMute: Bool) {
        self.seatIndex = seatIndex
        self.isMute = isMute
        self.delegate = delegate
        self.isSeatMute = isSeatMute
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            guard let self = self else { return }
            self.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: R.image.default_avatar())
            self.nameLabel.text = user.userName
        }
        let title = isMute ? "打开麦克风" : "关闭麦克风"
        muteButton.setTitle(title, for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.popMenuClip(corners: [.topLeft, .topRight], cornerRadius: 22, centerCircleRadius: 37)
    }
    
    private func buildLayout() {
        view.addSubview(tapGestureView)
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(avatarImageView)
        container.addSubview(nameLabel)
        container.addSubview(leaveSeatButton)
        container.addSubview(muteButton)
        
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
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        muteButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(28)
            make.height.equalTo(44)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
        }
        
        leaveSeatButton.snp.makeConstraints { make in
            make.top.equalTo(muteButton.snp.bottom).offset(15)
            make.size.equalTo(muteButton)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(25)
        }
    }
    
    @objc private func handleLeaveSeatClickAction() {
        delegate?.userSeatDidLeaveClick(seatIndex: seatIndex)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleMuteSeatClickAction() {
        guard !isSeatMute else {
            SVProgressHUD.showError(withStatus: "此座位已被管理员禁麦")
            return
        }
        delegate?.userSeatSilenceButtonDidClick(seatIndex: seatIndex, isMute: !isMute)
        dismiss(animated: true, completion: nil)
    }
}


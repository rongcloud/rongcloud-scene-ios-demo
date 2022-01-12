//
//  LiveVideoRoomUserView.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/23.
//

import UIKit

class LiveVideoRoomUserView: UIView {
    
    private lazy var avatarImageView = UIImageView(image: R.image.default_avatar())
    
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14, weight: .medium)
        instance.textColor = .white
        instance.text = "- -"
        return instance
    }()
    
    private lazy var networkImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.network_speed_fine()
        return instance
    }()
    private lazy var networkLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = .white.withAlphaComponent(0.7)
        return instance
    }()
    
    private(set) lazy var followButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(followButtonDidClicked), for: .touchUpInside)
        return button
    }()
    
    private var isFollow: Bool = false
    
    private var room: VoiceRoom? {
        didSet {
            guard oldValue == nil else { return }
            fetchUserInfo()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewClick))
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
        
        NotificationNameDidFollowUser.addObserver(self, selector: #selector(fetchUserInfo))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
        layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = bounds.height * 0.5
        avatarImageView.layer.masksToBounds = true
    }
    
    func setRoom(_ room: VoiceRoom) {
        self.room = room
    }
    
    @objc func handleViewClick() {
        guard let room = room else { return }
        let alertController = RCLVRSeatAlertUserViewController(room.userId)
        alertController.userDelegate = controller as? VoiceRoomUserOperationProtocol
        controller?.present(alertController, animated: false)
    }
    
    public func updateNetworking(rtt: NSInteger) {
        switch rtt {
        case 0...99:
            networkImageView.image = R.image.network_speed_fine()
        case 100...200:
            networkImageView.image = R.image.network_speed_soso()
        default:
            networkImageView.image = R.image.network_speed_bad()
        }
        networkLabel.text = "\(rtt)ms"
    }
    
    func updateNetworkDelay(_ hidden: Bool) {
        networkImageView.isHidden = hidden
        networkLabel.isHidden = hidden
        if hidden {
            nameLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(48)
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualTo(160)
                make.right.lessThanOrEqualToSuperview().offset(-20)
            }
        } else {
            nameLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(48)
                make.centerY.equalTo(snp.top).offset(13)
                make.width.lessThanOrEqualTo(160)
                make.right.lessThanOrEqualToSuperview().offset(-20)
            }
        }
        if followButton.superview != nil {
            nameLabel.snp.makeConstraints { make in
                make.right.lessThanOrEqualTo(followButton.snp.left).offset(-4)
            }
        }
    }
}

extension LiveVideoRoomUserView {
    private func setupUI() {
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        
        addSubview(avatarImageView)
        addSubview(nameLabel)
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.centerY.equalTo(snp.top).offset(13)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }
        
        addSubview(networkImageView)
        addSubview(networkLabel)
        
        networkImageView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.centerY.equalTo(snp.bottom).offset(-9)
        }
        
        networkLabel.snp.makeConstraints { make in
            make.left.equalTo(networkImageView.snp.right).offset(4)
            make.centerY.equalTo(networkImageView)
            make.right.lessThanOrEqualToSuperview().offset(-12)
        }
    }
}

extension LiveVideoRoomUserView {
    @objc private func fetchUserInfo() {
        guard let room = room else { return }
        UserInfoDownloaded.shared.refreshUserInfo(userId: room.userId) { [weak self] user in
            guard let self = self else { return }
            self.nameLabel.text = user.userName
            self.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                             placeholder: R.image.default_avatar())
            if room.isOwner == false {
                self.updateFollow(user.isFollow)
            }
        }
    }
    
    @objc private func followButtonDidClicked() {
        guard let userId = room?.userId else { return }
        let follow = !isFollow
        networkProvider.request(.follow(userId: userId)) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(res):
                if res.validate() {
                    self?.didFollow(follow)
                    self?.updateFollow(follow)
                }
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func didFollow(_ isFollow: Bool) {
        guard let userId = room?.userId else { return }
        guard let delegate = controller as? VoiceRoomUserOperationProtocol else { return }
        delegate.didFollow(userId: userId, isFollow: isFollow)
    }
    
    private func updateFollow(_ isFollow: Bool) {
        self.isFollow = isFollow
        if isFollow {
            followButton.setBackgroundImage(followedBackgroundImage(), for: .normal)
            followButton.setTitle("已关注", for: .normal)
            followButton.setTitleColor(.white.withAlphaComponent(0.8), for: .normal)
        } else {
            followButton.setBackgroundImage(followBackgroundImage(), for: .normal)
            followButton.setTitle("关注", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
        }
        let width = isFollow ? 60 : 48
        
        addSubview(followButton)
        followButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(6)
            make.width.equalTo(width)
            make.height.equalTo(28)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.centerY.equalTo(snp.top).offset(13)
            make.width.lessThanOrEqualTo(160)
            make.right.lessThanOrEqualTo(followButton.snp.left).offset(-4)
        }
        
        networkLabel.snp.makeConstraints { make in
            make.left.equalTo(networkImageView.snp.right).offset(4)
            make.centerY.equalTo(networkImageView)
            make.right.lessThanOrEqualTo(followButton.snp.left).offset(-6)
        }
        
        updateNetworkDelay(networkLabel.isHidden)
    }
    
    private func followBackgroundImage() -> UIImage {
        let size = CGSize(width: 48, height: 28)
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.colors = [
            UIColor(byteRed: 80, green: 93, blue: 255, alpha: 0.4).cgColor,
            UIColor(byteRed: 233, green: 43, blue: 136, alpha: 0.4).cgColor
        ]
        gradientLayer.bounds = CGRect(origin: .zero, size: size)
        gradientLayer.cornerRadius = 14
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                gradientLayer.render(in: renderer.cgContext)
            }
    }
    
    private func followedBackgroundImage() -> UIImage {
        let size = CGSize(width: 60, height: 28)
        let layer = CALayer()
        layer.bounds = CGRect(origin: .zero, size: size)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.cornerRadius = 14
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                layer.render(in: renderer.cgContext)
            }
    }
}

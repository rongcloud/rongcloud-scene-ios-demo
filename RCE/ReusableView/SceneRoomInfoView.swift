//
//  RoomInfoView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit

protocol RoomInfoViewClickProtocol: AnyObject {
    func roomInfoDidClick()
    func didFollowRoomUser(_ follow: Bool)
}

class SceneRoomInfoView: UIView {
    weak var delegate: RoomInfoViewClickProtocol?
    
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "- - "
        return instance
    }()
    private lazy var idLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        instance.text = "ID - -"
        return instance
    }()
    private lazy var yellowDotView: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexF8E71C()
        instance.layer.cornerRadius = 2
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var onlineMemberLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        instance.text = "在线 - "
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
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        return instance
    }()
    private(set) lazy var followButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 12.resize)
        button.addTarget(self, action: #selector(followButtonDidClicked), for: .touchUpInside)
        return button
    }()
    
    private var isFollow: Bool = false
    
    /// 电台模式不支持网络延时
    private var networkEnable: Bool {
        return room.roomType != 2
    }
    
    private let room: VoiceRoom
    init(_ room: VoiceRoom) {
        self.room = room
        super.init(frame: .zero)
        
        setupUI()
        updateRoom(info: room)
        
        /// 关注
        fetchUserInfo()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewClick))
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topRight, .bottomRight], radius: 20.0)
    }
    
    public func updateRoom(info: VoiceRoom) {
        nameLabel.text = info.roomName
        idLabel.text = "ID " + String(info.id)
        updateRoomUserNumber()
    }
    
    
    public func updateRoomUserNumber() {
        RCChatRoomClient.shared()
            .getChatRoomInfo(room.roomId, count: 0, order: .chatRoom_Member_Asc) { info in
                DispatchQueue.main.async {
                    self.onlineMemberLabel.text = "在线 \(info.totalMemberCount)"
                    self.layoutIfNeeded()
                }
            } error: { _ in }
    }
    
    @objc func handleViewClick() {
        if let delegate = controller as? VoiceRoomUserOperationProtocol {
            let dependency = VoiceRoomUserOperationDependency(room: room,
                                                              presentUserId: "")
            controller?.navigator(.userlist(dependency: dependency, delegate: delegate))
        } else {
            delegate?.roomInfoDidClick()
        }
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
}

extension SceneRoomInfoView {
    private func setupUI() {
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        
        addSubview(nameLabel)
        addSubview(idLabel)
        addSubview(yellowDotView)
        addSubview(onlineMemberLabel)
        
        nameLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(12.resize)
            $0.top.equalToSuperview().offset(6.resize)
            $0.width.lessThanOrEqualTo(160.resize)
        }
        
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(1)
            $0.left.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(6.resize)
        }
        
        yellowDotView.snp.makeConstraints {
            $0.centerY.equalTo(idLabel)
            $0.size.equalTo(CGSize(width: 4, height: 4))
            $0.left.equalTo(idLabel.snp.right).offset(10.resize)
        }
        
        onlineMemberLabel.snp.makeConstraints {
            $0.centerY.equalTo(yellowDotView)
            $0.left.equalTo(yellowDotView.snp.right).offset(3)
        }
        
        if networkEnable {
            addSubview(networkImageView)
            addSubview(networkLabel)
            
            networkImageView.snp.makeConstraints { make in
                make.left.equalTo(onlineMemberLabel.snp.right).offset(10.resize)
                make.centerY.equalTo(onlineMemberLabel)
            }
            
            networkLabel.snp.makeConstraints { make in
                make.left.equalTo(networkImageView.snp.right).offset(3)
                make.centerY.equalTo(networkImageView)
                make.right.equalToSuperview().inset(27.resize)
            }
        } else {
            onlineMemberLabel.snp.makeConstraints {
                $0.right.equalToSuperview().inset(27.resize)
            }
        }
    }
}

extension SceneRoomInfoView {
    private func fetchUserInfo() {
        if room.isOwner { return }
        UserInfoDownloaded.shared.refreshUserInfo(userId: room.userId) { [weak self] user in
            guard let self = self else { return }
            self.updateFollow(user.isFollow)
        }
    }
    
    @objc private func followButtonDidClicked() {
        let userId = room.userId
        let follow = !isFollow
        networkProvider.request(.follow(userId: userId)) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(res):
                if res.validate() {
                    self?.updateFollow(follow)
                }
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func updateFollow(_ isFollow: Bool) {
        delegate?.didFollowRoomUser(isFollow)
        self.isFollow = isFollow
        if isFollow {
            followButton.setBackgroundImage(followedBackgroundImage(), for: .normal)
            followButton.setTitle("已关注", for: .normal)
            followButton.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        } else {
            followButton.setBackgroundImage(followBackgroundImage(), for: .normal)
            followButton.setTitle("关注", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
        }
        let width = isFollow ? 60.resize : 48.resize
        addSubview(followButton)
        followButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(6.resize)
            make.width.equalTo(width)
            make.height.equalTo(28.resize)
        }
        
        nameLabel.snp.remakeConstraints {
            $0.left.equalToSuperview().inset(12.resize)
            $0.top.equalToSuperview().offset(6.resize)
            $0.width.lessThanOrEqualTo(160.resize)
            $0.right.equalTo(followButton.snp.left)
        }
        
        if networkEnable {
            networkLabel.snp.remakeConstraints { make in
                make.left.equalTo(networkImageView.snp.right).offset(3)
                make.centerY.equalTo(networkImageView)
                make.right.lessThanOrEqualTo(followButton.snp.left).offset(-6.resize)
            }
        } else {
            onlineMemberLabel.snp.remakeConstraints {
                $0.centerY.equalTo(yellowDotView)
                $0.left.equalTo(yellowDotView.snp.right).offset(3)
                $0.right.lessThanOrEqualTo(followButton.snp.left).offset(-6.resize)
            }
        }
    }
    
    private func followBackgroundImage() -> UIImage {
        let size = CGSize(width: 48.resize, height: 28.resize)
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.colors = [
            UIColor(byteRed: 80, green: 93, blue: 255, alpha: 0.4).cgColor,
            UIColor(byteRed: 233, green: 43, blue: 136, alpha: 0.4).cgColor
        ]
        gradientLayer.bounds = CGRect(origin: .zero, size: size)
        gradientLayer.cornerRadius = 14.resize
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                gradientLayer.render(in: renderer.cgContext)
            }
    }
    
    private func followedBackgroundImage() -> UIImage {
        let size = CGSize(width: 60.resize, height: 28.resize)
        let layer = CALayer()
        layer.bounds = CGRect(origin: .zero, size: size)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.cornerRadius = 14.resize
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                layer.render(in: renderer.cgContext)
            }
    }
}

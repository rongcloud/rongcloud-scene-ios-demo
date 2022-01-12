//
//  RCLVRUserAlertViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/25.
//

import SVProgressHUD
import RCLiveVideoLib
import SwiftUI

class RCLVRSeatAlertUserViewController: RCLVRAlertViewController {
    weak var userDelegate: VoiceRoomUserOperationProtocol?
    
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView(image: R.image.default_avatar())
        instance.contentMode = .scaleAspectFill
        instance.layer.cornerRadius = 28.resize
        instance.layer.masksToBounds = true
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
    
    private lazy var sendGiftButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setTitle("送礼物", for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        instance.titleLabel?.font = .systemFont(ofSize: 14.resize, weight: .medium)
        instance.setBackgroundImage(sendGiftButtonBackgroundImage(), for: .normal)
        instance.addTarget(self, action: #selector(sendGiftButtonClicked), for: .touchUpInside)
        return instance
    }()
    private lazy var sendPrivateMessageButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setTitle("发私信", for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 14.resize, weight: .medium)
        instance.setTitleColor(UIColor(byteRed: 239, green: 73, blue: 154), for: .normal)
        instance.setTitleColor(UIColor(byteRed: 239, green: 73, blue: 154, alpha: 0.7), for: .highlighted)
        instance.setBackgroundImage(commonButtonBackgroundImage(), for: .normal)
        instance.addTarget(self, action: #selector(sendPrivateMessageButtonClicked), for: .touchUpInside)
        return instance
    }()
    private lazy var followButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setTitle("+关注", for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 14.resize, weight: .medium)
        instance.setTitleColor(UIColor(byteRed: 239, green: 73, blue: 154), for: .normal)
        instance.setTitleColor(UIColor(byteRed: 239, green: 73, blue: 154, alpha: 0.7), for: .highlighted)
        instance.setBackgroundImage(commonButtonBackgroundImage(), for: .normal)
        instance.addTarget(self, action: #selector(followButtonClicked), for: .touchUpInside)
        return instance
    }()
    
    private(set) lazy var actionView = UIView()
    private(set) lazy var stackView: UIStackView = {
        let instance = UIStackView()
        instance.distribution = .fillEqually
        return instance
    }()
    
    private lazy var liveSeatButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("邀请连麦", for: .normal)
        instance.setTitle("抱下麦", for: .selected)
        instance.setImage(R.image.pick_user_up_seat_icon(), for: .normal)
        instance.setImage(R.image.pick_user_down_seat_icon(), for: .selected)
        instance.addTarget(self, action: #selector(handlePickDownSeat), for: .touchUpInside)
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
    private lazy var muteSeatButton: UIButton = {
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
    private lazy var kickOutRoomButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("踢出房间", for: .normal)
        instance.setImage(R.image.kick_out_room_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handleKickOutRoom), for: .touchUpInside)
        return instance
    }()
    private lazy var manageButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        instance.titleLabel?.font = .systemFont(ofSize: 13)
        instance.setTitle("设为管理", for: .normal)
        instance.setTitleColor(UIColor(hexInt: 0xdfdfdf), for: .normal)
        instance.setImage(R.image.empty_star(), for: .normal)
        instance.addTarget(self, action: #selector(setManager), for: .touchUpInside)
        instance.centerTextAndImage(spacing: 5)
        return instance
    }()
    
    private var isFollow: Bool = false
    
    private let userId: String
    
    init(_ userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLayout()
        setupSeatView()
        setupActionView()
        setupStackView()
        configUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView
            .arrangedSubviews
            .forEach {
                ($0 as? UIButton)?.alignImageAndTitleVertically(padding: 8)
            }
        manageButton.roundCorners(corners: [.bottomLeft, .topRight], radius: 22)
    }
    
    override func contentHeight() -> CGFloat {
        return 333.resize
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
}

extension RCLVRSeatAlertUserViewController {
    private func setupLayout() {
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(9.resize)
            make.width.height.equalTo(56.resize)
        }
        
        contentView.addSubview(avatarBorderImageView)
        avatarBorderImageView.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(avatarImageView.snp.bottom).offset(22.resize)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-25.resize)
        }
    }
    
    private func setupSeatView() {
        if Environment.currentUserId == userId { return }
        guard let seat = userId.seat else { return }
        contentView.addSubview(seatLabel)
        seatLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(nameLabel.snp.bottom).offset(12.resize)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-25.resize)
        }
        seatLabel.text = "\(seat.index)号麦位"
    }
    
    private func setupActionView() {
        if Environment.currentUserId == userId { return }
        
        contentView.addSubview(sendGiftButton)
        contentView.addSubview(sendPrivateMessageButton)
        contentView.addSubview(followButton)
        
        let topOffset: CGFloat = userId.seating ? 150.resize : 125.resize
        sendPrivateMessageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(topOffset)
            make.width.equalTo(100.resize)
            make.height.equalTo(43.resize)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-25.resize)
        }
        
        sendGiftButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(1.0/3)
            make.centerY.equalTo(sendPrivateMessageButton)
            make.width.equalTo(100.resize)
            make.height.equalTo(43.resize)
        }
        
        followButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(5.0/3)
            make.centerY.equalTo(sendPrivateMessageButton)
            make.width.equalTo(100.resize)
            make.height.equalTo(43.resize)
        }
        
        contentView.addSubview(manageButton)
        manageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(37.5.resize)
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 45))
        }
    }
    
    private func setupStackView() {
        var displayStak: Bool {
            if Environment.currentUserId == userId { return false }
            if Environment.currentUserId.isHost { return true }
            if Environment.currentUserId.isManager { return !userId.isHost }
            return false
        }
        guard displayStak else { return }
        
        actionView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        contentView.addSubview(actionView)
        actionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-114.resize)
        }
        
        actionView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(114.resize)
        }
        
        liveSeatButton.isSelected = userId.seating
        stackView.addArrangedSubview(liveSeatButton)
        if Environment.currentUserId.isHost, let seat = userId.seat {
            stackView.addArrangedSubview(lockSeatButton)
            stackView.addArrangedSubview(muteSeatButton)
            lockSeatButton.isSelected = seat.lock
            muteSeatButton.isSelected = seat.mute
        }
        stackView.addArrangedSubview(kickOutRoomButton)
        
        sendPrivateMessageButton.snp.makeConstraints { make in
            make.bottom.equalTo(actionView.snp.top).offset(-25.resize)
        }
    }
    
    private func configUI() {
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { [weak self] user in
            guard let self = self else { return }
            self.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                             placeholder: R.image.default_avatar())
            self.nameLabel.text = "\(user.userName)"
            self.isFollow = user.isFollow
            self.followButton.setTitle(self.isFollow ? "已关注" : "+关注", for: .normal)
        }
        
        if userId.isManager {
            manageButton.setImage(R.image.full_star(), for: .normal)
            manageButton.setTitle("撤回管理", for: .normal)
        } else {
            manageButton.setImage(R.image.empty_star(), for: .normal)
            manageButton.setTitle("设为管理", for: .normal)
        }
        manageButton.isHidden = !Environment.currentUserId.isHost
    }
}

extension RCLVRSeatAlertUserViewController {
    @objc private func sendGiftButtonClicked() {
        dismiss(animated: false)
        userDelegate?.didClickedSendGift(userId: userId)
    }
    
    private func onFollow(_ userId: String, follow: Bool) {
        isFollow = follow
        followButton.setTitle(follow ? "已关注" : "+关注", for: .normal)
        userDelegate?.didFollow(userId: userId, isFollow: isFollow)
    }

    @objc private func sendPrivateMessageButtonClicked() {
        dismiss(animated: false)
        userDelegate?.didClickedPrivateChat(userId: userId)
    }
    
    @objc private func followButtonClicked() {
        let follow = !isFollow
        let userId = userId
        networkProvider.request(.follow(userId: userId)) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(res):
                if res.validate() {
                    self?.onFollow(userId, follow: follow)
                } else {
                    SVProgressHUD.showError(withStatus: "网络请求失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @objc private func handlePickDownSeat() {
        dismiss(animated: false)
        if userId.seating {
            RCLiveVideoEngine.shared().kickUser(fromSeat:userId) { code in
                debugPrint("finishLiveVideo \(code.rawValue)")
            }
        } else {
            RCLiveVideoEngine.shared().inviteLiveVideo(userId, at: -1) { code in
                debugPrint("inviteLiveVideo \(code.rawValue)")
                SVProgressHUD.showSuccess(withStatus: "已邀请上麦")
            }
        }
    }
    
    @objc private func handleLockSeat() {
        dismiss(animated: false)
        if RCLiveVideoEngine.shared().currentMixType == .oneToOne {
            return SVProgressHUD.showInfo(withStatus: "默认模式不支持锁座")
        }
        guard let seat = userId.seat else { return }
        let lock = !seat.lock
        let index = seat.index
        seat.setLock(lock) { code in
            debugPrint("setLock \(code.rawValue)")
            if code == .success {
                if lock {
                    SVProgressHUD.showSuccess(withStatus: "关闭\(index)号麦位成功")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "开启\(index)号麦位成功")
                }
            } else {
                SVProgressHUD.showError(withStatus: "设置失败")
            }
        }
    }
    
    @objc private func handleMuteSeat() {
        dismiss(animated: false)
        guard let seat = userId.seat else { return }
        let mute = !seat.mute
        seat.setMute(mute) { code in
            debugPrint("setMute \(code.rawValue)")
            if code == .success {
                if mute {
                    SVProgressHUD.showSuccess(withStatus: "此麦位已闭麦")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "闭麦已取消")
                }
            } else {
                SVProgressHUD.showError(withStatus: "设置失败")
            }
        }
    }
    
    @objc private func handleKickOutRoom() {
        dismiss(animated: false)
        RCLiveVideoEngine.shared().kickOutRoom(userId) { code in
            debugPrint("kickOutRoom \(code.rawValue)")
            self.userDelegate?.kickoutRoom(userId: self.userId)
        }
    }
    
    @objc private func setManager() {
        guard let roomId = SceneRoomManager.shared.currentRoom?.roomId else { return }
        let userId = userId
        let setManager = !userId.isManager
        let api = RCNetworkAPI.setRoomManager(roomId: roomId, userId: userId, isManager: setManager)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    self.userDelegate?.didSetManager(userId: userId, isManager: setManager)
                    self.dismiss(animated: true)
                } else {
                    SVProgressHUD.showError(withStatus: "观众不在房间内，操作失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}

extension RCLVRSeatAlertUserViewController {
    private func sendGiftButtonBackgroundImage() -> UIImage {
        let size = CGSize(width: 100.resize, height: 44.resize)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor(byteRed: 239, green: 73, blue: 154).cgColor
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                       cornerRadius: 50.resize).cgPath
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                shapeLayer.render(in: renderer.cgContext)
            }
    }
    
    private func commonButtonBackgroundImage() -> UIImage {
        let size = CGSize(width: 100.resize, height: 44.resize)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(byteRed: 239, green: 73, blue: 154).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5),
                                       cornerRadius: 50.resize).cgPath
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                shapeLayer.render(in: renderer.cgContext)
            }
    }
}

fileprivate extension String {
    var seating: Bool {
        RCLiveVideoEngine.shared().currentSeats.contains(where: { $0.userId == self })
    }
    
    var isHost: Bool {
        SceneRoomManager.shared.currentRoom?.userId == self
    }
    
    var isManager: Bool {
        SceneRoomManager.shared.managerlist.contains(self)
    }
    
    var seat: RCLiveVideoSeat? {
        RCLiveVideoEngine.shared().currentSeats.first(where: {$0.userId == self})
    }
}

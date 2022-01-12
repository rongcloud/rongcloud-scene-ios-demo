//
//  OwnerClickUsedSeatViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import UIKit
import SVProgressHUD
import RxSwift

protocol VoiceRoomUserOperationProtocol: AnyObject {
    func kickUserOffSeat(seatIndex: UInt)
    func lockSeatDidClick(isLock: Bool, seatIndex: UInt)
    func muteSeat(isMute: Bool, seatIndex: UInt)
    func kickoutRoom(userId: String)
    func didSetManager(userId: String, isManager: Bool)
    func didClickedPrivateChat(userId: String)
    func didClickedSendGift(userId: String)
    func didClickedInvite(userId: String)
    func didFollow(userId: String, isFollow: Bool)
}

extension VoiceRoomUserOperationProtocol {
    func kickUserOffSeat(seatIndex: UInt) {}
    func lockSeatDidClick(isLock: Bool, seatIndex: UInt) {}
    func muteSeat(isMute: Bool, seatIndex: UInt) {}
    func kickoutRoom(userId: String) {}
    func didSetManager(userId: String, isManager: Bool) {}
    func didClickedPrivateChat(userId: String) {}
    func didClickedSendGift(userId: String) {}
    func didClickedInvite(userId: String) {}
    func didFollow(userId: String, isFollow: Bool) {}
}

struct VoiceRoomUserOperationDependency {
    let room: VoiceRoom
    var presentUserId: String
    var managelist: [String] { SceneRoomManager.shared.managerlist }
    var currentUserRoleType: VoiceRoomUserType {
        if room.isOwner { return .creator }
        if managelist.contains(Environment.currentUserId) { return .manager }
        return .audience
    }
    var presentUserRoleType: VoiceRoomUserType {
        if room.userId == presentUserId { return .creator }
        if managelist.contains(presentUserId) { return .manager }
        return .audience
    }
    var relativeSeatInfo: RCVoiceSeatInfo? {
        seatInfolist.first { info in
            info.userId == presentUserId
        }
    }
    var relativeSeatIndex: Int? {
        seatInfolist.firstIndex { info in
            info.userId == presentUserId
        }
    }
    var seatInfolist: [RCVoiceSeatInfo] {
        SceneRoomManager.shared.seatlist
    }
    
    func isPrsenterManager() -> Bool {
        managelist.contains(presentUserId)
    }
    
    func isPresenterOnSeat() -> Bool {
        if let _ = seatInfolist.first(where: { info in
            info.userId == presentUserId
        }) {
            return true
        }
        return false
    }
}

class VoiceRoomUserOperationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var dependency: VoiceRoomUserOperationDependency
    weak var delegate:VoiceRoomUserOperationProtocol?
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
    private lazy var seatIndexLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 13)
        instance.textColor = R.color.hexDFDFDF()
        instance.text = ""
        return instance
    }()
    private lazy var giftButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        instance.setTitle("送礼物", for: .normal)
        instance.setTitleColor(UIColor.white, for: .normal)
        instance.layer.cornerRadius = 22
        instance.backgroundColor = R.color.hexEF499A()
        instance.addTarget(self, action: #selector(handleSendGift), for: .touchUpInside)
        return instance
    }()
    private lazy var sendMessageButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        instance.setTitle("发私信", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 22
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = R.color.hexEF499A()?.cgColor
        instance.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return instance
    }()
    private lazy var followButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        instance.setTitle("关注", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 22
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = R.color.hexEF499A()?.cgColor
        instance.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
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
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView()
        instance.distribution = .fillEqually
        instance.backgroundColor = R.color.hex03062F()?.withAlphaComponent(0.16)
        return instance
    }()
    private lazy var pickUpButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("邀请上麦", for: .normal)
        instance.setImage(R.image.pick_user_up_seat_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handlePickUpUser), for: .touchUpInside)
        return instance
    }()
    private lazy var pickDownButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("抱下麦", for: .normal)
        instance.setImage(R.image.pick_user_down_seat_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handlekickUserOut), for: .touchUpInside)
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
    private lazy var kickoutButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("踢出房间", for: .normal)
        instance.setImage(R.image.kick_out_room_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handleKickOut), for: .touchUpInside)
        return instance
    }()
    private var isFollow = false
    
    init(dependency: VoiceRoomUserOperationDependency, delegate: VoiceRoomUserOperationProtocol?) {
        self.dependency = dependency
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        fetchUserInfo()
        setupButtonState()
        setupManagerButton()
        setupStackView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.popMenuClip(corners: [.topLeft, .topRight], cornerRadius: 22, centerCircleRadius: 37)
        pickUpButton.alignImageAndTitleVertically(padding: 8)
        pickDownButton.alignImageAndTitleVertically(padding: 8)
        lockSeatButton.alignImageAndTitleVertically(padding: 8)
        muteButton.alignImageAndTitleVertically(padding: 8)
        kickoutButton.alignImageAndTitleVertically(padding: 8)
        manageButton.roundCorners(corners: [.bottomLeft, .topRight], radius: 22)
    }
    
    private func fetchUserInfo() {
        UserInfoDownloaded.shared.refreshUserInfo(userId: dependency.presentUserId) { [weak self] user in
            guard let self = self else { return }
            self.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: R.image.default_avatar())
            self.nameLabel.text = user.userName
            self.isFollow = user.isFollow
            self.followButton.setTitle(self.isFollow ? "已关注" : "关注", for: .normal)
        }
    }
    
    @objc private func setManager() {
        let setManager = !self.dependency.isPrsenterManager()
        let roomId = dependency.room.roomId
        let userId = dependency.presentUserId
        let api = RCNetworkAPI.setRoomManager(roomId: roomId, userId: userId, isManager: setManager)
        networkProvider.rx.request(api)
            .asObservable()
            .filterSuccessfulStatusCodes()
            .map(AppResponse.self)
            .subscribe(onNext: {
                [weak self] response in
                guard let self = self else { return }
                guard response.code == 10000 else {
                    return SVProgressHUD.showError(withStatus: "观众不在房间内，操作失败")
                }
                self.setupManagerButton()
                self.delegate?.didSetManager(userId: self.dependency.presentUserId, isManager: setManager)
            }).disposed(by: disposeBag)
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(avatarImageView)
        container.addSubview(nameLabel)
        container.addSubview(seatIndexLabel)
        container.addSubview(giftButton)
        container.addSubview(sendMessageButton)
        container.addSubview(followButton)
        container.addSubview(stackView)
        container.addSubview(manageButton)
        
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
        
        seatIndexLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.centerX.equalToSuperview()
        }
        
        giftButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18.resize)
            make.height.equalTo(44.resize)
            make.width.equalTo(104.resize)
            make.top.equalTo(nameLabel.snp.bottom).offset(30.resize)
        }
        
        sendMessageButton.snp.makeConstraints { make in
            make.size.equalTo(giftButton)
            make.centerY.equalTo(giftButton)
            make.centerX.equalToSuperview()
        }
        
        followButton.snp.makeConstraints { make in
            make.size.equalTo(giftButton)
            make.centerY.equalTo(giftButton)
            make.right.equalToSuperview().inset(18.resize)
        }
        
        if shouldShowFunctionMenu() {
            stackView.snp.makeConstraints {
                $0.top.equalTo(giftButton.snp.bottom).offset(25)
                $0.height.equalTo(135)
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        } else {
            sendMessageButton.snp.remakeConstraints { make in
                make.size.equalTo(giftButton)
                make.centerY.equalTo(giftButton)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(25)
            }
        }
        
        manageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(37)
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 45))
        }
    }
    
    private func shouldShowFunctionMenu() -> Bool {
        if dependency.currentUserRoleType == .creator {
            return true
        }
        if dependency.currentUserRoleType == .manager, dependency.presentUserRoleType == .audience {
            return true
        }
        return false
    }
    
    private func setupStackView() {
        guard let scene = HomeItem(rawValue: dependency.room.roomType ?? 1) else { return }
        let buttonlist: [UIButton] = {
            switch dependency.currentUserRoleType {
            case .creator:
                switch scene {
                case .audioRoom:
                    if dependency.isPresenterOnSeat() {
                        return [pickDownButton, lockSeatButton, muteButton, kickoutButton]
                    } else {
                        return [pickUpButton, kickoutButton]
                    }
                case .videoCall, .audioCall: return []
                case .radioRoom: return [kickoutButton]
                case .liveVideo:
                    if dependency.isPresenterOnSeat() {
                        return [pickDownButton, kickoutButton]
                    } else {
                        return [pickUpButton, kickoutButton]
                    }
                }
            case .manager:
                guard
                    dependency.currentUserRoleType == .manager,
                    dependency.presentUserRoleType == .audience
                else { return [] }
                switch scene {
                case .audioRoom, .liveVideo:
                    if dependency.isPresenterOnSeat() {
                        return [pickDownButton, kickoutButton]
                    } else {
                        return [pickUpButton, kickoutButton]
                    }
                case .videoCall: return []
                case .audioCall: return []
                case .radioRoom: return [kickoutButton]
                }
            case .audience:
                return []
            }
        }()
        buttonlist.forEach { button in
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setupManagerButton() {
        dismiss(animated: true, completion: nil)
        if dependency.isPrsenterManager() {
            manageButton.setImage(R.image.full_star(), for: .normal)
            manageButton.setTitle("撤回管理", for: .normal)
        } else {
            manageButton.setImage(R.image.empty_star(), for: .normal)
            manageButton.setTitle("设为管理", for: .normal)
        }
        manageButton.isHidden = !(dependency.currentUserRoleType == .creator)
    }
    
    private func setupButtonState() {
        guard let seatInfo = dependency.relativeSeatInfo, let seatIndex = dependency.relativeSeatIndex else {
            return
        }
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
        seatIndexLabel.isHidden = seatIndex == 0
    }
    
    @objc private func handleSendGift() {
        dismiss(animated: true, completion: nil)
        delegate?.didClickedSendGift(userId: dependency.presentUserId)
    }
    
    @objc private func handleSendMessage() {
        dismiss(animated: true, completion: nil)
        delegate?.didClickedPrivateChat(userId: dependency.presentUserId)
    }
    
    @objc private func handleFollow() {
        let userId = dependency.presentUserId
        let follow = !isFollow
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
    
    private func onFollow(_ userId: String, follow: Bool) {
        isFollow = follow
        followButton.setTitle(follow ? "已关注" : "关注", for: .normal)
        delegate?.didFollow(userId: userId, isFollow: isFollow)
    }
    
    @objc private func handlePickUpUser() {
        dismiss(animated: true, completion: nil)
        delegate?.didClickedInvite(userId: dependency.presentUserId)
    }
    
    @objc private func handlekickUserOut() {
        guard let seatIndex = dependency.relativeSeatIndex else {
            return
        }
        delegate?.kickUserOffSeat(seatIndex: UInt(seatIndex))
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLockSeat() {
        guard let seatInfo = dependency.relativeSeatInfo, let seatIndex = dependency.relativeSeatIndex else {
            return
        }
        if seatInfo.status == .locking {
            delegate?.lockSeatDidClick(isLock: false, seatIndex: UInt(seatIndex))
        } else {
            delegate?.lockSeatDidClick(isLock: true, seatIndex: UInt(seatIndex))
        }
        setupButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleMuteSeat() {
        guard
            let seatInfo = dependency.relativeSeatInfo,
            let seatIndex = dependency.relativeSeatIndex
        else { return }
        delegate?.muteSeat(isMute: !seatInfo.isMuted, seatIndex: UInt(seatIndex))
        setupButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleKickOut() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.kickoutRoom(userId: self.dependency.presentUserId)
        }
    }
}

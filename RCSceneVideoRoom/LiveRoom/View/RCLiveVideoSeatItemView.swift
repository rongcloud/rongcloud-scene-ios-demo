//
//  RCLiveVideoSeatView.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/15.
//

import Pulsator
import CoreGraphics
import UIKit

class RCLiveVideoSeatItemView: UIView {
    private lazy var addImageView = UIImageView(image: R.image.live_seat_add())
    private lazy var lockImageView = UIImageView(image: R.image.lock_seat_icon())
    private lazy var muteImageView = UIImageView(image: R.image.mute_microphone_icon())
    private lazy var seatNameLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white.alpha(0.8)
        instance.font = .systemFont(ofSize: 12)
        return instance
    }()
    
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12.resize)
        instance.textColor = .white
        instance.text = "--"
        return instance
    }()
    
    private lazy var giftView = UIView()
    private lazy var giftImageView = UIImageView(image: R.image.gift_value())
    private lazy var giftLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9.resize)
        instance.textColor = .white
        instance.text = "0"
        return instance
    }()
    
    private lazy var avatarImageView = UIImageView(image: R.image.default_avatar())
    private lazy var avatarBgImageView = UIImageView(image: R.image.default_avatar())
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .regular)
        return UIVisualEffectView(effect: blur)
    }()
    private lazy var radarView: Pulsator = {
        let instance = Pulsator()
        instance.numPulse = 4
        instance.radius = 40.resize
        instance.fromValueForRadius = 23.0 / 40
        instance.animationDuration = 0.8
        instance.backgroundColor = UIColor(hexString: "#FF69FD").cgColor
        instance.repeatCount = 2
        return instance
    }()
    
    private let room: VoiceRoom
    private let seatInfo: RCLiveVideoSeat
    
    init(_ room: VoiceRoom, seatInfo: RCLiveVideoSeat) {
        self.room = room
        self.seatInfo = seatInfo
        super.init(frame: .zero)
        setupGesture()
        setupUI()
        setupSeatName()
        setupHostView()
        seatInfo.delegate = self
        NotificationNameGiftUpdate.addObserver(self, selector: #selector(updateGiftInfo(_:)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        radarView.position = avatarImageView.center
    }
    
    private func setupUI() {
        layer.masksToBounds = true
        if RCLiveVideoEngine.shared().currentMixType != .oneToOne {
            layer.borderWidth = 1
        }
        layer.borderColor = UIColor(byteRed: 24, green: 25, blue: 26).cgColor

        addSubview(avatarBgImageView)
        addSubview(blurView)
        layer.addSublayer(radarView)
        addSubview(avatarImageView)
        
        avatarBgImageView.contentMode = .scaleAspectFill
        avatarBgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.masksToBounds = true
        setupAvatarImageView()
        
        addSubview(addImageView)
        addImageView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(snp.centerY)
            make.width.height.equalTo(18)
        }
        
        addSubview(seatNameLabel)
        seatNameLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(addImageView.snp.bottom).offset(8)
        }
        
        addSubview(lockImageView)
        lockImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addSubview(muteImageView)
        muteImageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
        }
        
        addSubview(nameLabel)
        addSubview(giftView)
        giftView.addSubview(giftImageView)
        giftView.addSubview(giftLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(giftView)
            make.bottom.equalTo(giftView.snp.top).offset(-2)
            make.right.lessThanOrEqualToSuperview().offset(-4)
        }
        
        giftView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        giftView.layer.cornerRadius = 7
        giftView.layer.masksToBounds = true
        giftView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(4)
            make.height.equalTo(14)
        }
        
        giftImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(giftImageView.snp.height)
        }
        
        giftLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(giftImageView.snp.right).offset(4)
            make.right.equalToSuperview().offset(-7)
        }
        
        refreshUI()
    }
    
    private func refreshUI() {
        subviews.forEach { $0.isHidden = true }
        radarView.isHidden = true
        if seatInfo.userId.count == 0 {
            configNoUserUI()
        } else {
            configUserUI()
        }
    }
    
    private func configNoUserUI() {
        backgroundColor = UIColor(byteRed: 49, green: 51, blue: 99)
        addImageView.isHidden = seatInfo.lock
        seatNameLabel.isHidden = seatInfo.lock
        lockImageView.isHidden = !seatInfo.lock
        muteImageView.isHidden = !seatInfo.mute
    }
    
    private func configUserUI() {
        giftView.isHidden = false
        nameLabel.isHidden = false
        backgroundColor = .clear
        muteImageView.isHidden = !seatInfo.mute
        
        blurView.isHidden = seatInfo.userEnableVideo
        radarView.isHidden = seatInfo.userEnableVideo
        avatarImageView.isHidden = seatInfo.userEnableVideo
        avatarBgImageView.isHidden = seatInfo.userEnableVideo
        
        updateUserInfo()
    }
    
    private func updateUserInfo() {
        UserInfoDownloaded.shared.fetchUserInfo(userId: seatInfo.userId) { [weak self] user in
            self?.nameLabel.text = user.userName
            self?.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                              placeholder: R.image.default_avatar())
            self?.avatarBgImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                                placeholder: R.image.default_avatar())
            self?.giftLabel.text = "\(LiveVideoGiftManager.shared.giftInfo[user.userId] ?? 0)"
        }
    }
    
    @objc private func updateGiftInfo(_ notification: Notification) {
        if seatInfo.userId.count == 0 { return }
        let count = LiveVideoGiftManager.shared.giftInfo[seatInfo.userId] ?? 0
        giftLabel.text = "\(count)"
    }
}

extension RCLiveVideoSeatItemView {
    private func setupAvatarImageView() {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne:
            avatarImageView.layer.cornerRadius = 23.resize
            avatarImageView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().multipliedBy(2.0 / 3)
                make.width.height.equalTo(46.resize)
            }
            radarView.radius = 40.resize
        case .oneToSix:
            if room.userId == seatInfo.userId {
                avatarImageView.layer.cornerRadius = 50.resize
                avatarImageView.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().multipliedBy(0.5)
                    make.width.height.equalTo(100.resize)
                }
                radarView.radius = 85.resize
            } else {
                avatarImageView.layer.cornerRadius = 23.resize
                avatarImageView.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(10.resize)
                    make.width.height.equalTo(46.resize)
                }
                radarView.radius = 40.resize
            }
        case .gridTwo:
            avatarImageView.layer.cornerRadius = 50.resize
            avatarImageView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(100.resize)
            }
            radarView.radius = 85.resize
        case .gridThree, .gridFour:
            avatarImageView.layer.cornerRadius = 40.resize
            avatarImageView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(80.resize)
            }
            radarView.radius = 70.resize
        default:
            avatarImageView.layer.cornerRadius = 30.resize
            avatarImageView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(20.resize)
                make.width.height.equalTo(60.resize)
            }
            radarView.radius = 50.resize
        }
    }
}

extension RCLiveVideoSeatItemView {
    private func setupSeatName() {
        if room.userId == Environment.currentUserId {
            seatNameLabel.text = "邀请连麦"
        } else {
            seatNameLabel.text = "\(seatInfo.index)号麦位"
        }
    }
    
    private func setupHostView() {
        guard room.userId == seatInfo.userId else { return }
        giftView.removeFromSuperview()
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne, .oneToSix:
            nameLabel.removeFromSuperview()
        default:
            addSubview(nameLabel)
            nameLabel.snp.remakeConstraints { make in
                make.left.bottom.equalToSuperview().inset(4)
                make.right.lessThanOrEqualToSuperview().offset(-4)
            }
        }
    }
}

extension RCLiveVideoSeatItemView {
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func tapHandler() {
        if let controller = controller as? LiveVideoRoomViewController {
            seatTapHandler(controller)
        } else if let controller = controller as? LiveVideoRoomHostController {
            seatTapHandler(controller)
        }
    }
    
    private func seatTapHandler(_ controller: LiveVideoRoomHostController) {
        if seatInfo.userId.count == 0 {
            let alertController = RCLVRSeatAlertEmptyViewController(seatInfo)
            controller.present(alertController, animated: false)
        } else if seatInfo.userId == Environment.currentUserId {
            if RCLiveVideoEngine.shared().currentMixType != .oneToOne {
                let alertController = RCLVRSeatAlertHostViewController(seatInfo)
                controller.present(alertController, animated: false)
            }
        } else {
            let alertController = RCLVRSeatAlertUserViewController(seatInfo.userId)
            alertController.userDelegate = controller
            controller.present(alertController, animated: false)
        }
    }
    
    private func seatTapHandler(_ controller: LiveVideoRoomViewController) {
        if seatInfo.lock { return SVProgressHUD.showError(withStatus: "该座位已锁定") }
        if seatInfo.userId.count == 0 {
            switch controller.micButton.micState {
            case .request: controller.requestSeat(seatInfo.index)
            case .waiting: controller.waitingSeat()
            case .connecting:
                if seatInfo.userId == Environment.currentUserId {
                    controller.connectingSeat()
                } else if seatInfo.userId.count == 0 {
                    controller.switchSeat(seatInfo)
                } else {
                    controller.otherUserSeat(seatInfo)
                }
            default: SVProgressHUD.showError(withStatus: "未知操作")
            }
        } else if seatInfo.userId == Environment.currentUserId {
            let alertController = RCLVRAlertConnectingViewController(seatInfo)
            alertController.delegate = controller
            controller.present(alertController, animated: false)
        } else {
            if needShowSeatUserAlert() {
                let alertController = RCLVRSeatAlertUserViewController(seatInfo.userId)
                alertController.userDelegate = controller
                controller.present(alertController, animated: false)
            }
        }
    }
    
    private func needShowSeatUserAlert() -> Bool {
        guard room.userId == seatInfo.userId else { return true }
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne, .oneToSix: return false
        default: return true
        }
    }
}

extension RCLiveVideoSeatItemView: RCLiveVideoSeatDelegate {
    func seat(_ seat: RCLiveVideoSeat, didLock isLocked: Bool) {
        refreshUI()
        SceneRoomManager.updateLiveSeatList()
    }
    
    func seat(_ seat: RCLiveVideoSeat, didMute isMuted: Bool) {
        refreshUI()
    }
    
    func seat(_ seat: RCLiveVideoSeat, didUserEnableAudio enable: Bool) {
        refreshUI()
    }
    
    func seat(_ seat: RCLiveVideoSeat, didUserEnableVideo enable: Bool) {
        refreshUI()
    }
    
    func seat(_ seat: RCLiveVideoSeat, didSpeak audioLevel: Int) {
        if audioLevel > 0 { radarView.start() }
        debugPrint("didSpeak \(audioLevel) atIndex: \(seat.index)")
    }
}

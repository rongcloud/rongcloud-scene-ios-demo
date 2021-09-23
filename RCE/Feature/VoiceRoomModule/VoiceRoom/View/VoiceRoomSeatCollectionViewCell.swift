//
//  VoiceRoomSeatCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import Reusable
import Pulsator

class VoiceRoomSeatCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var gradientLayer: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.colors = [R.color.hex505DFF()!.cgColor, R.color.hexE92B88()!.cgColor]
        instance.startPoint = CGPoint(x: 0, y: 0)
        instance.endPoint = CGPoint(x: 1, y: 1)
        instance.cornerRadius = 29.resize
        instance.masksToBounds = true
        return instance
    }()
    private lazy var radarView: Pulsator = {
        let instance = Pulsator()
        instance.numPulse = 4
        instance.radius = 60.resize
        instance.animationDuration = 1.5
        instance.backgroundColor = UIColor(hexString: "#FF69FD").cgColor
        return instance
    }()
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 28.resize
        instance.image = R.image.circle_bg()
        return instance
    }()
    private lazy var borderImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = R.image.gradient_border()
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 10)
        instance.textColor = .white
        instance.text = " "
        return instance
    }()
    private lazy var giftView: GiftValueView = {
        let instance = GiftValueView(frame: .zero)
        return instance
    }()
    private lazy var muteMicrophoneImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.mute_microphone_icon()
        return instance
    }()
    private lazy var seatViewContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var starImageView: UIImageView = {
        let instance = UIImageView(image: R.image.full_star())
        return instance
    }()
    private lazy var seatView: SeatIndexView = {
        let instance = SeatIndexView()
        return instance
    }()
    private lazy var statusImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = nil
        return instance
    }()
    private var seatInfo: RCVoiceSeatInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(radarView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(giftView)
        contentView.addSubview(muteMicrophoneImageView)
        contentView.addSubview(seatViewContainer)
        contentView.addSubview(starImageView)
        contentView.addSubview(borderImageView)
        seatViewContainer.addSubview(seatView)
        avatarImageView.addSubview(statusImageView)
        
        avatarImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 56.resize, height: 56.resize))
            $0.top.left.right.equalToSuperview().inset(2)
        }
        
        borderImageView.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(14)
        }
        
        giftView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview()
        }
        
        muteMicrophoneImageView.snp.makeConstraints {
            $0.right.bottom.equalTo(avatarImageView)
        }
        
        seatViewContainer.snp.makeConstraints {
            $0.top.equalTo(nameLabel)
            $0.bottom.equalTo(giftView)
            $0.left.right.equalToSuperview()
        }
        
        seatView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        statusImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        starImageView.snp.makeConstraints { make in
            make.right.equalTo(nameLabel.snp.left)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        radarView.position = avatarImageView.center
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 58.resize, height: 58.resize)
        gradientLayer.position = avatarImageView.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        radarView.stop()
    }
    
    public func update(seatInfo: RCVoiceSeatInfo, index: Int, managerlist: [VoiceRoomUser], giftValues: [String: Int]) {
        self.seatInfo = seatInfo
        switch seatInfo.status {
        case .using: ()
        case .empty:
            statusImageView.image = R.image.plus_user_to_seat_icon()
        case .locking:
            statusImageView.image = R.image.lock_seat_icon()
        @unknown default:
          ()
        }
        let userExist = (seatInfo.userId != nil)
        borderImageView.isHidden = !userExist
        statusImageView.isHidden = userExist
        giftView.isHidden = !userExist
        seatViewContainer.isHidden = userExist
        nameLabel.isHidden = !userExist
        gradientLayer.isHidden = !userExist
        seatView.update(index: index)
        muteMicrophoneImageView.isHidden = !seatInfo.isMuted
        if let userId = seatInfo.userId {
            starImageView.isHidden = !(managerlist.contains { $0.userId == userId })
            //avatarImageView.image = R.image.default_avatar()
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
                self?.nameLabel.text = user.userName
                self?.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: R.image.default_avatar(), completionHandler: { result in
                    if self?.seatInfo?.userId == seatInfo.userId { return }
                    self?.avatarImageView.image = nil
                })
            }
            giftView.update(value: giftValues[userId] ?? 0)
        } else {
            avatarImageView.image = R.image.circle_bg()
            starImageView.isHidden = true
        }
        layer.insertSublayer(radarView, at: 0)
    }
    
    static func cellSize() -> CGSize {
        let cell = VoiceRoomSeatCollectionViewCell()
        return cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func setSpeakingState(isSpeaking: Bool) {
        let isMuted = seatInfo?.isMuted ?? true
        guard isSpeaking, seatInfo?.status == .using, !isMuted else {
            self.radarView.stop()
            return
        }
        if radarView.isPulsating {
            return
        } else {
            radarView.start()
        }
    }
}

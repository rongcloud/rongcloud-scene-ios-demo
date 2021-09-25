//
//  RCRadioRoomOwnerView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/16.
//

import Pulsator

protocol RCRadioRoomOwnerViewProtocol: AnyObject {
    func masterViewDidClick()
}

class RCRadioRoomOwnerView: UIView {
    weak var delegate: RCRadioRoomOwnerViewProtocol?
    private lazy var radarView: Pulsator = {
        let instance = Pulsator()
        instance.numPulse = 4
        instance.radius = 80.resize
        instance.animationDuration = 1.5
        instance.repeatCount = MAXFLOAT
        instance.backgroundColor = UIColor(hexString: "#FF69FD").cgColor
        return instance
    }()
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 40.resize
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
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        return instance
    }()
    private lazy var giftView: GiftValueView = {
        let instance = GiftValueView(frame: .zero)
        return instance
    }()
    private lazy var muteMicrophoneImageView: UIImageView = {
        let instance = UIImageView()
        instance.isHidden = true
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.mute_microphone_icon()
        return instance
    }()
    private(set) var seatInfo: RCVoiceSeatInfo?
    
    var giftValue: Int {
        return giftView.value
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(radarView)
        addSubview(avatarImageView)
        addSubview(borderImageView)
        addSubview(nameLabel)
        addSubview(giftView)
        addSubview(muteMicrophoneImageView)
        avatarImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 80.resize, height: 80.resize))
            $0.top.left.right.equalToSuperview().inset(2)
        }
        
        borderImageView.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
        
        muteMicrophoneImageView.snp.makeConstraints {
            $0.right.bottom.equalTo(avatarImageView)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        giftView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview()
        }
        
        isUserInteractionEnabled = true
        let ownerTap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        addGestureRecognizer(ownerTap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        radarView.position = avatarImageView.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleUserTap() {
        delegate?.masterViewDidClick()
    }
    
    func update(seat mute: Bool) {
        muteMicrophoneImageView.isHidden = !mute
        if mute, radarView.isPulsating { radarView.stop() }
    }
    
    func update(seat userId: String?) {
        if let userId = userId {
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
                self?.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: R.image.default_avatar())
                self?.nameLabel.text = user.userName
            }
        } else {
            self.avatarImageView.image = R.image.empty_seat_user_avatar()
            self.nameLabel.text = " "
        }
        radarView.isHidden = (userId == nil)
        borderImageView.isHidden = (userId == nil)
    }
    
    func update(radar speaking: Bool) {
        guard speaking else { return radarView.stop() }
        if radarView.isPulsating { return }
        radarView.start()
    }
    
    func update(gift value: Int) {
        giftView.update(value: value)
    }
}

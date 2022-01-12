//
//  VoiceRoomPKGiftView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/11.
//

import UIKit

class VoiceRoomPKGiftUserView: UIView {
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.layer.cornerRadius = 13
        instance.layer.borderWidth = 1.0
        instance.image = R.image.pk_seat_default_sofa()
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var rankLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 8)
        instance.textColor = .white
        return instance
    }()
    private lazy var rankBgImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.left_rank_bg()
        instance.isHidden = true
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(avatarImageView)
        avatarImageView.addSubview(rankBgImageView)
        rankBgImageView.addSubview(rankLabel)
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 26, height: 26))
            make.edges.equalToSuperview()
        }
        
        rankBgImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        rankLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func updateColor(_ color: UIColor) {
        avatarImageView.layer.borderColor = color.cgColor
    }
    
    func updateUser(user: PKSendGiftUser?, rank: Int, isLeft: Bool) {
        if let user = user {
            avatarImageView.kf.setImage(with: URL.potraitURL(portrait: user.portrait), placeholder: R.image.default_avatar())
            if isLeft {
                rankBgImageView.image = R.image.left_rank_bg()
            } else {
                rankBgImageView.image = R.image.right_rank_bg()
            }
            rankBgImageView.isHidden = false
            rankLabel.text = "\(rank)"
        } else {
            avatarImageView.image = R.image.pk_seat_default_sofa()
            rankBgImageView.isHidden = true
        }
    }
}

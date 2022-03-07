//
//  VoiceRoomGiftSeatCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

import Reusable
import Kingfisher

public struct VoiceRoomGiftSeat {
    let userId: String
    let userAvatar: String?
    let userMark: String
    var isSelected: Bool
    
    public mutating func setSelected(_ state: Bool) {
        isSelected = state
    }
}

final class VoiceRoomGiftSeatCell: UICollectionViewCell, Reusable {
    private lazy var avatarImageView = UIImageView()
    private lazy var nameView = UIView()
    private lazy var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameView)
        nameView.addSubview(nameLabel)
        
        avatarImageView.layer.cornerRadius = 17.5.resize
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.clear.cgColor
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2.resize)
            make.width.height.equalTo(35.resize)
        }
        
        nameView.layer.cornerRadius = 7.resize
        nameView.backgroundColor = UIColor(hexString: "#03062F").withAlphaComponent(0.4)
        nameView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(avatarImageView.snp.bottom)
            make.width.greaterThanOrEqualTo(16.resize)
            make.width.lessThanOrEqualTo(45.resize)
            make.height.equalTo(14.resize)
        }
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 10.resize)
        nameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-12.resize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(_ user: VoiceRoomGiftSeat) -> VoiceRoomGiftSeatCell {
        nameLabel.text = user.userMark
        if let urlString = user.userAvatar, let url = URL(string: urlString) {
            let processor = KingfisherOptionsInfoItem.processor(RoundCornerImageProcessor(cornerRadius: 17.5.resize))
            avatarImageView.kf.setImage(with: url,
                                        placeholder: R.image.default_avatar(),
                                        options: [processor])
        } else {
            avatarImageView.image = R.image.default_avatar()
        }
        avatarImageView.layer.borderColor =
            user.isSelected ? UIColor(hexString: "#E92B88").cgColor : UIColor.clear.cgColor
        nameView.backgroundColor =
            user.isSelected ? UIColor(hexString: "#E92B88") : UIColor(hexString: "#03062F").withAlphaComponent(0.4)
        return self
    }
}

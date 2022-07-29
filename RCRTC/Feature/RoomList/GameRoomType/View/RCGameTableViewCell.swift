//
//  RoomListTableViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import Reusable
import RCSceneRoom

class RCGameTableViewCell: UITableViewCell, Reusable {
    
    let gameTypeIcon = UIImageView()
    let gameTypeLabel = UILabel()

    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.shadowColor = UIColor(hexInt: 0xF4F5F6).withAlphaComponent(0.7).cgColor
        instance.layer.shadowOffset = CGSize(width: 1, height: 3)
        instance.layer.shadowRadius = 10
        return instance
    }()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white
        instance.layer.cornerRadius = 8
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var roomAvatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = nil
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 32
        return instance
    }()
    private lazy var genderImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = R.image.groom_man_icon()
        return instance
    }()
    private lazy var roomNameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .black
        return instance
    }()
    private lazy var gameTypeView: UIImageView = {
        let instance = UIImageView()
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        instance.layer.cornerRadius = 4.39
        instance.clipsToBounds = true
        
        gameTypeIcon.contentMode = .scaleAspectFill
        gameTypeIcon.image = R.image.groom_demo_icon()
        gameTypeIcon.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        gameTypeIcon.layer.cornerRadius = 4.39
        gameTypeIcon.clipsToBounds = true
        
        gameTypeLabel.font = .systemFont(ofSize: 10)
        gameTypeLabel.textColor = UIColor(hexString: "#5F6084")
        gameTypeLabel.text = "你画我猜"
        gameTypeLabel.textAlignment = .center
        gameTypeLabel.frame = CGRect(x: 24, y: 0, width: 81-24, height: 24)

        instance.addSubview(gameTypeIcon)
        instance.addSubview(gameTypeLabel)
        return instance
    }()
    private lazy var userNameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = UIColor(hexString: "#BBC0CA")
        instance.text = "- -"
        return instance
    }()
    private lazy var lockImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.private_room_icon()
        return instance
    }()
    private lazy var userNumberImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.groom_user_number_icon()
        return instance
    }()
    private lazy var userNumberLabel: UILabel = {
        let instance = UILabel()
        instance.font = .boldSystemFont(ofSize: 11)
        instance.textColor = UIColor(hexString: "#566074",alpha: 0.6)
        instance.text = "- -"
        return instance
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(shadowView)
        contentView.addSubview(container)
        container.addSubview(roomAvatarImageView)
        container.addSubview(roomNameLabel)
        container.addSubview(gameTypeView)
        container.addSubview(genderImageView)
//        container.addSubview(userNameLabel)
        container.addSubview(lockImageView)
        container.addSubview(userNumberImageView)
        container.addSubview(userNumberLabel)
        
        container.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20.resize)
            make.top.bottom.equalToSuperview().inset(6)
        }
        
        roomAvatarImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 64, height: 64))
            make.top.bottom.equalToSuperview().inset(16.resize)
            make.left.equalToSuperview().offset(16.resize)
        }
        
        genderImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 23.5, height: 23.5))
            make.top.equalToSuperview().inset(59.resize)
            make.left.equalToSuperview().offset(63.resize)
        }
        
        roomNameLabel.snp.makeConstraints { make in
            make.left.equalTo(roomAvatarImageView.snp.right).offset(16.resize)
            make.top.equalToSuperview().offset(26.resize)
        }
        
        gameTypeView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20.resize)
            make.size.equalTo(CGSize(width: 81, height: 22))
            make.left.equalTo(roomNameLabel)
        }
        
//        userNameLabel.snp.makeConstraints { make in
//            make.left.equalTo(gameTypeView.snp.right).offset(8.resize)
//            make.centerY.equalTo(gameTypeView)
//        }
        
        lockImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14.resize)
            make.right.equalToSuperview().inset(12.resize)
        }
        
        userNumberLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12.resize)
            make.bottom.equalToSuperview().inset(12.resize)
        }
        
        userNumberImageView.snp.makeConstraints { make in
            make.right.equalTo(userNumberLabel.snp.left).offset(-5)
            make.centerY.equalTo(userNumberLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateCell(room: RCSceneRoom) -> RCGameTableViewCell {
        if let portraitUrl = room.createUser?.portraitUrl {
            roomAvatarImageView.kf.setImage(with: URL(string: portraitUrl), placeholder: R.image.room_background_image1())
        }
        
        
        if let sex = room.createUser?.sex {
            genderImageView.image = sex == "女" ? R.image.groom_woman_icon() : R.image.groom_man_icon()
        }
        
        roomNameLabel.text = room.roomName
        lockImageView.isHidden = (room.isPrivate == 0)
        userNumberLabel.text = "\(room.userTotal)"
        if let gameInfo = room.gameResp {
            gameTypeLabel.text = gameInfo.gameName
            gameTypeIcon.kf.setImage(with: URL(string: gameInfo.thumbnail))
        }
        return self
    }
}

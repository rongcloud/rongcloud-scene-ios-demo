//
//  FriendCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import Reusable
import Kingfisher

protocol FriendCellDelegate: AnyObject {
    func didClickAvatar(_ user: VoiceRoomUser)
    func didClickFollow(_ user: VoiceRoomUser, value: Int)
}

final class FriendCell: UITableViewCell, Reusable {
    
    private weak var delegate: FriendCellDelegate?
    private var user: VoiceRoomUser?
    private var currentType = FriendType.fans
    
    private lazy var avatarButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.default_avatar(), for: .normal)
        instance.imageView?.contentMode = .scaleAspectFill
        instance.addTarget(self, action: #selector(didClickAvatar), for: .touchUpInside)
        return instance
    }()
    
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        instance.textColor = UIColor(byteRed: 3, green: 0, blue: 58)
        return instance
    }()
    
    private lazy var relationButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        instance.addTarget(self, action: #selector(didClickFollow), for: .touchUpInside)
        return instance
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor(red: 0.965, green: 0.973, blue: 0.976, alpha: 1)
        contentView.addSubview(avatarButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(relationButton)
        
        avatarButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21.5)
            make.width.height.equalTo(48)
            make.top.bottom.equalToSuperview().inset(8)
        }
        avatarButton.layer.cornerRadius = 24
        avatarButton.layer.masksToBounds = true
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(avatarButton.snp.right).offset(12)
            make.right.lessThanOrEqualTo(relationButton.snp.left).offset(-12)
        }
        
        relationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-19)
            make.centerY.equalToSuperview()
            make.width.equalTo(84)
            make.height.equalTo(32)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didClickAvatar() {
        guard let user = user else { return }
        delegate?.didClickAvatar(user)
    }
    
    @objc private func didClickFollow() {
        guard let user = user else { return }
        var value: Int {
            if currentType == .fans {
                return user.relation == 1 ? 0 : 1
            }
            return user.relation == -1 ? user.status! : -1
        }
        delegate?.didClickFollow(user, value: value)
    }
    
    func update(_ user: VoiceRoomUser, type: FriendType, delegate: FriendCellDelegate) -> Self {
        self.delegate = delegate
        self.currentType = type
        self.user = user
        nameLabel.text = user.userName
        updateFriend(user, type: type)
        avatarButton.kf.setImage(with: URL(string: user.portraitUrl), for: .normal)
        return self
    }
    
    private func updateFriend(_ user: VoiceRoomUser, type: FriendType) {
        let status = user.relation
        let size = CGSize(width: 84, height: 32)
        let image = UIGraphicsImageRenderer(size: size)
            .image { renderer in
                if type == .fans, status == 0 {
                    let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 4)
                    renderer.cgContext.addPath(path.cgPath)
                    UIColor(byteRed: 121, green: 131, blue: 254).setFill()
                    renderer.cgContext.fillPath()
                } else {
                    let boundRect = CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5)
                    let path = UIBezierPath(roundedRect: boundRect, cornerRadius: 4)
                    renderer.cgContext.addPath(path.cgPath)
                    renderer.cgContext.setLineWidth(1)
                    UIColor(byteRed: 3, green: 0, blue: 58, alpha: 0.5).setStroke()
                    renderer.cgContext.strokePath()
                }
            }
        relationButton.setBackgroundImage(image, for: .normal)
        
        let title: String = {
            if status == 1 {
                return "互相关注"
            }
            if status == -1 {
                return "+关注"
            }
            if type == .fans {
                return "回关"
            } else {
                return "已关注"
            }
        }()
        relationButton.setTitle(title, for: .normal)
        let onlyFans = status == 0 && type == .fans
        let buttonColor = onlyFans ? .white : UIColor(byteRed: 3, green: 0, blue: 58)
        relationButton.setTitleColor(buttonColor, for: .normal)
    }
}

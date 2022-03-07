//
//  DialHistoryTableViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import UIKit
import Reusable
import Kingfisher
import RCSceneService

class DialHistoryTableViewCell: UITableViewCell, Reusable {
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = nil
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 48.resize/2
        return instance
    }()
    private lazy var bgImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleToFill
        instance.image = R.image.dial_customer_bg()
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var contactImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.custom_service_contact()
        return instance
    }()
    private lazy var phoneLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instance.textColor = UIColor(hexString: "#020037")
        return instance
    }()
    private lazy var weekLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 13)
        instance.textColor = UIColor(hexString: "#BBC0CA")
        return instance
    }()
    private lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E3E5E6")
        return instance
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        contentView.backgroundColor = UIColor(hexString: "#F5F6F9")
        contentView.addSubview(bgImageView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(weekLabel)
        contentView.addSubview(contactImageView)
        contentView.addSubview(separatorline)
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48.resize, height: 48.resize))
            make.left.equalToSuperview().offset(17.resize)
            make.top.bottom.equalToSuperview().inset(12.resize)
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(12.resize)
            make.centerY.equalToSuperview()
        }
        
        weekLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12.resize)
            make.centerY.equalToSuperview()
        }
        
        contactImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12.resize)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 70, height: 29))
        }
        
        separatorline.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    public func updateCell(history: DialHistory) {
        separatorline.isHidden = false
        bgImageView.isHidden = true
        contactImageView.isHidden = true
        phoneLabel.text = history.number
        avatarImageView.image = R.image.default_avatar()
        UserInfoDownloaded.shared.fetchUserInfo(userId: history.userId) { [weak self] user in
            guard let self = self, let url = URL(string: user.portraitUrl) else { return }
            self.avatarImageView.kf.setImage(with: url, placeholder: R.image.default_avatar())
        }
        weekLabel.text = history.dateString
    }
}

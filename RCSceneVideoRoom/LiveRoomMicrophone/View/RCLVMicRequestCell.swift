//
//  RCLVMicRequestCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/8.
//

import UIKit
import Reusable
import RCSceneService
import Kingfisher

protocol RCLVMicRequestDelegate {
    func acceptMicRequest(_ user: VoiceRoomUser)
    func rejectMicRequest(_ user: VoiceRoomUser)
}

class RCLVMicRequestCell: UITableViewCell, Reusable {
    
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.layer.cornerRadius = (48.resize)/2
        instance.clipsToBounds = true
        instance.image = R.image.default_avatar()
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var acceptButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14.resize)
        instance.setTitle("接受", for: .normal)
        instance.layer.cornerRadius = 20.resize
        instance.addTarget(self, action: #selector(handleAccpetButtonClick), for: .touchUpInside)
        return instance
    }()
    private lazy var rejectButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14.resize)
        instance.setTitle("拒绝", for: .normal)
        instance.layer.cornerRadius = 20.resize
        instance.addTarget(self, action: #selector(handleRejectButtonClick), for: .touchUpInside)
        return instance
    }()
    private lazy var lineView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return instance
    }()
    private var user: VoiceRoomUser?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        backgroundColor = .clear
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(rejectButton)
        contentView.addSubview(lineView)
        
        avatarImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(23.resize)
            $0.top.bottom.equalToSuperview().inset(8.resize)
            $0.size.equalTo(CGSize(width: 48.resize, height: 48.resize))
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarImageView.snp.right).offset(12.resize)
            $0.centerY.equalToSuperview()
        }
        
        rejectButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(acceptButton.snp.left).offset(-12)
            make.size.equalTo(acceptButton)
        }
        
        acceptButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 64.resize, height: 40.resize))
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(23.resize)
        }
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.equalTo(avatarImageView.snp.right)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateCell(_ user: VoiceRoomUser) -> RCLVMicRequestCell {
        self.user = user
        nameLabel.text = user.userName
        let avatarURL = URL(string: user.portraitUrl)
        avatarImageView.kf.setImage(with: avatarURL, placeholder: R.image.default_avatar())
        return self
    }
    
    @objc func handleAccpetButtonClick() {
        guard let user = user else { return }
        guard let delegate = controller as? RCLVMicRequestDelegate else { return }
        delegate.acceptMicRequest(user)
    }
    
    @objc func handleRejectButtonClick() {
        guard let user = user else { return }
        guard let delegate = controller as? RCLVMicRequestDelegate else { return }
        delegate.rejectMicRequest(user)
    }
}

//
//  EditUserInfoViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/1.
//

import UIKit

class EditUserInfoViewController: UIViewController {
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white
        instance.layer.cornerRadius = 12
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = nil
        instance.layer.cornerRadius = 35
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var editIconImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.edit_user_avatar_icon()
        return instance
    }()
    private lazy var textField: UITextField = {
       let instance = UITextField()
        instance.textColor = UIColor(hexString: "#020037")
        instance.font = .systemFont(ofSize: 14)
        instance.backgroundColor = UIColor(hexString: "#F3F4F5")
        instance.layer.cornerRadius = 4
        instance.clipsToBounds = true
        instance.placeholder = "请输入用户名称"
        return instance
    }()
    private lazy var closeButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("关闭", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#020037"), for: .normal)
        return instance
    }()
    private lazy var saveButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("保存", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#7983FE"), for: .normal)
        return instance
    }()
    private lazy var logoutButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 15)
        instance.setTitle("退出登录", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#020037"), for: .normal)
        return instance
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        if let user = Environment.currentUser {
            if let url = user.portrait {
                avatarImageView.kf.setImage(with: URL(string: url), placeholder: R.image.default_avatar())
            }
            textField.text = user.userName
        }
    }
    
    private func buildLayout() {
        view.addSubview(container)
        container.addSubview(avatarImageView)
        container.addSubview(editIconImageView)
        container.addSubview(textField)
        container.addSubview(closeButton)
        container.addSubview(saveButton)
        container.addSubview(logoutButton)
        
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(40.resize)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25.resize)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 70, height: 70))
        }
        
        editIconImageView.snp.makeConstraints { make in
            make.right.bottom.equalTo(avatarImageView)
        }
        
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30.resize)
            make.height.equalTo(40)
            make.top.equalTo(avatarImageView.snp.bottom).offset(25.resize)
        }
        
        closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(56.resize)
            make.top.equalTo(textField.snp.bottom).offset(25.resize)
        }
        
        saveButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-56.resize)
            make.centerY.equalTo(closeButton)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(38.resize)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20.resize)
        }
    }
}

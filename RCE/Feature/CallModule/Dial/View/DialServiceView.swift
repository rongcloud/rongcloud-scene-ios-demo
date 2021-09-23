//
//  DialServiceView.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/29.
//

import UIKit

final class DialServiceView: UIView {
    
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.customer_service_avatar()
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
        instance.font = UIFont.systemFont(ofSize: 16.resize, weight: .medium)
        instance.text = "专属客户经理"
        instance.textColor = .white
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(service))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(bgImageView)
        addSubview(avatarImageView)
        addSubview(phoneLabel)
        addSubview(contactImageView)
        
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
        
        contactImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12.resize)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 70.resize, height: 29.resize))
        }
    }
    
    @objc private func service() {
        UIApplication.shared.open(URL(string: "tel://13161856839")!, options: [:]) { _ in }
    }
}

//
//  RoomNoticeView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import UIKit

class RoomNoticeView: UIView {
    private lazy var iconImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = nil
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = .white.withAlphaComponent(0.8)
        return instance
    }()
    
    init(icon: UIImage?, title: String) {
        super.init(frame: .zero)
        buildLayout()
        iconImageView.image = icon
        nameLabel.text = title
    }
    
    private func buildLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        addSubview(iconImageView)
        addSubview(nameLabel)
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(5)
            make.right.equalToSuperview().inset(7)
            make.top.bottom.equalToSuperview().inset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

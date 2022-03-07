//
//  VoiceRoomUserListEmptyView.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/10.
//

import UIKit

final class VoiceRoomUserListEmptyView: UIView {
    private lazy var imageView = UIImageView(image: R.image.voice_room_users_empty_icon())
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(snp.bottom).offset(-32.resize)
        }
        titleLabel.text = "暂无用户"
        titleLabel.textColor = UIColor.white.alpha(0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 16.resize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

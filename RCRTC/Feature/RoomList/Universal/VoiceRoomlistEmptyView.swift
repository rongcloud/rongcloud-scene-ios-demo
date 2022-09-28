//
//  VoiceRoomlistEmptyView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/1.
//

import UIKit

class VoiceRoomlistEmptyView: UIView {
    private lazy var emptyImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.roomlist_empty_icon()
        return instance
    }()
    private lazy var emptyLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = UIColor(hexString: "#AAB1BD")
        instance.text = "请创建房间"
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(emptyImageView)
        addSubview(emptyLabel)
        
        emptyImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyImageView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

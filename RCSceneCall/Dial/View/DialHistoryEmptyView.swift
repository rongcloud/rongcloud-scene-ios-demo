//
//  DialHistoryEmptyView.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/22.
//

import UIKit
import RCSceneModular

class DialHistoryEmptyView: UIView {
    
    private lazy var iconView = UIImageView(image: R.image.rc_call_empty_icon())
    private lazy var tipLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.systemFont(ofSize: 14.resize)
        instance.textColor = UIColor(byteRed: 236, green: 150, blue: 3)
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(byteRed: 255, green: 239, blue: 211)
        layer.cornerRadius = 18.resize
        layer.masksToBounds = true
        
        addSubview(iconView)
        addSubview(tipLabel)
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.resize)
            make.top.bottom.equalToSuperview().inset(6.resize)
            make.width.height.equalTo(24.resize)
        }
        
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(4.resize)
            make.right.equalToSuperview().offset(-20.resize)
            make.centerY.equalToSuperview()
        }
        if SceneRoomManager.scene == .audioCall {
            tipLabel.text = "拨号给已注册用户，发起RTC语音通话"
        } else {
            tipLabel.text = "拨号给已注册用户，发起RTC视频通话"
        }
    }
}

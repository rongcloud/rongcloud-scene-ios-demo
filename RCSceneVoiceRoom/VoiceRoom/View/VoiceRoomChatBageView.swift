//
//  VoiceRoomChatBageView.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/28.
//

import UIKit

final class VoiceRoomChatBageView: UIView {
    
    private lazy var countLabel = UILabel()
    
    private(set) var count = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 7.resize
        layer.masksToBounds = true
        backgroundColor = .red
        isHidden = true
        
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 10.resize)
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(4.resize)
            make.height.equalToSuperview()
            make.width.greaterThanOrEqualTo(6.resize)
            make.height.equalTo(14.resize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ count: Int) {
        self.count = count
        if count <= 0 {
            isHidden = true
            return
        }
        isHidden = false
        if count < 100 {
            countLabel.text = "\(count)"
        } else {
            countLabel.text = "···"
        }
    }
}

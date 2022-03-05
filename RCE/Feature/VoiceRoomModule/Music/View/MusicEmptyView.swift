//
//  MusicEmptyView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit

class MusicEmptyView: UIView {
    private lazy var tipsLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 13)
        instance.textColor = UIColor.white.withAlphaComponent(0.4)
        instance.text = "暂无歌曲，快去添加吧~"
        return instance
    }()
    private lazy var addButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("添加歌曲", for: .normal)
        instance.layer.cornerRadius = 20
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor.white.cgColor
        instance.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        return instance
    }()
    var callback:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tipsLabel)
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 40))
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(addButton.snp.top).offset(-22)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleButtonClick() {
        callback?()
    }
}

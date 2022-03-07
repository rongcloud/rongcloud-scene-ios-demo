//
//  SeatIndexView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/26.
//

import UIKit

class SeatIndexView: UIView {
    private lazy var indexLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 7)
        instance.textColor = UIColor.white.withAlphaComponent(0.8)
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        instance.layer.cornerRadius = 6.5
        instance.clipsToBounds = true
        instance.textAlignment = .center
        instance.text = "1"
        return instance
    }()
    private lazy var contentLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 10)
        instance.textColor = UIColor.white.withAlphaComponent(0.8)
        instance.backgroundColor = .clear
        instance.text = "号麦位"
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indexLabel)
        addSubview(contentLabel)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        layer.cornerRadius = 7
        clipsToBounds = true
        indexLabel.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(1)
            $0.size.equalTo(CGSize(width: 13, height: 13))
        }
        
        contentLabel.snp.makeConstraints {
            $0.left.equalTo(indexLabel.snp.right).offset(4)
            $0.right.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(index: Int) {
        indexLabel.text = "\(index)"
    }
}

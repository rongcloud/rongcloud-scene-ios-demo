//
//  GiftValueView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit

class GiftValueView: UIView {
    private lazy var heartImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.gift_value()
        return instance
    }()
    private lazy var valueLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = .white
        instance.text = "0"
        return instance
    }()
    var value: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heartImageView)
        addSubview(valueLabel)
        layer.cornerRadius = 7
        clipsToBounds = true
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        heartImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 14.resize, height: 14.resize))
            $0.left.bottom.top.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints {
            $0.left.equalTo(heartImageView.snp.right).offset(4)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(value: Int) {
        self.value = value
        valueLabel.text = "\(value)"
    }
}

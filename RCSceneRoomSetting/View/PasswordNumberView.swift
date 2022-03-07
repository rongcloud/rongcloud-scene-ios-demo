//
//  PasswordNumberView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/14.
//

import UIKit

public class PasswordNumberView: UIView {
    private lazy var lineView: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexE5E6E7()
        return instance
    }()
    private lazy var numberLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 30)
        instance.textColor = R.color.hex020037()
        instance.isHidden = true
        instance.textAlignment = .center
        instance.text = ""
        return instance
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lineView)
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(36.resize)
        }
        
        lineView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(text: String?) {
        if let letter = text {
            lineView.isHidden = true
            numberLabel.isHidden = false
            numberLabel.text = letter
        } else {
            lineView.isHidden = false
            numberLabel.isHidden = true
        }
    }
}

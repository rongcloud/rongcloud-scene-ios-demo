//
//  DialCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import UIKit
import Reusable

class DialCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var numberLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 25)
        instance.textColor = UIColor(hexString: "#020037")
        return instance
    }()
    private lazy var alphaLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 11)
        instance.textColor = UIColor(hexString: "#020037")
        return instance
    }()
    private lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E3E5E6")
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(alphaLabel)
        contentView.addSubview(separatorline)
        
        numberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(13)
        }
        
        alphaLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(7)
            make.centerX.equalToSuperview()
        }
        
        separatorline.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    func updateCell(item: DialKeyboardAction) {
        var alpha = ""
        switch item {
        case let .character(value):
            numberLabel.text = value
            alpha = ""
        case let .number(number):
            numberLabel.text = "\(number)"
            switch number {
            case 2:
                alpha = "ABC"
            case 3:
                alpha = "EDF"
            case 4:
                alpha = "GHI"
            case 5:
                alpha = "JKL"
            case 6:
                alpha = "MNO"
            case 7:
                alpha = "PQRS"
            case 8:
                alpha = "TUV"
            case 9:
                alpha = "WXYZ"
            default:
                alpha = ""
            }
        }
        alphaLabel.text = alpha
    }
}

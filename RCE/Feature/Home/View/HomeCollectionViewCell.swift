//
//  HomeCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import Reusable

class HomeCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var backgroundImageView = UIImageView()
    
    private lazy var coverView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#03062F").withAlphaComponent(0.4)
        instance.layer.cornerRadius = 16.resize
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 19, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var descLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12, weight: .regular)
        instance.textColor = .white
        instance.numberOfLines = 0
        return instance
    }()
    
    private lazy var comingLabel: UILabel = {
        let instance = UILabel()
        instance.numberOfLines = 0
        instance.font = .systemFont(ofSize: 14.resize, weight: .regular)
        instance.textColor = .white
        instance.text = "COMING\nSOON"
        instance.numberOfLines = 2
        instance.textAlignment = .center
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(coverView)
        contentView.addSubview(comingLabel)
        backgroundImageView.addSubview(titleLabel)
        backgroundImageView.addSubview(descLabel)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16.resize)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().inset(16)
        }
        
        coverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        comingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15.resize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(item: HomeItem) -> HomeCollectionViewCell {
        backgroundImageView.image = item.image
        coverView.isHidden = item.enabled
        comingLabel.isHidden = item.enabled
        titleLabel.text = item.name
        descLabel.text = item.desc
        if item == .audioRoom {
            titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(40.resize)
                make.left.equalToSuperview().offset(16.resize)
            }
            
            descLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
                make.left.equalTo(titleLabel)
                make.width.equalToSuperview().multipliedBy(0.5)
            }
        } else {
            titleLabel.snp.remakeConstraints { make in
                make.top.left.equalToSuperview().offset(16.resize)
            }
            
            descLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
                make.left.equalTo(titleLabel)
                make.right.equalToSuperview().inset(16)
            }
        }
        layoutIfNeeded()
        return self
    }
}

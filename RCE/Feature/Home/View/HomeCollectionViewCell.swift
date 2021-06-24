//
//  HomeCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import Reusable

class HomeCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var backgroundImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = nil
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 18.resize, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var descriptionLabel: UILabel = {
        let instance = UILabel()
        instance.numberOfLines = 0
        instance.font = .systemFont(ofSize: 12.resize, weight: .regular)
        instance.textColor = .white
        return instance
    }()
    
    private lazy var coverView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#03062F").withAlphaComponent(0.4)
        instance.layer.cornerRadius = 20.resize
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
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(coverView)
        contentView.addSubview(comingLabel)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16.resize)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(16.resize)
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
    
    func updateCell(item: HomeItem) {
        backgroundImageView.image = item.image
        nameLabel.text = item.name
        descriptionLabel.text = item.englishName
        coverView.isHidden = item.isEnable
    }
}

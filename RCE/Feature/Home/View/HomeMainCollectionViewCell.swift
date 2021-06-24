//
//  HomeCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import Reusable

class HomeMainCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var backgroundImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = nil
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 18, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var descriptionLabel: UILabel = {
        let instance = UILabel()
        instance.numberOfLines = 0
        instance.font = .systemFont(ofSize: 12, weight: .regular)
        instance.textColor = .white
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.resize)
            make.top.equalToSuperview().offset(50.resize)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16.resize)
            make.width.equalTo(156.resize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(item: HomeItem) {
        backgroundImageView.image = item.image
        nameLabel.text = item.name
        descriptionLabel.text = item.englishName
    }
}

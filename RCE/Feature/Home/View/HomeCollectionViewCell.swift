//
//  HomeCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import Reusable
import RCSceneFoundation
import RCSceneVoiceRoom

extension HomeItem {
    var image: UIImage? {
        switch self {
        case .audioRoom:
            return R.image.home_icon_voice_room()
        case .videoCall:
            return R.image.home_icon_video_call()
        case .audioCall:
            return R.image.home_icon_voice_call()
        case .radioRoom:
            return R.image.home_icon_radio_room()
        case .liveVideo:
            return R.image.home_icon_video_room()
        }
    }
    
    var markImage: UIImage? {
        switch self {
        case .audioRoom:
            return R.image.home_icon_pro()
        case .liveVideo:
            return R.image.home_icon_new()
        default:
            return nil
        }
    }
    
    var enabled: Bool {
        return true
    }
}

class HomeCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var itemImageView = UIImageView()
    private lazy var markImageView = UIImageView()
    
//    private lazy var titleLabel: UILabel = {
//        let instance = UILabel()
//        instance.font = .systemFont(ofSize: 19, weight: .medium)
//        instance.textColor = .white
//        return instance
//    }()
//    private lazy var descLabel: UILabel = {
//        let instance = UILabel()
//        instance.font = .systemFont(ofSize: 12, weight: .regular)
//        instance.textColor = .white
//        instance.numberOfLines = 0
//        return instance
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(itemImageView)
        contentView.addSubview(markImageView)
//        backgroundImageView.addSubview(titleLabel)
//        backgroundImageView.addSubview(descLabel)
        
        itemImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        markImageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.height.equalTo(54.resize)
        }
        
//        titleLabel.snp.makeConstraints { make in
//            make.top.left.equalToSuperview().offset(16.resize)
//        }
        
//        descLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
//            make.left.equalTo(titleLabel)
//            make.right.equalToSuperview().inset(16)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(item: HomeItem) -> HomeCollectionViewCell {
        itemImageView.image = item.image
        markImageView.image = item.markImage
//        titleLabel.text = item.name
//        descLabel.text = item.desc
//        if item == .audioRoom {
//            titleLabel.snp.remakeConstraints { make in
//                make.top.equalToSuperview().offset(40.resize)
//                make.left.equalToSuperview().offset(16.resize)
//            }
//
//            descLabel.snp.remakeConstraints { make in
//                make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
//                make.left.equalTo(titleLabel)
//                make.width.equalToSuperview().multipliedBy(0.5)
//            }
//        } else {
//            titleLabel.snp.remakeConstraints { make in
//                make.top.left.equalToSuperview().offset(16.resize)
//            }
//
//            descLabel.snp.remakeConstraints { make in
//                make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
//                make.left.equalTo(titleLabel)
//                make.right.equalToSuperview().inset(16)
//            }
//        }
//        layoutIfNeeded()
        return self
    }
}

//
//  VoiceRoomGiftCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/26.
//

import UIKit
import Reusable

struct VoiceRoomGift {
    let id: String
    let name: String
    let icon: String
    let price: Int
}

final class RCVRGiftBroadcastView: UIView {
    private lazy var broadcastLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(byteRed: 233, green: 43, blue: 136)
        layer.masksToBounds = true
        
        broadcastLabel.text = "全服广播"
        broadcastLabel.textColor = UIColor.white
        broadcastLabel.font = UIFont.systemFont(ofSize: 8.resize)
        addSubview(broadcastLabel)
        broadcastLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.left.right.equalToSuperview().inset(6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
}

final class VoiceRoomGiftCell: UICollectionViewCell, Reusable {
    private lazy var iconImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var priceView = UIView()
    private lazy var diamondImageView = UIImageView()
    private lazy var priceLabel = UILabel()
    private lazy var broadcastView = RCVRGiftBroadcastView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceView)
        priceView.addSubview(diamondImageView)
        priceView.addSubview(priceLabel)
        iconImageView.addSubview(broadcastView)
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(80.resize)
        }
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 11.resize)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom)
            make.width.lessThanOrEqualToSuperview().offset(-12.resize)
        }
        
        priceView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        
        diamondImageView.image = R.image.gift_diamond()
        diamondImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        
        priceLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        priceLabel.font = UIFont.systemFont(ofSize: 9.resize)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(diamondImageView.snp.right).offset(2)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        broadcastView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(4)
        }
        
        contentView.layer.borderColor = UIColor(hexString: "#E92B88").cgColor
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.cornerRadius = isSelected ? 3.resize : 0
            contentView.layer.borderWidth = isSelected ? 1 : 0
        }
    }
    
    public func update(_ gift: VoiceRoomGift?) -> Self {
        if let gift = gift {
            iconImageView.image = UIImage(named: gift.icon)
            nameLabel.text = gift.name
            priceLabel.text = "\(gift.price)"
            diamondImageView.image = R.image.gift_diamond()
            broadcastView.isHidden = !broadcastGifts.contains(gift.id)
        } else {
            iconImageView.image = nil
            nameLabel.text = ""
            priceLabel.text = ""
            diamondImageView.image = nil
            broadcastView.isHidden = true
        }
        return self
    }
}

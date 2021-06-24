//
//  VoiceRoomMusicSoundEffectCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import Reusable

final class VoiceRoomMusicSoundEffectCell: UICollectionViewCell, Reusable {
    
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-8.resize)
        }
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 14.resize)
        
        contentView.layer.cornerRadius = 19.resize
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool{
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.white.alpha(0.2) : .clear
        }
    }
    
    func update(_ item: AudioEffect) -> VoiceRoomMusicSoundEffectCell {
        titleLabel.text = item.name
        return self
    }
}

//
//  FeedbackReasonCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/7/20.
//

import UIKit
import Reusable

enum FeedbackReasonType: CaseIterable {
    case sceneFunction
    case audioQuality
    case usageFlow
    case interaction
    
    var image: UIImage? {
        switch self {
        case .sceneFunction:
            return R.image.feedback_scene_icon()
        case .audioQuality:
            return R.image.feedback_audio_icon()
        case .usageFlow:
            return R.image.feedback_usage_icon()
        case .interaction:
            return R.image.feedback_interaction()
        }
    }
    
    var title: String {
        switch self {
        case .sceneFunction:
            return "场景\n功能"
        case .audioQuality:
            return "音频\n质量"
        case .usageFlow:
            return "使用\n流程"
        case .interaction:
            return "交互\n体验"
        }
    }
}

class FeedbackReasonCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var containerView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "e5e6e7").cgColor
        instance.layer.cornerRadius = 8
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.numberOfLines = 0
        instance.textColor = UIColor(hexString: "020037")
        return instance
    }()
    private lazy var iconImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = nil
        return instance
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                containerView.backgroundColor = UIColor(hexString: "C4C6FF").withAlphaComponent(0.3)
            } else {
                containerView.backgroundColor = .white
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(iconImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().offset(14)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(6)
            make.right.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }
    }
    
    func updateCell(reason: FeedbackReasonType) {
        iconImageView.image = reason.image
        nameLabel.text = reason.title
    }
}

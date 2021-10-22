//
//  RCMHBeautyActionCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/2.
//

import Reusable

extension RCMHBeautyAction {
    var image: UIImage? {
        switch self {
        case .switchCamera: return R.image.rc_beauty_switch_camera()
        case .sticker: return R.image.rc_beauty_sticker()
        case .retouch: return R.image.rc_beauty_retouch()
        case .makeup: return R.image.rc_beauty_makeup()
        case .effect: return R.image.rc_beauty_effect()
        }
    }
    
    var tintImage: UIImage? { image?.withRenderingMode(.alwaysTemplate) }
}

class RCMHBeautyActionCell: UICollectionViewCell, Reusable {
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12.resize)
        instance.textColor = .white
        return instance
    }()
    
    private lazy var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        imageView.tintColor = .white
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(48.resize)
            make.centerX.top.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            let color: UIColor = isHighlighted ? .red : .white
            titleLabel.textColor = color
            imageView.tintColor = color
        }
    }
    
    func update(_ action: RCMHBeautyAction) -> RCMHBeautyActionCell {
        titleLabel.text = action.rawValue
        imageView.image = action.tintImage
        return self
    }
}

//
//  RCLVRLayoutCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/9.
//

import Reusable
import UIKit

private var normalBackgroundImage: UIImage = {
    let size = CGSize(width: 157.5.resize, height: 48.resize)
    let layer = CALayer()
    layer.bounds = CGRect(origin: .zero, size: size)
    layer.borderWidth = 0
    layer.backgroundColor = UIColor.white.withAlphaComponent(0.16).cgColor
    layer.cornerRadius = 6.resize
    return UIGraphicsImageRenderer(size: size)
        .image { renderer in
            layer.render(in: renderer.cgContext)
        }
}()

private var selectedBackgroundImage: UIImage = {
    let size = CGSize(width: 157.5.resize, height: 48.resize)
    let layer = CALayer()
    layer.bounds = CGRect(origin: .zero, size: size)
    layer.borderWidth = 1
    layer.borderColor = UIColor(byteRed: 239, green: 73, blue: 154).cgColor
    layer.backgroundColor = UIColor(byteRed: 239, green: 73, blue: 154, alpha: 0.06).cgColor
    layer.cornerRadius = 6.resize
    return UIGraphicsImageRenderer(size: size)
        .image { renderer in
            layer.render(in: renderer.cgContext)
        }
}()

class RCLVRLayoutCell: UICollectionViewCell, Reusable {
    private lazy var imageView = UIImageView(image: normalBackgroundImage)
    private lazy var iconImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(50.resize)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24.resize)
        }
        
        iconImageView.tintColor = .white
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 14.resize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.image = isSelected ? selectedBackgroundImage : normalBackgroundImage
            let color: UIColor = isSelected ? UIColor(byteRed: 239, green: 73, blue: 154) : .white
            iconImageView.tintColor = color
            titleLabel.textColor = color
        }
    }
    
    func update(_ type: RCLiveVideoMixType) -> Self {
        titleLabel.text = type.title
        iconImageView.image = type.image?.withRenderingMode(.alwaysTemplate)
        return self
    }
}

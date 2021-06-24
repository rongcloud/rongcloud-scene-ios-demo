//
//  BackgroundImageCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/18.
//

import UIKit
import Reusable
import Kingfisher

class BackgroundImageCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var backgroundImageView: AnimatedImageView = {
        let instance = AnimatedImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = nil
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 12
        return instance
    }()
    private lazy var selectedImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.background_image_unselected()
        return instance
    }()
    
    private lazy var gifLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 13, weight: .semibold)
        instance.textColor = .white
        instance.text = "GIF"
        return instance
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectedImageView.image = R.image.background_image_selected()
            } else {
                selectedImageView.image = R.image.background_image_unselected()
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
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(selectedImageView)
        contentView.addSubview(gifLabel)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSize(width: 105.resize, height: 105.resize))
        }
        
        selectedImageView.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(10.resize)
        }
        
        gifLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().inset(13)
        }
    }
    
    func updateCell(item: String) {
        let urlString = item
        let url = URL(string: urlString)
        backgroundImageView.kf_setOnlyDiskCacheImage(url, to: CGSize(width: 105.resize, height: 105.resize))
        gifLabel.isHidden = !item.hasSuffix("gif")
    }
}

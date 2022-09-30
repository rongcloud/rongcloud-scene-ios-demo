//
//  SelectVoiceRoomBgImageCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit
import Reusable
import Kingfisher

class SelectVoiceRoomBgImageCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var backgroundImageView: AnimatedImageView = {
        let instance = AnimatedImageView()
        instance.contentMode = .scaleToFill
        instance.image = nil
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 16
        return instance
    }()
    private lazy var selectedStateImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = nil
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 8
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var gifLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12, weight: .semibold)
        instance.textColor = .white
        instance.text = "GIF"
        return instance
    }()
    
    override var isSelected: Bool {
        didSet {
            selectedStateImageView.image = (isSelected ? R.image.background_selected_icon() : nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(selectedStateImageView)
        contentView.addSubview(gifLabel)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalTo(CGSize(width: 60.resize, height: 60.resize))
        }
        
        selectedStateImageView.snp.makeConstraints {
            $0.right.top.equalToSuperview().inset(4)
            $0.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        gifLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().inset(3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateCell(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let targetSize = CGSize(width: 60.resize, height: 60.resize)
        let resizingProcessor = ResizingImageProcessor(referenceSize: targetSize, mode: .aspectFill)
        var options = KingfisherOptionsInfo()
        options.append(.memoryCacheExpiration(.expired))
        options.append(.onlyLoadFirstFrame)
        options.append(.processor(resizingProcessor))
        backgroundImageView.kf.setImage(with: url, options: options)
        gifLabel.isHidden = !urlString.hasSuffix("gif")
    }
}

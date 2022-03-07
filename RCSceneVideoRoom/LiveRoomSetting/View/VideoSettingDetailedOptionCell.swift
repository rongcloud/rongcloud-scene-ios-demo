//
//  VideoSettingDetailedOptionCell.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/11/29.
//

import UIKit
import Reusable


class VideoSettingDetailedOptionCell: UICollectionViewCell,Reusable {
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
    
    
    private lazy var centerItem: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setBackgroundImage(normalBackgroundImage, for: .normal)
        btn.setBackgroundImage(selectedBackgroundImage, for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor(byteRed: 239, green: 73, blue: 154), for: .selected)
        btn.isUserInteractionEnabled = false
        contentView.addSubview(btn)
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(centerItem)
        centerItem.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
    }
    
    func update(_ option: String, selected: Bool)  {
        centerItem.setTitle(option, for: .normal)
        centerItem.isSelected = selected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



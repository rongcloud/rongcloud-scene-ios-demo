//
//  AppendForbiddenCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/3.
//

import UIKit
import Reusable

class AppendForbiddenCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.28)
        instance.layer.cornerRadius = 15
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var appendButton: UIButton = {
        let instance = UIButton()
        instance.isUserInteractionEnabled = false
        instance.backgroundColor = .clear
        instance.setImage(R.image.append_forbidden_icon(), for: .normal)
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        contentView.addSubview(container)
        container.addSubview(appendButton)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(30)
        }
        
        appendButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(30)
        }
    }
}

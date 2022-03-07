//
//  ForbiddenWordCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/3.
//

import UIKit
import Reusable

class ForbiddenWordCell: UICollectionViewCell, Reusable {
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white.withAlphaComponent(0.28)
        instance.layer.cornerRadius = 15
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        return instance
    }()
    private lazy var deleteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.isUserInteractionEnabled = false
        instance.setImage(UIImage(named: "delete_forbidden_icon"), for: .normal)
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
        container.addSubview(nameLabel)
        container.addSubview(deleteButton)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(8)
            make.right.equalToSuperview().inset(12)
        }
    }
    
    func updateCell(item: ForbiddenCellType) {
        switch item {
        case .append:
            ()
        case let .word(word):
            nameLabel.text = word
        }
    }
}

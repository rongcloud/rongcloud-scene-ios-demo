//
//  MusicSheetCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/10/9.
//

import UIKit
import Reusable

class MusicSheetCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16, weight: .regular)
        instance.textColor = .white
        return instance
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                nameLabel.textColor = UIColor(hexString: "#EF499A")
            } else {
                nameLabel.textColor = .white
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLaout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLaout() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateCell(channel: MusicChannel) {
        nameLabel.text = channel.sheetName
    }
}

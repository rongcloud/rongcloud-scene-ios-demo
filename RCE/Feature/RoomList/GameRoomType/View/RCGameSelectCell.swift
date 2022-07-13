//
//  RCGameSelectCell.swift
//  RCE
//
//  Created by haoxiaoqing on 2022/5/15.
//

import UIKit
import Foundation

class RCGameSelectCell: UICollectionViewCell {
    
    var checkImageView = UIImageView()
    var imageView = UIImageView()
    var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.image = R.image.groom_demo_icon()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        checkImageView.image = R.image.groom_check_icon()
        checkImageView.isHidden = true
        
        label = UILabel()
        label.textColor = UIColor(hexString: "#03003A",alpha: 0.6)
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "你画我猜"
        
        self.addSubview(imageView)
        self.addSubview(checkImageView)
        self.addSubview(label)
        
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.left.top.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 28, height: 28))
            make.left.equalToSuperview().offset(46)
            make.top.equalTo(-14.resize)
        }
        
        label.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 70, height: 18))
            make.top.equalTo(imageView.snp.bottom).offset(5.resize)
            make.left.equalToSuperview().offset(-5)
        }
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateCell(game: RCSceneGameResp) -> RCGameSelectCell {
        imageView.kf.setImage(with: URL(string: game.thumbnail))
        label.text = game.gameName
        return self
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected && ((self.viewController?.isKind(of: CreateGameRoomViewController.self)) == true) {
                checkImageView.isHidden = false
            } else {
                checkImageView.isHidden = true
            }
        }
    }

}


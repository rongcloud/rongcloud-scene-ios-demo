//
//  RCGameFiterViewCell.swift
//  RCE
//
//  Created by haoxiaoqing on 2022/5/15.
//

import UIKit
import Foundation

class RCGameFiterViewCell: UICollectionViewCell {
    
    public lazy var contentlabel: UILabel = {
        let instance = UILabel()
        instance.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        instance.backgroundColor = UIColor(hexString: "#DBE2E8")
        instance.textColor = UIColor(hexString: "#03003A", alpha:0.6)
        instance.textAlignment = .center
        instance.font = UIFont(name: "PingFangSC-Medium", size: 12)
        instance.layer.cornerRadius = 15
        instance.layer.masksToBounds = true
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(contentlabel)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                contentlabel.backgroundColor = UIColor(hexString: "#EEC0C6")
                contentlabel.textColor = UIColor(hexString: "#FF505E")
            } else {
                contentlabel.backgroundColor = UIColor(hexString: "#DBE2E8")
                contentlabel.textColor = UIColor(hexString: "#03003A", alpha: 0.6)
            }

        }
    }

}


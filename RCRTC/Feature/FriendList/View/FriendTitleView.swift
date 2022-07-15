//
//  FriendTitleView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import UIKit

final class FriendTitleView: UIView {

    private lazy var normalAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 15),
        .foregroundColor: UIColor(byteRed: 3, green: 0, blue: 58, alpha: 0.45)
    ]
    
    private lazy var selectedAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 15, weight: .medium),
        .foregroundColor: UIColor(byteRed: 3, green: 0, blue: 58)
    ]
    
    private lazy var fansButton: UIButton = {
        let instance = UIButton()
        let title = "粉丝"
        let normalTitle = NSAttributedString(string: title, attributes: normalAttributes)
        let selectedTitle = NSAttributedString(string: title, attributes: selectedAttributes)
        instance.setAttributedTitle(normalTitle, for: .normal)
        instance.setAttributedTitle(selectedTitle, for: .selected)
        instance.addTarget(self, action: #selector(fansSelected), for: .touchUpInside)
        return instance
    }()
    
    private lazy var focusButton: UIButton = {
        let instance = UIButton()
        let title = "关注"
        let normalTitle = NSAttributedString(string: title, attributes: normalAttributes)
        let selectedTitle = NSAttributedString(string: title, attributes: selectedAttributes)
        instance.setAttributedTitle(normalTitle, for: .normal)
        instance.setAttributedTitle(selectedTitle, for: .selected)
        instance.addTarget(self, action: #selector(focusSelected), for: .touchUpInside)
        return instance
    }()
    
    private lazy var topLineView = UIView()
    private lazy var centerLineView = UIView()
    
    @objc dynamic var currentIndex: Int = 0 {
        didSet {
            fansButton.isSelected = currentIndex == 0
            focusButton.isSelected = currentIndex == 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(fansButton)
        addSubview(focusButton)
        addSubview(topLineView)
        addSubview(centerLineView)
        
        topLineView.backgroundColor = UIColor(byteRed: 227, green: 229, blue: 230)
        topLineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        centerLineView.backgroundColor = UIColor(byteRed: 227, green: 229, blue: 230)
        centerLineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(0.5)
            make.height.equalTo(14)
        }
        
        let buttonSize = CGSize(width: 83, height: 28)
        fansButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.size.equalTo(buttonSize)
        }
        
        focusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.width.height.equalTo(fansButton)
        }
        
        let buttonImage = UIGraphicsImageRenderer(size: buttonSize)
            .image { renderer in
                let context = renderer.cgContext
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: buttonSize), cornerRadius: buttonSize.height * 0.5)
                context.addPath(path.cgPath)
                UIColor.black.withAlphaComponent(0.1).setFill()
                context.fillPath()
            }
        fansButton.setBackgroundImage(buttonImage, for: .selected)
        focusButton.setBackgroundImage(buttonImage, for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func fansSelected() {
        currentIndex = 0
    }
    
    @objc private func focusSelected() {
        currentIndex = 1
    }
}

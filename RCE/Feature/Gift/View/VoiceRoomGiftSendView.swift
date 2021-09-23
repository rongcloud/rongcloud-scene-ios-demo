//
//  VoiceRoomGiftSendView.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/26.
//

import UIKit

protocol VoiceRoomGiftSendViewDelegate: AnyObject {
    func onGiftSendButtonClicked()
    func onGiftCountButtonClicked()
}

final class VoiceRoomGiftSendView: UIView {
    
    weak var delegate: VoiceRoomGiftSendViewDelegate?
    
    private lazy var sendButton = UIButton()
    private lazy var countLabel = UILabel()
    private lazy var arrowImageView = UIImageView()
    private lazy var countButton = UIButton()
    
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                onSendButtonEnabled()
            } else {
                onSendButtonDisable()
            }
        }
    }
    
    var count: Int = 1 {
        didSet {
            countLabel.text = "x\(count)"
            arrowImageView.image = R.image.gift_arrow_up()
        }
    }
    
    init(_ delegate: VoiceRoomGiftSendViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onSendButtonClicked() {
        delegate?.onGiftSendButtonClicked()
    }
    
    @objc private func onCountButtonClicked() {
        arrowImageView.image = R.image.gift_arrow_down()
        delegate?.onGiftCountButtonClicked()
    }
    
    func getDistanceOfArrowCenterToTheRight() -> CGFloat {
        return bounds.width - arrowImageView.center.x
    }
}

extension VoiceRoomGiftSendView {
    private func setupConstraints() {
        addSubview(countLabel)
        addSubview(sendButton)
        addSubview(arrowImageView)
        addSubview(countButton)
        
        sendButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(60.resize)
            make.height.equalTo(34.resize)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(sendButton.snp.left).offset(-8.resize)
            make.width.height.equalTo(12.resize)
        }
        
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15.resize)
            make.right.equalTo(arrowImageView.snp.left).offset(-10.resize)
        }
        
        countButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(sendButton.snp.left)
        }
    }
    
    private func setupUI() {
        layer.cornerRadius = 17.resize
        layer.masksToBounds = true
        layer.borderWidth = 1
        
        countLabel.text = "x\(count)"
        countLabel.textColor = .white
        countLabel.font = UIFont.systemFont(ofSize: 14.resize, weight: .medium)
        
        arrowImageView.image = R.image.gift_arrow_up()
        
        sendButton.addTarget(self, action: #selector(onSendButtonClicked), for: .touchUpInside)
        countButton.addTarget(self, action: #selector(onCountButtonClicked), for: .touchUpInside)
        
        isEnabled = false
    }
    
    private func onSendButtonDisable() {
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.resize, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        let sendAttributeText = NSAttributedString(string: "赠送",
                                                   attributes: attributes)
        sendButton.setAttributedTitle(sendAttributeText, for: .normal)
        sendButton.addTarget(self, action: #selector(onSendButtonClicked), for: .touchUpInside)
        sendButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }
    
    private func onSendButtonEnabled() {
        layer.borderColor = UIColor(hexString: "#E92B88").cgColor
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.resize, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        let sendAttributeText = NSAttributedString(string: "赠送",
                                                   attributes: attributes)
        sendButton.setAttributedTitle(sendAttributeText, for: .normal)
        sendButton.backgroundColor = UIColor(hexString: "#E92B88")
    }
}

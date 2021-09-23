//
//  RCRadioRoomToolBarView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import UIKit

final class RCRadioRoomToolBarView: UIView {
    
    private lazy var chatButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white.alpha(0.26)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitle("聊聊吧…", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        return button
    }()
    
    private(set) lazy var recordButton = RCVRVoiceButton()
    
    private lazy var giftButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_gift_icon(), for: .normal)
        return button
    }()
    
    private lazy var messageButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_message_icon(), for: .normal)
        return button
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_setting_icon(), for: .normal)
        return button
    }()
    
    private lazy var pkButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.voiceroom_pk_button(), for: .normal)
        return instance
    }()
    
    private lazy var stackView: UIStackView = {
        let instance = UIStackView()
        instance.distribution = .equalSpacing
        instance.alignment = .center
        instance.spacing = 12
        return instance
    }()
    
    private lazy var messageBadgeView = VoiceRoomChatBageView()
    
    public var rightMostViewFrame: CGRect {
        guard let view = stackView.arrangedSubviews.last else { return .zero }
        return convert(view.frame, from: stackView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshUnreadMessageCount() {
        let unreadCount = RCIMClient.shared()
            .getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        messageBadgeView.update(Int(unreadCount))
    }
    
    public func add(chat target: Any?, action: Selector) {
        chatButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func add(gift target: Any?, action: Selector) {
        giftButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func add(message target: Any?, action: Selector) {
        messageButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func add(setting target: Any?, action: Selector) {
        settingButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func add(pk target: Any?, action: Selector) {
        pkButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func layoutUI(_ roomInfo: VoiceRoom) {
        stackView.arrangedSubviews
            .forEach { stackView.removeArrangedSubview($0) }
        addSubview(stackView)
        stackView.snp.remakeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalTo(chatButton)
        }
        if roomInfo.isOwner {
            recordButton.isHidden = true
            chatButton.titleEdgeInsets = .zero
            [giftButton, messageButton, settingButton]
                .forEach { stackView.addArrangedSubview($0) }
        } else {
            recordButton.isHidden = false
            chatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            [giftButton, messageButton]
                .forEach { stackView.addArrangedSubview($0) }
        }
    }
}

extension RCRadioRoomToolBarView {
    private func setupConstraints() {
        addSubview(chatButton)
        chatButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(105)
            make.height.equalTo(36)
        }
        chatButton.layer.cornerRadius = 18
        chatButton.layer.masksToBounds = true
        
        addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.left.equalTo(chatButton)
            make.centerY.equalTo(chatButton)
            make.width.height.equalTo(44)
        }
        
        messageButton.addSubview(messageBadgeView)
        messageBadgeView.snp.makeConstraints { make in
            make.centerX.equalTo(messageButton.snp.right).offset(-4)
            make.centerY.equalTo(messageButton.snp.top).offset(4)
        }
    }
}

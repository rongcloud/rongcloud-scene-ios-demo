//
//  VoiceRoomToolBarView.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/16.
//

import UIKit

final class VoiceRoomToolBarView: UIView {
    
    private var role: VoiceRoomUserType
    
    private(set) lazy var chatButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(R.image.trigger_input_icon(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitle("聊聊吧…", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        return button
    }()
    private(set) lazy var usersButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_mic_order_icon(), for: .normal)
        return button
    }()
    private(set) lazy var requestMicroButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.connect_mic_state_none(), for: .normal)
        return button
    }()
    private(set) lazy var cancelMicroButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.connect_mic_state_none(), for: .normal)
        return button
    }()
    private(set) lazy var giftButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_gift_icon(), for: .normal)
        return button
    }()
    private(set) lazy var messageButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_message_icon(), for: .normal)
        return button
    }()
    private(set) lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.voice_room_setting_icon(), for: .normal)
        return button
    }()
    
    private(set) lazy var usersBadgeView = VoiceRoomChatBageView()
    private(set) lazy var messageBadgeView = VoiceRoomChatBageView()
    
    init(_ role: VoiceRoomUserType) {
        self.role = role
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setRole(_ role: VoiceRoomUserType) {
        switch role {
        case .creator:
            setupCreatorConstraints()
        case .manager, .audience:
            setupAudienceConstraints()
        }
    }
    
    public func update(users count: Int) {
        usersBadgeView.update(count)
    }
    
    public func refreshUnreadMessageCount() {
        let unreadCount = RCIMClient.shared()
            .getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        messageBadgeView.update(Int(unreadCount))
    }
    
    public func add(chat target: Any?, action: Selector) {
        chatButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func add(users target: Any?, action: Selector) {
        usersButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func add(requset target: Any?, action: Selector) {
        requestMicroButton.addTarget(target, action: action, for: .touchUpInside)
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
}

extension VoiceRoomToolBarView {
    private func setupConstraints() {
        addSubview(chatButton)
        chatButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(105)
            make.height.equalTo(36)
        }
        if role == .creator {
            setupCreatorConstraints()
        } else {
            setupAudienceConstraints()
        }
        messageButton.addSubview(messageBadgeView)
        messageBadgeView.snp.makeConstraints { make in
            make.centerX.equalTo(messageButton.snp.right).offset(-4)
            make.centerY.equalTo(messageButton.snp.top).offset(4)
        }
    }
    
    private func setupCreatorConstraints() {
        addSubview(usersButton)
        usersButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(chatButton.snp.right).offset(15)
            make.width.height.equalTo(36)
        }
        
        usersButton.addSubview(usersBadgeView)
        usersBadgeView.snp.makeConstraints { make in
            make.centerX.equalTo(usersButton.snp.right).offset(-4)
            make.centerY.equalTo(usersButton.snp.top).offset(4)
        }
        
        addSubview(settingButton)
        settingButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        addSubview(giftButton)
        giftButton.snp.remakeConstraints { make in
            make.right.equalTo(settingButton.snp.left).offset(-15)
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
        }
        
        addSubview(messageButton)
        messageButton.snp.remakeConstraints { make in
            make.right.equalTo(giftButton.snp.left).offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
    }
    
    private func setupAudienceConstraints() {
        addSubview(messageButton)
        messageButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        addSubview(giftButton)
        giftButton.snp.remakeConstraints { make in
            make.right.equalTo(messageButton.snp.left).offset(-15)
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
        }
        
        addSubview(requestMicroButton)
        requestMicroButton.snp.makeConstraints { make in
            make.right.equalTo(giftButton.snp.left).offset(-15)
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
        }
    }
}

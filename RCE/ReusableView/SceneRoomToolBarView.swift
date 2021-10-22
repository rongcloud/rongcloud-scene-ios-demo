//
//  VoiceRoomToolBarView.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/16.
//

import UIKit

enum SceneToolType {
    case record
    case pk
    case userlist
    case requestMic
    case gift
    case message
    case setting
}

extension VoiceRoom {
    var toollist: [SceneToolType] {
        switch roomType {
        case 1:
            if isOwner == true {
                return [.userlist, .pk, .gift, .message, .setting]
            } else {
                return [.requestMic,.gift, .message]
            }
        case 2:
            if isOwner == true {
                return [.gift, .message, .setting]
            } else {
                return [.gift, .message]
            }
        case 3:
            if isOwner == true {
                return [.userlist, .gift, .message, .setting]
            } else {
                return [.requestMic,.gift, .message]
            }
        default: return []
        }
    }
}

final class SceneRoomToolBarView: UIView {
    private(set) lazy var chatButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white.alpha(0.26)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitle("聊聊吧…", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        return button
    }()
    private(set) lazy var recordButton = RCVRVoiceButton()
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
    private(set) lazy var pkButton: UIButton = {
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
    private let toollist: [SceneToolType]
    private(set) lazy var usersBadgeView = VoiceRoomChatBageView()
    private(set) lazy var messageBadgeView = VoiceRoomChatBageView()
    
    var micState: ConnectMicState = .request {
        didSet {
            setupRecordButton()
            setupMicButton()
        }
    }
    
    public var rightMostViewFrame: CGRect {
        guard let view = stackView.arrangedSubviews.last else { return .zero }
        return convert(view.frame, from: stackView)
    }
    
    init(toolist: [SceneToolType]) {
        self.toollist = toolist
        super.init(frame: .zero)
        setupConstraints()
    }
    
    init(_ room: VoiceRoom) {
        self.toollist = room.toollist
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(users count: Int) {
        usersBadgeView.update(count)
        if !usersBadgeView.isHidden && micState != .request {
            usersBadgeView.isHidden = true
        }
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
    
    public func add(pk target: Any?, action: Selector) {
        pkButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

extension SceneRoomToolBarView {
    private func toolView(of type: SceneToolType) -> UIView {
        switch type {
        case .gift:
            return giftButton
        case .message:
            return messageButton
        case .pk:
            return pkButton
        case .requestMic:
            return requestMicroButton
        case .userlist:
            return usersButton
        case .record:
            return recordButton
        case .setting:
            return settingButton
        }
    }
    
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
        
        usersButton.addSubview(usersBadgeView)
        usersBadgeView.snp.makeConstraints { make in
            make.centerX.equalTo(usersButton.snp.right).offset(-4)
            make.centerY.equalTo(usersButton.snp.top).offset(4)
        }
        
        toollist
            .map { toolView(of: $0) }
            .forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalTo(chatButton)
        }
        
        setupRecordButton()
    }
    
    private func setupRecordButton() {
        let isOwner = toollist.contains(.setting)
        if isOwner || micState == .connecting {
            recordButton.isHidden = true
            chatButton.titleEdgeInsets = .zero
        } else {
            recordButton.isHidden = false
            chatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        }
    }
    
    private func setupMicButton() {
        if toollist.contains(.userlist) {
            if micState == .request {
                usersButton.setImage(R.image.voice_room_mic_order_icon(), for: .normal)
                usersBadgeView.isHidden = usersBadgeView.count == 0
            } else {
                usersButton.setImage(micState.image, for: .normal)
                usersBadgeView.isHidden = true
            }
        } else {
            requestMicroButton.setImage(micState.image, for: .normal)
        }
    }
}

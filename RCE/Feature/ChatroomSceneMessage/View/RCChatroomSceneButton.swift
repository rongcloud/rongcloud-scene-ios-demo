//
//  RCChatroomSceneButton.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/4.
//

import UIKit

enum RCChatroomSceneButtonType {
    case pk
    case mic
    case gift
    case message
    case setting
    
    var image: UIImage? {
        switch self {
        case .pk: return R.image.voiceroom_pk_button()
        case .mic: return R.image.voice_room_mic_order_icon()
        case .gift: return R.image.voice_room_gift_icon()
        case .message: return R.image.voice_room_message_icon()
        case .setting: return R.image.voice_room_setting_icon()
        }
    }
}

enum RCChatroomSceneMicState {
    case user
    case request
    case waiting
    case connecting
    var image: UIImage? {
        switch self {
        case .user: return R.image.voice_room_mic_order_icon()
        case .request: return R.image.connect_mic_state_none()
        case .waiting: return R.image.connect_mic_state_waiting()
        case .connecting: return R.image.connect_mic_state_connecting()
        }
    }
}

class RCChatroomSceneButton: UIButton {
    
    private lazy var badgeView = VoiceRoomChatBageView()
    var badgeCount: Int { badgeView.count }
    
    var micState: RCChatroomSceneMicState = .user {
        didSet {
            hideBadgeIfNeeded()
            setImage(micState.image, for: .normal)
        }
    }

    private let type: RCChatroomSceneButtonType
    init(_ type: RCChatroomSceneButtonType) {
        self.type = type
        super.init(frame: .zero)
        setImage(type.image, for: .normal)
        addSubview(badgeView)
        badgeView.snp.makeConstraints { make in
            make.centerX.equalTo(snp.right).offset(-4)
            make.centerY.equalTo(snp.top).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBadgeCount(_ count: Int) {
        badgeView.update(count)
        hideBadgeIfNeeded()
    }
    
    private func hideBadgeIfNeeded() {
        guard type == .mic else { return }
        switch micState {
        case .user, .request:
            badgeView.isHidden = badgeCount == 0
        case .waiting, .connecting:
            badgeView.isHidden = true
        }
    }
}

extension RCChatroomSceneButton {
    func refreshMessageCount() {
        let unreadCount = RCIMClient.shared()
            .getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        setBadgeCount(Int(unreadCount))
    }
}

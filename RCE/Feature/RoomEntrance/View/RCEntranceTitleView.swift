//
//  RCEntranceTitleView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import RCSceneVoiceRoom

extension RCScene {
    var name: String {
        switch self {
        case .audioRoom:
            return "语聊房"
        case .radioRoom:
            return "语音电台"
        case .videoCall:
            return "视频通话"
        case .audioCall:
            return "语音通话"
        case .liveVideo:
            return "视频直播"
        case .gameRoom:
            return "游戏房"
        default: return ""
        }
    }
    
    var desc: String {
        switch self {
        case .audioRoom:
            return "超大聊天室，支持麦位、麦序\n管理，涵盖KTV等多种玩法"
        case .radioRoom:
            return "听众端采用CDN链路 支持人数无上限"
        case .videoCall:
            return "低延迟、高清晰度视频通话"
        case .audioCall:
            return "拥有智能降噪的无差别 电话体验"
        case .liveVideo:
            return "视频直播间，支持高级美颜、观众连麦互动"
        case .gameRoom:
            return "多种游戏，快速匹配"
        default: return ""
        }
    }
}

final class RCEntranceTitleView: UIView {
    
    private lazy var normalAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 17, weight: .medium),
        .foregroundColor: UIColor(byteRed: 3, green: 0, blue: 58)
    ]
    
    private lazy var selectedAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 19, weight: .medium),
        .foregroundColor: UIColor(byteRed: 3, green: 0, blue: 58)
    ]
    
    private lazy var roomButton: UIButton = {
        let instance = UIButton()
        let title = SceneRoomManager.scene.name
        let normalTitle = NSAttributedString(string: title, attributes: normalAttributes)
        let selectedTitle = NSAttributedString(string: title, attributes: selectedAttributes)
        instance.setAttributedTitle(normalTitle, for: .normal)
        instance.setAttributedTitle(selectedTitle, for: .selected)
        instance.addTarget(self, action: #selector(roomSelected), for: .touchUpInside)
        return instance
    }()
    
    private lazy var friendButton: UIButton = {
        let instance = UIButton()
        let title = "好友"
        let normalTitle = NSAttributedString(string: title, attributes: normalAttributes)
        let selectedTitle = NSAttributedString(string: title, attributes: selectedAttributes)
        instance.setAttributedTitle(normalTitle, for: .normal)
        instance.setAttributedTitle(selectedTitle, for: .selected)
        instance.addTarget(self, action: #selector(friendSelected), for: .touchUpInside)
        return instance
    }()
    
    private lazy var movingView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(byteRed: 3, green: 0, blue: 58)
        return instance
    }()
    
    private var currentIndex: Int = 0 {
        didSet {
            roomButton.isSelected = currentIndex == 0
            friendButton.isSelected = currentIndex == 1
            movingView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.centerX.equalTo(currentIndex == 0 ? roomButton : friendButton)
                make.width.equalTo(26)
                make.height.equalTo(2)
            }
        }
    }

    var currentIndexDidChanged: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(roomButton)
        addSubview(friendButton)
        addSubview(movingView)
        
        roomButton.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.greaterThanOrEqualTo(76)
            make.height.equalTo(44)
        }
        
        friendButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.height.equalTo(roomButton)
            make.left.equalTo(roomButton.snp.right)
        }
        
        movingView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(roomButton)
            make.width.equalTo(26)
            make.height.equalTo(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func roomSelected() {
        currentIndex = 0
        currentIndexDidChanged?(currentIndex)
    }
    
    @objc private func friendSelected() {
        currentIndex = 1
        currentIndexDidChanged?(currentIndex)
    }
    
    func set(_ index: Int) {
        currentIndex = index
    }
}

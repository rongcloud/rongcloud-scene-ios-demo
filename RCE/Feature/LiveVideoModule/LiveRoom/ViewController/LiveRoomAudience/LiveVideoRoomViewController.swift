//
//  LiveVideoRoomViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import UIKit
import Differentiator

class LiveVideoRoomViewController: RCLiveModuleViewController {
    
    /// 管理员
    dynamic var managers = [VoiceRoomUser]()
    
    /// 主播美颜
    var osTypeHandler: ChatGPUImageHandler?
    var beautyManager: MHBeautyManager?
    
    private(set) lazy var roomInfoView = SceneRoomInfoView(room)
    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomGiftView = SceneRoomMarkView()
    private(set) lazy var roomMoreView = RCLiveVideoRoomMoreView()
    private(set) lazy var messageView = RCVRMView()
    private(set) lazy var toolBarView = SceneRoomToolBarView(room)
    private(set) lazy var roomSuspendView = RCRadioRoomSuspendView(room)
    private(set) lazy var roomUserView = LiveVideoRoomUserView()
    private(set) lazy var likeView = UIView()
    
    private(set) lazy var sticker = RCMHStickerViewController(beautyManager!)
    private(set) lazy var retouch = RCMHRetouchViewController(beautyManager!)
    private(set) lazy var makeup = RCMHMakeupViewController(beautyManager!)
    private(set) lazy var effect = RCMHEffectViewController(beautyManager!)
    
    private(set) lazy var musicControlVC = VoiceRoomMusicControlViewController(roomId: room.roomId)
    
    dynamic var role: RCRTCLiveRoleType = .audience
    
    var room: VoiceRoom
    init(_ room: VoiceRoom, beautyManager: MHBeautyManager? = nil) {
        self.room = room
        self.role = room.isOwner ? .broadcaster : .audience
        self.beautyManager = beautyManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        RCCall.shared().canIncomingCall = true
        beautyManager?.destroy()
        debugPrint("LVRV deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        RCCall.shared().canIncomingCall = false
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let previewView = RCLiveVideoEngine.shared().previewView()
        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(likeView)
        view.addSubview(roomInfoView)
        view.addSubview(roomMoreView)
        view.addSubview(roomNoticeView)
        view.addSubview(roomGiftView)
        view.addSubview(messageView)
        view.addSubview(toolBarView)
        
        likeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        roomInfoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        
        roomMoreView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.right.equalToSuperview().inset(12)
            make.width.height.equalTo(44)
        }
        
        roomNoticeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(roomInfoView.snp.bottom).offset(8)
        }
        
        roomGiftView.iconImageView.image = R.image.gift_value()
        roomGiftView.nameLabel.text = "0"
        roomGiftView.snp.makeConstraints { make in
            make.centerY.equalTo(roomNoticeView)
            make.left.equalTo(roomNoticeView.snp.right).offset(6)
        }
        
        messageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(toolBarView.snp.top)
            make.width.equalToSuperview().multipliedBy(278.0 / 375)
            make.height.equalTo(320.resize)
        }
        
        toolBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
    }
    
    dynamic func handleReceivedMessage(_ message: RCMessage) {}
}

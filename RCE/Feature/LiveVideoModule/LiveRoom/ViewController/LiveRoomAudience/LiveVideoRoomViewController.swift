//
//  LiveVideoRoomViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import UIKit
import Differentiator
import RCChatroomSceneKit
import RCLiveVideoLib

class LiveVideoRoomViewController: RCLiveModuleViewController {
    
    /// 管理员
    dynamic var managers = [VoiceRoomUser]()
    
    /// 主播美颜
    var osTypeHandler: ChatGPUImageHandler?
    var beautyManager: MHBeautyManager?
    
    private let musicInfoBubbleView = RCMusicEngine.musicInfoBubbleView
    
    private lazy var gradientLayer: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.colors = [
            UIColor(byteRed: 70, green: 42, blue: 79).cgColor,
            UIColor(byteRed: 26, green: 29, blue: 61).cgColor
        ]
        instance.locations = [0, 0.89]
        instance.startPoint = CGPoint(x: 0.25, y: 0.5)
        instance.endPoint = CGPoint(x: 0.75, y: 0.5)
        return instance
    }()
    
    private(set) lazy var previewView = LiveVideoRoomPreviewView()
    private(set) lazy var seatView = UIView()
    private(set) lazy var roomUserView = LiveVideoRoomUserView()
    private(set) lazy var roomCountingView = LiveVideoRoomCountingView()
    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomGiftView = SceneRoomMarkView()
    private(set) lazy var roomMoreView = RCLiveVideoRoomMoreView()
    private(set) lazy var chatroomView = RCChatroomSceneView()
    private(set) lazy var roomSuspendView = RCRadioRoomSuspendView(room)

    private(set) lazy var micButton = RCChatroomSceneButton(.mic)
    private(set) lazy var giftButton = RCChatroomSceneButton(.gift)
    private(set) lazy var messageButton = RCChatroomSceneButton(.message)
    
    private(set) lazy var sticker = RCMHStickerViewController(beautyManager!)
    private(set) lazy var retouch = RCMHRetouchViewController(beautyManager!)
    private(set) lazy var makeup = RCMHMakeupViewController(beautyManager!)
    private(set) lazy var effect = RCMHEffectViewController(beautyManager!)
    
    private(set) lazy var musicControlVC = VoiceRoomMusicControlViewController(roomId: room.roomId)
    
    dynamic var role: RCRTCLiveRoleType = .audience
    
    var isSeatFreeEnter: Bool = false
    
    var room: VoiceRoom
    init(_ room: VoiceRoom, beautyManager: MHBeautyManager? = nil) {
        self.room = room
        self.role = room.isOwner ? .broadcaster : .audience
        self.beautyManager = beautyManager
        super.init(nibName: nil, bundle: nil)
        SceneRoomManager.shared.forbiddenWordlist = []
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
        
        DataSourceImpl.instance.roomId = self.room.roomId
        DelegateImpl.instance.roomId = self.room.roomId
        PlayerImpl.instance.type = .live
        
        RCIM.shared().addReceiveMessageDelegate(self)
        DataSourceImpl.instance.fetchRoomPlayingMusicInfo { info in
            self.musicInfoBubbleView?.info = info;
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.layer.addSublayer(gradientLayer)
        
        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(seatView)
        
        view.addSubview(roomUserView)
        view.addSubview(roomCountingView)
        view.addSubview(roomMoreView)
        view.addSubview(roomNoticeView)
        view.addSubview(roomGiftView)
        view.addSubview(chatroomView.messageView)
        view.addSubview(chatroomView.toolBar)
        
        roomUserView.updateNetworkDelay(enableCDN)
        roomUserView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        
        roomCountingView.snp.makeConstraints { make in
            make.centerY.equalTo(roomUserView)
            make.right.equalTo(roomMoreView.snp.left).offset(-10)
        }
        
        roomMoreView.snp.makeConstraints { make in
            make.centerY.equalTo(roomUserView)
            make.right.equalToSuperview().inset(12)
            make.width.height.equalTo(36)
        }
        
        roomNoticeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(roomUserView.snp.bottom).offset(8)
        }
        
        roomGiftView.iconImageView.image = R.image.gift_value()
        roomGiftView.nameLabel.text = "0"
        roomGiftView.snp.makeConstraints { make in
            make.centerY.equalTo(roomNoticeView)
            make.left.equalTo(roomNoticeView.snp.right).offset(6)
        }
        
        chatroomView.toolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        chatroomView.messageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-140.resize)
            make.bottom.equalTo(chatroomView.toolBar.snp.top)
            make.height.equalTo(320.resize)
        }
        
        guard let bubble = musicInfoBubbleView else {
            return
        }
        view.addSubview(bubble)
        bubble.snp.makeConstraints { make in
            make.top.equalTo(roomUserView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 150, height: 50))
        }
    }
    
    dynamic func handleReceivedMessage(_ message: RCMessage) {
        handleCommandMessage(message)
    }
    
    func handleCommandMessage(_ message: RCMessage) {
        CommandMessageHandler.handleMessage(message, musicInfoBubbleView)
    }
}

extension LiveVideoRoomViewController: RCIMReceiveMessageDelegate {
    func onRCIMCustomAlertSound(_ message: RCMessage!) -> Bool {
        return true
    }
}

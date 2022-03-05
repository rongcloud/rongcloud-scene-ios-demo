//
//  LiveVideoCreationController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/2.
//

import UIKit
import SVProgressHUD
import RCChatroomSceneKit

final class LiveVideoRoomHostController: LiveVideoRoomModuleHostController {
    
    private(set) lazy var beautyPlugin = RCBeautyPlugin()
    
    var room: VoiceRoom! {
        didSet {
            SceneRoomManager.shared.currentRoom = room
            if (room != nil) {
                DataSourceImpl.instance.roomId = room.roomId
                DelegateImpl.instance.roomId = room.roomId
            }
        }
    }
    
    var managers = [VoiceRoomUser]() {
        didSet {
            SceneRoomManager.shared.managerlist = managers.map { $0.userId }
            messageView.tableView.reloadData()
        }
    }
    
    var giftInfo: [String: Int] = [:]
    
    var isSeatFreeEnter: Bool = false
    
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
    
    private(set) lazy var creationView = LiveVideoRoomCreationView(beautyPlugin)
    
    private(set) lazy var containerView = UIView()
    private(set) lazy var seatView = UIView()
    private(set) lazy var roomUserView = LiveVideoRoomUserView()
    private(set) lazy var roomCountingView = LiveVideoRoomCountingView()
    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomGiftView = SceneRoomMarkView()
    private(set) lazy var roomMoreView = RCLiveVideoRoomMoreView()
    
    private(set) lazy var chatroomView = RCChatroomSceneView()
    private(set) lazy var pkButton = RCChatroomSceneButton(.pk)
    private(set) lazy var micButton = RCChatroomSceneButton(.mic)
    private(set) lazy var giftButton = RCChatroomSceneButton(.gift)
    private(set) lazy var messageButton = RCChatroomSceneButton(.message)
    private(set) lazy var settingButton = RCChatroomSceneButton(.setting)
    
    private(set) lazy var videoPropsSetVc = VideoPropertiesSetViewController()
    
    private let musicInfoBubbleView = RCMusicEngine.musicInfoBubbleView
    
    lazy var pkView = LiveVideoRoomPKView()
    
    init(_ room: VoiceRoom? = nil) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
        SceneRoomManager.shared.forbiddenWordlist = []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        if let room = room { didCreate(room) }
        RCCall.shared().canIncomingCall = false
        UIApplication.shared.isIdleTimerDisabled = true
        videoPropsSetVc.delegate = self
        PlayerImpl.instance.type = .live
        PlayerImpl.instance.initializedEarMonitoring()
        bubbleViewAddGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func buildLayout() {
        view.backgroundColor = .black
        view.layer.addSublayer(gradientLayer)
        
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let preview = RCLiveVideoEngine.shared().previewView()
        containerView.addSubview(preview)
        preview.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(preview.snp.height).multipliedBy(9.0 / 16)
        }
        
        containerView.addSubview(seatView)
        seatView.snp.makeConstraints { make in
            make.edges.equalTo(preview)
        }
        
        containerView.addSubview(creationView)
        creationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func rebuildLayout() {
        if room == nil { return }
        
        /// 移除创建UI
        creationView.removeFromSuperview()
        
        view.addSubview(roomUserView)
        view.addSubview(roomCountingView)
        view.addSubview(roomMoreView)
        view.addSubview(roomNoticeView)
        view.addSubview(roomGiftView)
        view.addSubview(chatroomView.messageView)
        view.addSubview(chatroomView.toolBar)
        
        roomUserView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        
        roomCountingView.snp.makeConstraints { make in
            make.centerY.equalTo(roomUserView)
            make.right.equalTo(roomMoreView.snp.left).offset(-10)
        }
        
        roomMoreView.update(.broadcaster)
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
        
        guard let bubble = musicInfoBubbleView, let _ = self.room else {
            return
        }
        view.addSubview(bubble)
        bubble.snp.makeConstraints { make in
            make.top.equalTo(roomUserView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 150, height: 50))
        }
    }
    
    private func bubbleViewAddGesture() {
        guard let bubble = musicInfoBubbleView else {
            return
        }
        bubble.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action:#selector(presentMusicController))
        bubble.addGestureRecognizer(tap)
    }
    
    @objc func presentMusicController() {
        RCMusicEngine.shareInstance().show(in: self, completion: nil)
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        RCCall.shared().canIncomingCall = true
        debugPrint("Live deinit")
    }
}

extension LiveVideoRoomHostController {
    dynamic func roomDidCreated() {}
    dynamic func handleReceivedMessage(_ message: RCMessage) {
        RoomMessageHandlerManager.handleMessage(message, musicInfoBubbleView)
    }
}

extension LiveVideoRoomHostController: RCRoomCycleProtocol {
}

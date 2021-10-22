//
//  LiveVideoCreationController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/2.
//

import UIKit
import SVProgressHUD

final class LiveVideoRoomHostController: LiveVideoRoomModuleHostController {
    /// 视频流相关
    let gpuHandler = ChatGPUImageHandler()
    private(set) lazy var beautyManager: MHBeautyManager = {
        let instance = MHBeautyManager()
        instance.setupDefault()
        return instance
    }()
    
    var room: VoiceRoom!
    
    var managers = [VoiceRoomUser]() {
        didSet {
            SceneRoomManager.shared.managerlist = managers.map { $0.userId }
            messageView.reloadMessages()
        }
    }
    
    private(set) lazy var creationView = LiveVideoRoomCreationView(beautyManager)
    
    private(set) lazy var containerView = UIView()
    private(set) lazy var likeView = UIView()
    private(set) lazy var roomInfoView = SceneRoomInfoView(room)
    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomGiftView = SceneRoomMarkView()
    private(set) lazy var roomMoreView = RCLiveVideoRoomMoreView()
    private(set) lazy var messageView = RCVRMView()
    private(set) lazy var toolBarView = SceneRoomToolBarView(room)
    private(set) lazy var roomUserView = LiveVideoRoomUserView()
    
    private(set) lazy var sticker = RCMHStickerViewController(beautyManager)
    private(set) lazy var retouch = RCMHRetouchViewController(beautyManager)
    private(set) lazy var makeup = RCMHMakeupViewController(beautyManager)
    private(set) lazy var effect = RCMHEffectViewController(beautyManager)
    
    private(set) lazy var musicControlVC = VoiceRoomMusicControlViewController(roomId: room!.roomId)
    
    init(_ room: VoiceRoom? = nil) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        if let room = room { restore(room) }
        RCCall.shared().canIncomingCall = false
        UIApplication.shared.isIdleTimerDisabled = true
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
    
    private func buildLayout() {
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let preview = RCLiveVideoEngine.shared().previewView()
        containerView.addSubview(preview)
        preview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        
        roomMoreView.update(.broadcaster)
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
            make.width.lessThanOrEqualToSuperview().multipliedBy(278.0 / 375)
            make.height.equalTo(320.resize)
        }
        
        toolBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
    }
    
    func setupToolBarView() {
        if room == nil { return }
        toolBarView.add(users: self, action: #selector(liveVideoRequestDidClick))
        toolBarView.add(gift: self, action: #selector(handleGiftButtonClick))
        toolBarView.add(setting: self, action: #selector(handleSettingClick))
        toolBarView.refreshUnreadMessageCount()
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        RCCall.shared().canIncomingCall = true
        beautyManager.destroy()
        debugPrint("Live deinit")
    }
}

extension LiveVideoRoomHostController {
    dynamic func handleReceivedMessage(_ message: RCMessage) {}
}

extension LiveVideoRoomHostController: RCRoomCycleProtocol {
}

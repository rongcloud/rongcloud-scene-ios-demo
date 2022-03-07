//
//  RCRadioRoomViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import SVProgressHUD

import RCSceneMusic
import RCSceneService
import RCSceneModular
import RCSceneFoundation

import RCChatroomSceneKit

final class RCRadioRoomViewController: RCModuleViewController {
    private(set) lazy var queue = DispatchQueue(label: "rc_radio_room_queue")
    
    private(set) lazy var roomInfoView = SceneRoomInfoView(roomInfo)
    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomOwnerView = RCRadioRoomOwnerView()
    private(set) lazy var roomSuspendView = RCRadioRoomSuspendView(roomInfo)
    
    private(set) lazy var chatroomView = RCChatroomSceneView()
    private(set) lazy var giftButton = RCChatroomSceneButton(.gift)
    private(set) lazy var messageButton = RCChatroomSceneButton(.message)
    private(set) lazy var settingButton = RCChatroomSceneButton(.setting)
    
    var messageView: RCChatroomSceneMessageView {
        return chatroomView.messageView
    }
    var roomToolBarView: RCChatroomSceneToolBar {
        return chatroomView.toolBar
    }
    
    private(set) lazy var moreButton = UIButton()
    
    private(set) lazy var roomKVState = RCRadioRoomKVState(roomInfo)
    
    dynamic var managers = [VoiceRoomUser]()
    
    private let musicInfoBubbleView = RCMusicEngine.musicInfoBubbleView

    var floatingManager: RCSceneRoomFloatingProtocol?
    
    weak var roomContainerAction: RCRoomContainerAction?
    
    var roomInfo: VoiceRoom
    let isCreate: Bool
    
    init(_ roomInfo: VoiceRoom, isCreate: Bool = false) {
        self.roomInfo = roomInfo
        self.isCreate = isCreate
        DelegateImpl.instance.roomId = roomInfo.roomId
        DataSourceImpl.instance.roomId = roomInfo.roomId
        PlayerImpl.instance.type = .radio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        PlayerImpl.instance.initializedEarMonitoring()
        bubbleViewAddGesture()
        if (!roomInfo.isOwner) {
            DataSourceImpl.instance.fetchRoomPlayingMusicInfo { info in
                self.musicInfoBubbleView?.info = info;
            }
        }
    }
    
    deinit {
        print("Radio Room deinit")
    }
    
    ///消息回调，在engine模块中触发
    dynamic func handleReceivedMessage(_ message: RCMessage) {
        handleCommandMessage(message)
    }
    //处理音乐消息同步指令消息
    func handleCommandMessage(_ message: RCMessage) {
        RoomMessageHandlerManager.handleMessage(message, musicInfoBubbleView)
    }
    //组件化重构
    func radioJoinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        SVProgressHUD.show()
        dispatch_join() { [unowned self] result in
            switch result {
            case .success:
                SVProgressHUD.dismiss(withDelay: 0.3)
                if roomInfo.isOwner {
                    enterSeat { _ in }
                } else {
                    listenToTheRadio { _ in }
                }
                SceneRoomManager.shared.currentRoom = roomInfo
                sendJoinRoomMessage()
                RCRTCEngine.sharedInstance().defaultAudioStream.setAudioQuality(.music, scenario: .musicChatRoom)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            if isCreate { roomKVState.initKV() }
            completion(result)
        }
    }
    
    func radioLeaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        clearMusicData()
        sendLeaveRoomMessage()
        dispatch_leave { [unowned self] result in
            navigationController?.safe_popToViewController(animated: true)
            if let fm = self.floatingManager {
                fm.hide()
            }
            DataSourceImpl.instance.clear()
            PlayerImpl.instance.clear()
            // TODO Call Status
//            RCCall.shared().canIncomingCall = true
            SceneRoomManager.shared.currentRoom = nil
            completion(result)
        }
    }
    
    func radioDescendantViews() -> [UIView] {
        return [messageView.tableView]
    }
}

extension RCRadioRoomViewController {
    private func setupConstraints() {
        view.addSubview(roomInfoView)
        view.addSubview(roomNoticeView)
        view.addSubview(roomOwnerView)
        view.addSubview(moreButton)
        view.addSubview(messageView)
        view.addSubview(roomToolBarView)
        
        roomInfoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(9)
            $0.left.equalToSuperview()
        }
        
        roomNoticeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(roomInfoView.snp.bottom).offset(12)
        }
        
        roomOwnerView.snp.makeConstraints {
            $0.top.equalTo(roomInfoView.snp.bottom).offset(34.resize)
            $0.centerX.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(roomInfoView)
            $0.right.equalToSuperview().inset(12.resize)
        }
        
        messageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(278.0 / 375)
            $0.bottom.equalTo(roomToolBarView.snp.top).offset(-8.resize)
            $0.top.equalTo(roomOwnerView.snp.bottom).offset(24.resize)
        }
        
        roomToolBarView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        
        guard let bubble = musicInfoBubbleView else {
            return
        }
        view.addSubview(bubble)
        bubble.snp.makeConstraints { make in
            make.top.equalTo(moreButton.snp.bottom).offset(10)
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
        //观众不展示音乐列表
        if (!roomInfo.isOwner) {return}
        RCMusicEngine.shareInstance().show(in: self, completion: nil)
    }
}

extension RCRadioRoomViewController: RCVoiceRoomDelegate {
   
    func messageDidReceive(_ message: RCMessage) {
        if message.content == nil { return }
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }
}


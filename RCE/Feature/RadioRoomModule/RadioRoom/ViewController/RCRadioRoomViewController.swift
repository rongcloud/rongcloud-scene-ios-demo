//
//  RCRadioRoomViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import SVProgressHUD

final class RCRadioRoomViewController: RCModuleViewController {
    private(set) lazy var queue = DispatchQueue(label: "rc_radio_room_queue")
    
    private(set) lazy var roomInfoView = RoomInfoView(roomId: roomInfo.roomId, networkEnable: false)
    private(set) lazy var roomNoticeView = RoomNoticeView(icon: R.image.room_notice_icon(), title: "公告")
    private(set) lazy var roomOwnerView = RCRadioRoomOwnerView()
    private(set) lazy var roomSuspendView = RCRadioRoomSuspendView(roomInfo)
    private(set) lazy var messageView = RCVRMView()
    private(set) lazy var roomToolBarView = RCRadioRoomToolBarView()
    private(set) lazy var moreButton = UIButton()
    private(set) lazy var musicControlVC = VoiceRoomMusicControlViewController(roomId: roomInfo.roomId)
    
    private(set) lazy var roomKVState = RCRadioRoomKVState(roomInfo)
    
    dynamic var managerlist = [VoiceRoomUser]()
    
    var roomInfo: VoiceRoom
    let isCreate: Bool
    
    init(_ roomInfo: VoiceRoom, isCreate: Bool = false) {
        self.roomInfo = roomInfo
        self.isCreate = isCreate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        RCCall.shared().canIncomingCall = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        RCCall.shared().canIncomingCall = true
    }
    
    deinit {
        print("Radio Room deinit")
    }
    
    ///消息回调，在engine模块中触发
    dynamic func handleReceivedMessage(_ message: RCMessage) {}
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
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(roomToolBarView.snp.top).offset(-8.resize)
            $0.top.equalTo(roomOwnerView.snp.bottom).offset(24.resize)
        }
        
        roomToolBarView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        
        roomToolBarView.layoutUI(roomInfo)
    }
}

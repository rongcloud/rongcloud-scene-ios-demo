//
//  VoiceRoomViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import SnapKit
import Kingfisher
import SVProgressHUD
import RxSwift

let alertTypeVideoAlreadyClose = "alertTypeVideoAlreadyClose"
let alertTypeConfirmCloseRoom = "alertTypeConfirmCloseRoom"

struct ManagerListWrapper: Codable {
    let code: Int
    let data: [VoiceRoomUser]?
}

class VoiceRoomViewController: UIViewController {
    dynamic var kvRoomInfo: RCVoiceRoomInfo?
    dynamic var voiceRoomInfo: VoiceRoom
    dynamic var seatlist: [RCVoiceSeatInfo] = {
        var list = [RCVoiceSeatInfo]()
        for _ in 0...8 {
            let info = RCVoiceSeatInfo()
            info.status = .empty
            list.append(RCVoiceSeatInfo())
        }
        return list
    }()
    dynamic var managerlist = [VoiceRoomUser]()
    dynamic var userGiftInfo = [String: Int]()
    dynamic var roomState: RoomSettingState
    dynamic var isRoomClosed = false
    dynamic var timer: Timer?
    dynamic var inviterCount: Int = 10

    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomInfoView = SceneRoomInfoView(voiceRoomInfo)
    private(set) lazy var moreButton = UIButton()
    private(set) lazy var ownerView = VoiceRoomMasterView()
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = VoiceRoomSeatCollectionViewCell.cellSize()
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: VoiceRoomSeatCollectionViewCell.self)
        instance.backgroundColor = .clear
        instance.contentInset = UIEdgeInsets(top: 20, left: 23.resize, bottom: 20, right: 23.resize)
        instance.isScrollEnabled = false
        instance.showsVerticalScrollIndicator = false
        return instance
    }()
    private(set) lazy var musicControlVC = VoiceRoomMusicControlViewController(roomId: voiceRoomInfo.roomId)
    private(set) lazy var messageView = RCVRMView()
    private(set) lazy var toolBarView: SceneRoomToolBarView = {
        if currentUserRole() == .creator {
            return SceneRoomToolBarView(toolist: [.userlist, .pk, .gift, .message, .setting])
        } else {
            return SceneRoomToolBarView(toolist: [.requestMic,.gift, .message])
        }
    }()
    lazy var pkView = VoiceRoomPKView()
    private let isCreate: Bool
    
    init(roomInfo: VoiceRoom, isCreate: Bool = false) {
        voiceRoomInfo = roomInfo
        self.isCreate = isCreate
        roomState = RoomSettingState(room: roomInfo)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        RCVoiceRoomEngine.sharedInstance().setDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("voice room deinit")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVoiceRoom()
        buildLayout()
        setupModules()
        addObserver()
        UserDefaults.standard.increaseFeedbackCountdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if parent == nil {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        fetchManagerList()
        toolBarView.refreshUnreadMessageCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if parent == nil {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    private func buildLayout() {
        view.backgroundColor = .clear
        pkView.alpha = 0
        view.addSubview(messageView)
        view.addSubview(ownerView)
        view.addSubview(roomInfoView)
        view.addSubview(collectionView)
        view.addSubview(moreButton)
        view.addSubview(toolBarView)
        view.addSubview(roomNoticeView)
        view.addSubview(pkView)
        
        messageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(278.0 / 375)
            $0.bottom.equalTo(toolBarView.snp.top).offset(-8.resize)
            $0.top.equalTo(collectionView.snp.bottom).offset(21.resize)
        }
        
        roomInfoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(9)
            $0.left.equalToSuperview()
        }
        
        roomNoticeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(roomInfoView.snp.bottom).offset(12)
        }
        
        ownerView.snp.makeConstraints {
            $0.top.equalTo(roomInfoView.snp.bottom).offset(14.resize)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(ownerView.snp.bottom).offset(20.resize)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(roomInfoView)
            $0.right.equalToSuperview().inset(12.resize)
        }
        
        toolBarView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        
        pkView.snp.makeConstraints { make in
            make.top.equalTo(roomNoticeView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(12)
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleNotification(noti: Notification) {
        if isRoomClosed, let vc = UIApplication.shared.topMostViewController(), vc == self {
            navigator(.voiceRoomAlert(title: "当前直播已结束", actions: [.confirm("确定")], alertType: alertTypeVideoAlreadyClose, delegate: self))
        }
    }
    
    //MARK: - dynamic funcs
    ///设置模块，在viewDidLoad中调用
    dynamic func setupModules() {}
    ///消息回调，在engine模块中触发
    dynamic func handleReceivedMessage(_ message: RCMessage) {}
}

extension VoiceRoomViewController {
    private func setupVoiceRoom() {
        SVProgressHUD.show()
        var roomKVInfo: RCVoiceRoomInfo?
        if isCreate {
            let kvRoom = RCVoiceRoomInfo()
            kvRoom.roomName = voiceRoomInfo.roomName
            kvRoom.seatCount = 9
            roomKVInfo = kvRoom
        }
        moreButton.isEnabled = false
        SceneRoomManager.shared
            .join(voiceRoomInfo.roomId, roomKVInfo: roomKVInfo) { [weak self] result in
                RCCall.shared().canIncomingCall = false
                guard let self = self else { return }
                self.moreButton.isEnabled = true
                switch result {
                case .success:
                    SVProgressHUD.dismiss()
                    self.sendJoinRoomMessage()
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
    }
    
    func leaveRoom() {
        SceneRoomManager.shared
            .leave { [weak self] result in
                RCRoomFloatingManager.shared.hide()
                RCCall.shared().canIncomingCall = true
                self?.navigationController?.safe_popToViewController(animated: true)
                switch result {
                case .success:
                    print("leave room success")
                case let .failure(error):
                    print("leave room fail: \(error.localizedDescription)")
                }
            }
    }
    
    /// 关闭房间
    func closeRoom() {
        SVProgressHUD.show()
        VoiceRoomNotification.roomClosed.send(content: voiceRoomInfo.roomId)
        let api: RCNetworkAPI = .closeRoom(roomId: voiceRoomInfo.roomId)
        networkProvider.request(api) { result in
            RCCall.shared().canIncomingCall = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                switch result.map(AppResponse.self) {
                case let .success(response):
                    if response.validate() {
                        SVProgressHUD.showSuccess(withStatus: "直播结束，房间已关闭")
                        self?.leaveRoom()
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
                    }
                case .failure:
                    SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
                }
            }
        }
    }
}

extension VoiceRoomViewController {
    func fetchManagerList() {
        let api: RCNetworkAPI = .roomManagers(roomId: voiceRoomInfo.roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(ManagerListWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managerlist = wrapper.data ?? []
                if wrapper.code == 30001 {
                    self.currentRoomDidClosed()
                }
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func currentRoomDidClosed() {
        view.subviews.forEach {
            if $0 == roomInfoView { return }
            $0.removeFromSuperview()
        }
        roomInfoView.updateRoom(info: voiceRoomInfo)
        
        let tipLabel = UILabel()
        tipLabel.text = "该房间直播已结束"
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.618)
        }
        
        let tipButton = UIButton()
        tipButton.setTitle("返回房间列表", for: .normal)
        tipButton.setTitleColor(.white, for: .normal)
        tipButton.backgroundColor = .lightGray
        tipButton.layer.cornerRadius = 6
        tipButton.layer.masksToBounds = true
        tipButton.addTarget(self, action: #selector(backToRoomList), for: .touchUpInside)
        view.addSubview(tipButton)
        tipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.1)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
    
    @objc private func backToRoomList() {
        leaveRoom()
    }
    
    func currentUserRole() -> VoiceRoomUserType {
        if Environment.currentUserId == voiceRoomInfo.userId {
            return .creator
        }
        if managerlist.contains(where: { Environment.currentUserId == $0.userId }) {
            return .manager
        }
        return .audience
    }
}

extension VoiceRoomViewController: RCRoomCycleProtocol {
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        SceneRoomManager.shared.join(voiceRoomInfo.roomId, complation: completion)
    }
    
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        SceneRoomManager.shared.leave(completion)
    }
    
    func descendantViews() -> [UIView] {
        return [messageView.tableView]
    }
}

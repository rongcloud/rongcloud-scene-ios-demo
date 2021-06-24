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
    
    private(set) lazy var backgroundImageView: AnimatedImageView = {
        let instance = AnimatedImageView()
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        let url = URL(string: voiceRoomInfo.backgroundUrl ?? "")
        instance.kf_setOnlyDiskCacheImage(url)
        return instance
    }()
    private(set) lazy var roomInfoView = RoomInfoView(roomId: voiceRoomInfo.roomId)
    private(set) lazy var moreButton = UIButton()
    private(set) lazy var ownerView = OwnerSeatView()
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
    private(set) lazy var messageView = ChatMessageView(voiceRoomInfo)
    private(set) lazy var toolBarView = VoiceRoomToolBarView(currentUserRole())
    
    init(roomInfo: VoiceRoom) {
        voiceRoomInfo = roomInfo
        roomState = RoomSettingState(room: roomInfo)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        roomState.connectStateChanged = {
           [weak self] state in
            self?.toolBarView.requestMicroButton.setImage(state.image, for: .normal)
            if state == .connecting {
                RCVoiceRoomEngine.sharedInstance().cancelRequestSeat {
                } error: { code, msg in
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("voice room deinit")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        joinVoiceRoom()
        buildLayout()
        setupModules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchManagerList()
        toolBarView.refreshUnreadMessageCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func buildLayout() {
        view.backgroundColor = .black
        view.addSubview(backgroundImageView)
        view.addSubview(messageView)
        view.addSubview(ownerView)
        view.addSubview(roomInfoView)
        view.addSubview(collectionView)
        view.addSubview(moreButton)
        view.addSubview(toolBarView)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        messageView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(toolBarView.snp.top).offset(-8.resize)
            $0.top.equalTo(collectionView.snp.bottom).offset(21.resize)
        }
        
        roomInfoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(9)
            $0.left.equalToSuperview()
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
    }
    
    //MARK: - dynamic funcs
    ///设置模块，在viewDidLoad中调用
    dynamic func setupModules() {}
    ///消息回调，在engine模块中触发
    dynamic func handleReceivedMessage(_ message: RCMessage) {}
}

extension VoiceRoomViewController {
    private func joinVoiceRoom() {
        SVProgressHUD.show()
        moreButton.isEnabled = false
        VoiceRoomManager.shared
            .join(voiceRoomInfo.roomId) { [weak self] result in
                guard let self = self else { return }
                self.moreButton.isEnabled = true
                switch result {
                case .success:
                    SVProgressHUD.dismiss()
                    self.messageView.onUserEnter(Environment.currentUserId)
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
    }
    
    func leaveRoom() {
        VoiceRoomManager.shared
            .leave { [weak self] result in
                switch result {
                case .success:
                    self?.navigationController?.safe_popToViewController(animated: true)
                case let .failure(error):
                    print(error.localizedDescription)
                    self?.navigationController?.safe_popToViewController(animated: true)
                }
            }
    }
    
    /// 关闭房间
    func closeRoom() {
        SVProgressHUD.show()
        VoiceRoomNotification.roomClosed.send(content: voiceRoomInfo.roomId)
        let api: RCNetworkAPI = .closeRoom(roomId: voiceRoomInfo.roomId)
        networkProvider.request(api) { result in
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
                if wrapper.code == 30001 {
                    self?.navigator(.voiceRoomAlert(title: "当前直播已结束", actions: [.confirm("确定")], alertType: alertTypeVideoAlreadyClose, delegate: self))
                }
                self?.managerlist = wrapper.data ?? []
                VoiceRoomSharedContext.shared.managerlist = (wrapper.data ?? []).map(\.userId)
                self?.collectionView.reloadData()
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    func userSeatIndex(userId: String) -> Int? {
        let index = seatlist.firstIndex { info in
            if let seatUserId = info.userId, seatUserId == userId {
                return true
            } else {
                return false
            }
        }
        return index
    }
    
    func isSelfOnSeatNow() -> Bool {
        if let _ = userSeatIndex(userId: Environment.currentUserId) {
            return true
        }
        return false
    }
    
    func currentUserRole() -> VoiceRoomUserType {
        if Environment.currentUserId == voiceRoomInfo.userId {
            return .creator
        }
        if managerlist.contains(where: { user in
            Environment.currentUserId == user.userId
        }) {
            return .manager
        }
        return .audience
    }
    
    func requestSeat() {
        guard self.roomState.connectState == .request else {
            return
        }
        if roomState.isFreeEnterSeat {
            enterSeatIfAvailable()
            return
        }
        RCVoiceRoomEngine.sharedInstance().requestSeat {
            DispatchQueue.main.async {
                SVProgressHUD.showSuccess(withStatus: "已申请连线，等待房主接受")
                self.roomState.connectState = .waiting
            }
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "请求连麦失败\(msg)");
        }
    }
    
    func enterSeatIfAvailable(_ isPicked: Bool = false) {
        RCVoiceRoomEngine.sharedInstance().cancelRequestSeat {} error: { code, msg in }
        let suffixlist = Array(self.seatlist.suffix(from: 1))
        if let index = suffixlist.firstIndex(where: { info in
            info.status == .empty && info.userId == nil
        }) {
            enterSeat(index: index + 1, isPicked)
        } else {
            SVProgressHUD.showError(withStatus: "没有空座了，请稍后重试")
        }
    }
    
    func enterSeat(index: Int, _ isPicked: Bool = false) {
        roomState.isCloseSelfMic = false
        RCVoiceRoomEngine.sharedInstance().enterSeat(UInt(index)) {
            DispatchQueue.main.async {
                if !isPicked {
                    SVProgressHUD.showInfo(withStatus: "上麦成功")
                }
                self.roomState.connectState = .connecting
            }
        } error: { code, msg in
            debugPrint("enter seat error \(msg)")
        }
    }
    
    func leaveSeat(index: UInt, isKickout: Bool = false) {
        RCVoiceRoomEngine.sharedInstance().leaveSeat {
            [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.roomState.isCloseSelfMic = false
                if !isKickout {
                    SVProgressHUD.showSuccess(withStatus: "下麦成功")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "您已被抱下麦")
                }
                if !(self.currentUserRole() == .creator) {
                    self.roomState.connectState = .request
                }
            }
        } error: { code, msg in
            debugPrint("下麦失败\(code) \(msg)")
        }
    }
    
    func setupRequestStateAndMicOrderListState() {
        RCVoiceRoomEngine.sharedInstance()
            .getRequestSeatUserIds { [weak self] userlist in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if self.currentUserRole() == .creator  {
                        self.toolBarView.update(users: userlist.count)
                    } else  {
                        if userlist.contains(Environment.currentUserId) {
                            self.roomState.connectState = .waiting
                        }
                        if self.isSelfOnSeatNow() {
                            self.roomState.connectState = .connecting
                        }
                    }
                }
            } error: { code, msg in
                SVProgressHUD.showError(withStatus: "获取排麦列表失败")
            }
    }
}

extension VoiceRoomViewController: VoiceRoomAlertProtocol {
    func cancelDidClick(alertType: String) {}
    
    func confirmDidClick(alertType: String) {
        switch alertType {
        case alertTypeConfirmCloseRoom:
            leaveRoom()
        case alertTypeVideoAlreadyClose:
            closeRoom()
        default:
            ()
        }
    }
}

//
//  VoiceRoomViewController+Seats.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/18.
//

import SVProgressHUD
import RCSceneMusic

extension VoiceRoomViewController {
    @_dynamicReplacement(for: seatlist)
    private var seats_seatlist: [RCVoiceSeatInfo] {
        get { seatlist }
        set {
            seatlist = newValue
            collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.updateCollectionViewHeight()
            })
            
            if let seatInfo = seatlist.first {
                ownerView.updateOwner(seatInfo: seatInfo)
                ownerView.updateGiftVales(giftValues: userGiftInfo)
            }
            /// 当麦位数量变化时，触发连麦用户下麦，需要更新状态
            if roomState.connectState == .connecting {
                roomState.connectState = isSitting() ? .connecting : .request
            } else if isSitting() {
                micButton.micState = voiceRoomInfo.isOwner ? .user : .connecting
            }

            if seatlist.contains(where: { $0.userId == Environment.currentUserId }) {
                self.roomContainerAction?.disableSwitchRoom()
            } else if voiceRoomInfo.isOwner == false {
                self.roomContainerAction?.enableSwitchRoom()
            }
        }
    }
    
    @_dynamicReplacement(for: managers)
    private var seats_managers: [VoiceRoomUser] {
        get { managers }
        set {
            managers = newValue
            SceneRoomManager.shared.managers = managers.map(\.userId)
            messageView.tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    @_dynamicReplacement(for: userGiftInfo)
    var seats_userGiftInfo: [String: Int] {
        get {
            return userGiftInfo
        }
        set {
            userGiftInfo = newValue
            collectionView.reloadData()
            ownerView.updateGiftVales(giftValues: userGiftInfo)
        }
    }
    
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func updateCollectionViewHeight() {
        let height = collectionView.contentSize.height
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(height + 20)
        }
        view.layoutIfNeeded()
    }
}

extension VoiceRoomViewController {
    func requestSeat() {
        if roomState.connectState == .waiting {
            navigator(.requestSeatPop(delegate: self))
            return
        }
        guard roomState.connectState == .request else {
            return
        }
        if roomState.isFreeEnterSeat {
            return enterSeatIfAvailable()
        }
        RCVoiceRoomEngine.sharedInstance()
            .requestSeat { [weak self] in
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "已申请连线，等待房主接受")
                    self?.roomState.connectState = .waiting
                }
            } error: { code, msg in
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: "请求连麦失败\(msg)")
                }
            }
    }
    
    func enterSeatIfAvailable(_ isPicked: Bool = false) {
        RCVoiceRoomEngine.sharedInstance().cancelRequestSeat {} error: { code, msg in }
        if let index = seatlist[1..<seatlist.count].firstIndex(where: { $0.isEmpty }) {
            enterSeat(index: index, isPicked)
        } else {
            SVProgressHUD.showError(withStatus: "没有空座了，请稍后重试")
        }
    }
    
    typealias EnterSeatCompletion = () -> Void
    func enterSeat(index: Int, _ isPicked: Bool = false, completion: EnterSeatCompletion? = nil) {
        if roomState.isEnterSeatWaiting { return }
        roomState.isEnterSeatWaiting.toggle()
        RCVoiceRoomEngine.sharedInstance()
            .enterSeat(UInt(index)) { [weak self] in
                self?.roomState.isEnterSeatWaiting.toggle()
                DispatchQueue.main.async {
                    if !isPicked {
                        SVProgressHUD.showInfo(withStatus: "上麦成功")
                    }
                    self?.roomState.connectState = .connecting
                    self?.roomContainerAction?.disableSwitchRoom()
                    completion?()
                }
            } error: { [weak self] code, msg in
                self?.roomState.isEnterSeatWaiting.toggle()
                debugPrint("enter seat error \(msg)")
                completion?()
            }
    }
    
    func leaveSeat(isKickout: Bool = false) {
        RCVoiceRoomEngine.sharedInstance().leaveSeat {
            [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if !isKickout {
                    SVProgressHUD.showSuccess(withStatus: "下麦成功")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "您已被抱下麦")
                }
                if !(self.currentUserRole() == .creator) {
                    self.roomState.connectState = .request
                    self.roomContainerAction?.enableSwitchRoom()
                }
                if self.voiceRoomInfo.isOwner {
                    let _ = PlayerImpl.instance.stopMixing(with: nil)
                }
            }
        } error: { code, msg in
            debugPrint("下麦失败\(code) \(msg)")
        }
    }
    
    func isSitting(_ userId: String = Environment.currentUserId) -> Bool {
        return seatlist.contains { $0.userId == userId }
    }
    
    func seatIndex(of userId: String = Environment.currentUserId) -> Int? {
        return seatlist.firstIndex { $0.userId == userId }
    }
}

//MARK: - Seat CollectionView DataSource
extension VoiceRoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seatlist.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomSeatCollectionViewCell.self)
        cell.update(seatInfo: seatlist[indexPath.row + 1],
                    index: indexPath.row + 1,
                    managers: managers,
                    giftValues: userGiftInfo)
        return cell
    }
}

extension VoiceRoomViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let seatIndex = indexPath.row + 1
        let seatInfo = seatlist[seatIndex]
        switch seatInfo.status {
        case .empty:
            if currentUserRole() == .creator {
                navigator(.ownerClickEmptySeat(seatInfo, UInt(seatIndex), self))
            } else {
                if isSitting() {
                    if roomState.isEnterSeatWaiting { return }
                    roomState.isEnterSeatWaiting.toggle()
                    RCVoiceRoomEngine.sharedInstance().switchSeat(to: UInt(seatIndex)) {
                        [weak self] in
                        guard let self = self else { return }
                        self.roomState.isEnterSeatWaiting.toggle()
                        guard !self.seatlist[seatIndex].isMuted else { return }
                    } error: { [weak self] code, msg in
                        self?.roomState.isEnterSeatWaiting.toggle()
                    }
                } else {
                    if roomState.isFreeEnterSeat {
                        enterSeat(index: seatIndex)
                    } else {
                        requestSeat()
                    }
                }
            }
        case .using:
            guard let userId = seatInfo.userId else {
                return
            }
            if userId == Environment.currentUserId {
                let seatInfo = self.seatlist[seatIndex]
                navigator(.userSeatPop(seatIndex: UInt(seatIndex), isUserMute: roomState.isCloseSelfMic, isSeatMute: seatInfo.isMuted, delegate: self))
            } else {
                operate(userId)
            }
        case .locking:
            if currentUserRole() == .creator {
                navigator(.ownerClickEmptySeat(seatInfo, UInt(seatIndex), self))
            } else {
                if isSitting() {
                    SVProgressHUD.showError(withStatus: "该座位已经被锁定")
                }
            }
        @unknown default:
            fatalError()
        }
    }
}

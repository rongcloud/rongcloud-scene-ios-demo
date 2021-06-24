//
//  VoiceRoomViewController+Seats.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/18.
//

import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: seatlist)
    private var inner_seatlist: [RCVoiceSeatInfo] {
        get {
            return seatlist
        }
        set {
            seatlist = newValue
            VoiceRoomSharedContext.shared.seatlist = seatlist
            
            collectionView.reloadData()
            view.layoutIfNeeded()
            
            if let seatInfo = seatlist.first {
                ownerView.updateOwner(seatInfo: seatInfo)
                ownerView.updateGiftVales(giftValues: userGiftInfo)
            }
            
            let height = collectionView.contentSize.height
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(height + 20)
            }
            
            if isSelfOnSeatNow() {
                roomState.connectState = .connecting
            }
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
        ownerView.delegate = self
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
                    managerlist: managerlist,
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
                if isSelfOnSeatNow() {
                    RCVoiceRoomEngine.sharedInstance().switchSeat(to: UInt(seatIndex)) {
                        [weak self] in
                        guard let self = self else { return }
                        guard !self.seatlist[seatIndex].isMuted else { return }
                        RCVoiceRoomEngine.sharedInstance().disableAudioRecording(self.roomState.isCloseSelfMic)
                    } error: { code, msg in

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
                navigator(.manageUser(dependency: ManageUserDependency(roomId: voiceRoomInfo.roomId, roomCreator: voiceRoomInfo.userId, presentUserId: userId), delegate: self))
            }
        case .locking:
            if currentUserRole() == .creator {
                navigator(.ownerClickEmptySeat(seatInfo, UInt(seatIndex), self))
            } else {
                if isSelfOnSeatNow() {
                    SVProgressHUD.showError(withStatus: "该座位已经被锁定")
                }
            }
        @unknown default:
            fatalError()
        }
    }
}

// MARK: - Owner Seat View Click Delegate
extension VoiceRoomViewController: OwnerSeatViewProtocol {
    private func mineSeatIndex() -> Int? {
        return userSeatIndex(userId: Environment.currentUserId)
    }
    
    func ownerSeatViewDidClick() {
        if currentUserRole() == .creator {
            if let index = mineSeatIndex(), index == 0 {
                let isMute = self.seatlist.first?.isMuted ?? false
                self.navigator(.ownerSeatPop(Environment.currentUserId, isMute, self))
            } else {
                self.enterSeat(index: 0)
            }
        }
    }
}

// MARK: - User Click Seat Pop View Delegate
extension VoiceRoomViewController: ManageOwnSeatProtocol {
    func userSeatSilenceButtonDidClick(seatIndex: UInt, isMute: Bool) {
        roomState.isCloseSelfMic = isMute
        RCVoiceRoomEngine.sharedInstance().disableAudioRecording(isMute)
    }
    
    func userSeatDidLeaveClick(seatIndex: UInt) {
        guard let userId = seatlist[Int(seatIndex)].userId, userId == Environment.currentUserId else {
            SVProgressHUD.showError(withStatus: "您当前没在麦上")
            return
        }
        leaveSeat(index: seatIndex)
    }
}

// MARK: - Owenr Seat Pop View Delegate
extension VoiceRoomViewController: ManageOwnerSeatProtocol {
    func muteSeatDidClick(isMute: Bool) {
        muteSeat(isMute: isMute, seatIndex: 0)
    }
    
    func leaveSeatDidClick() {
        leaveSeat(index: 0)
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension VoiceRoomViewController: ManageUserProtocol {
    func didSetManager(userId: String, isManager: Bool) {
        fetchManagerList()
        let roomId = voiceRoomInfo.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
            let event = RCChatroomAdmin()
            event.userId = user.userId
            event.userName = user.userName
            event.isAdmin = isManager
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] mId in
                guard let self = self else { return }
                self.messageView.add(event)
            } error: { errorCode, mId in
            }
        }
        VoiceRoomNotification.mangerlistNeedRefresh.send(content: "")
        if isManager {
            SVProgressHUD.showSuccess(withStatus: "已设为管理员")
        } else {
            SVProgressHUD.showSuccess(withStatus: "已撤回管理员")
        }
    }
    
    func kickUserOffSeat(seatIndex: UInt) {
        guard let userId = self.seatlist[Int(seatIndex)].userId else {
            return
        }
        RCVoiceRoomEngine.sharedInstance().kickUser(fromSeat: userId) {
            SVProgressHUD.showSuccess(withStatus: "发送下麦通知成功")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "发送下麦通知失败")
        }
    }
    
    func lockSeatDidClick(isLock: Bool, seatIndex: UInt) {
        RCVoiceRoomEngine.sharedInstance().lockSeat(seatIndex, lock: isLock) {
            
        } error: { code, msg in
            
        }
    }
    
    func muteSeat(isMute: Bool, seatIndex: UInt) {
        RCVoiceRoomEngine.sharedInstance().muteSeat(seatIndex, mute: isMute) {
            if isMute {
                SVProgressHUD.showSuccess(withStatus: "此麦位已闭麦")
            } else {
                SVProgressHUD.showSuccess(withStatus: "已取消闭麦")
            }
        } error: { code, msg in
            
        }

    }
    
    func kickoutRoom(userId: String) {
        RCVoiceRoomEngine.sharedInstance().kickUser(fromRoom: userId) {
        } error: { code, msg in
        }
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didClickedPrivateChat(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedPrivateChat(userId: userId)
            }
            return
        }
        navigator(.privateChat(userId: userId))
    }
    
    func didClickedSendGift(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedSendGift(userId: userId)
            }
            return
        }
        let dependency = VoiceRoomGiftDependency(roomId: voiceRoomInfo.roomId,
                                                 roomUserId: voiceRoomInfo.userId,
                                                 seats: seatlist,
                                                 userIds: [userId])
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
    func didClickedInvite(userId: String) {
        inviteUserToSeat(userId: userId)
    }
}

// MARK: - Owner Click Empty User Seat Pop View Delegate
extension VoiceRoomViewController: ManageEmptySeatProtocol {
    func ownerlockEmptySeat(isLock: Bool, seatIndex: UInt) {
        let title = isLock ? "关闭" : "打开"
        RCVoiceRoomEngine.sharedInstance().lockSeat(seatIndex, lock: isLock) {
            SVProgressHUD.showSuccess(withStatus: "\(title)\(seatIndex)号麦位成功")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "\(title)\(seatIndex)号麦位失败")
        }
    }
    
    func muteEmptySeat(isMute: Bool, seatIndex: UInt) {
        muteSeat(isMute: isMute, seatIndex: seatIndex)
    }
    
    func inviteUserDidClick() {
        navigator(.requestOrInvite(roomId: voiceRoomInfo.roomId, delegate: self, showPage: 1, onSeatUserIds: seatlist.compactMap(\.userId)))
    }
}

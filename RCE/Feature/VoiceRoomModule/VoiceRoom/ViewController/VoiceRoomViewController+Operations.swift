//
//  VoiceRoomViewController+Operations.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/30.
//

import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupOperationModule() {
        setupModules()
        ownerView.delegate = self
    }
    
    private func showMusicAlert() {
        let vc = UIAlertController(title: "播放音乐中下麦会导致音乐终端，是否确定下麦？", message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.leaveSeat()
            self.dismiss(animated: true, completion: nil)
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        let topVC = UIApplication.shared.topMostViewController()
        topVC?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Owner Seat View Click Delegate
extension VoiceRoomViewController: VoiceRoomMasterViewProtocol {
    func masterViewDidClick() {
        guard currentUserRole() == .creator else { return }
        guard let index = seatIndex(), index == 0 else {
            return enterSeat(index: 0)
        }
        let isMute = seatlist.first?.isMuted ?? false
        let navigation = RCNavigation.masterSeatOperation(Environment.currentUserId, isMute, self)
        navigator(navigation)
    }
}

// MARK: - Owenr Seat Pop View Delegate
extension VoiceRoomViewController: VoiceRoomMasterSeatOperationProtocol {
    func didMasterSeatMuteButtonClicked(_ isMute: Bool) {
        muteSeat(isMute: isMute, seatIndex: 0)
    }
    
    func didMasterLeaveButtonClicked() {
        if SceneRoomManager.shared.currentPlayingStatus == .mixingStatePlaying {
            showMusicAlert()
        } else {
            leaveSeat()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension VoiceRoomViewController: VoiceRoomSeatedOperationProtocol {
    func seated(_ index: UInt, _ mute: Bool) {
        roomState.isCloseSelfMic = mute
        RCVoiceRoomEngine.sharedInstance().disableAudioRecording(mute)
    }
    
    func seatedDidLeaveClicked() {
        guard isSitting() else { return }
        leaveSeat()
    }
}

// MARK: - Owner Click Empty User Seat Pop View Delegate
extension VoiceRoomViewController: VoiceRoomEmptySeatOperationProtocol {
    func emptySeat(_ index: UInt, isLock: Bool) {
        let title = isLock ? "关闭" : "打开"
        RCVoiceRoomEngine.sharedInstance().lockSeat(index, lock: isLock) {
            SVProgressHUD.showSuccess(withStatus: "\(title)\(index)号麦位成功")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "\(title)\(index)号麦位失败")
        }
    }
    
    func emptySeat(_ index: UInt, isMute: Bool) {
        muteSeat(isMute: isMute, seatIndex: index)
    }
    
    func emptySeatInvitationDidClicked() {
        let navigation = RCNavigation.requestOrInvite(roomId: voiceRoomInfo.roomId,
                                                      delegate: self,
                                                      showPage: 1,
                                                      onSeatUserIds: seatlist.compactMap(\.userId))
        navigator(navigation)
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension VoiceRoomViewController: VoiceRoomUserOperationProtocol {
    /// 抱下麦
    func kickUserOffSeat(seatIndex: UInt) {
        guard let userId = seatlist[Int(seatIndex)].userId else {
            return
        }
        RCVoiceRoomEngine.sharedInstance().kickUser(fromSeat: userId) {
            SVProgressHUD.showSuccess(withStatus: "发送下麦通知成功")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "发送下麦通知失败")
        }
    }
    /// 锁座位
    func lockSeatDidClick(isLock: Bool, seatIndex: UInt) {
        RCVoiceRoomEngine.sharedInstance()
            .lockSeat(seatIndex, lock: isLock) {} error: { code, msg in }
    }
    /// 座位静音
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
    /// 踢出房间
    func kickoutRoom(userId: String) {
        let roomId = voiceRoomInfo.roomId
        RCVoiceRoomEngine.sharedInstance().kickUser(fromRoom: userId) {
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { targetUser in
                    let event = RCChatroomKickOut()
                    event.userId = user.userId
                    event.userName = user.userName
                    event.targetId = targetUser.userId
                    event.targetName = targetUser.userName
                    RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] _ in
                        self?.messageView.add(event)
                    } error: { _, _ in }
                }
            }
        } error: { code, msg in }
        UIApplication.shared.keyWindow()?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
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
        let dependency = VoiceRoomGiftDependency(room: voiceRoomInfo,
                                                 seats: seatlist,
                                                 userIds: [userId])
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
    func didClickedInvite(userId: String) {
        inviteUserToSeat(userId: userId)
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        let roomId = voiceRoomInfo.roomId
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { followUser in
            guard isFollow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                self?.messageView.add(message)
                RCChatroomMessageCenter.sendChatMessage(roomId, content: message) { mId in
                    print("send message seccuss: \(mId)")
                } error: { eCode, mId in
                    print("send message fail: \(mId), code: \(eCode.rawValue)")
                }
                
            }
        }
    }
}

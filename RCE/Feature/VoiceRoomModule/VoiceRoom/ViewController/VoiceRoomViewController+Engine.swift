//
//  VoiceRoomViewController+Engine.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/18.
//

import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        RCVoiceRoomEngine.sharedInstance().setDelegate(self)
    }
    
    private func handleReceivePickSeat(from: String) {
        var inviter = "房主"
        if managerlist.map(\.userId).contains(from) {
            inviter = "管理员"
        }
        let alertVC = UIAlertController(title: "是否同意上麦", message: "您被\(inviter)邀请上麦，是否同意？", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "同意", style: .default, handler: { _ in
            self.enterSeatIfAvailable()
            VoiceRoomNotification.agreeManagePick.send(content: from)
        }))
        alertVC.addAction(UIAlertAction(title: "拒绝", style: .cancel, handler: { _ in
            VoiceRoomNotification.rejectManagePick.send(content: from)
        }))
        topMostViewController().present(alertVC, animated: true, completion: nil)
    }
}

//MARK: - Voice Room Delegate
extension VoiceRoomViewController: RCVoiceRoomDelegate {
    func roomDidOccurError(_ code: RCVoiceRoomErrorCode) {
        if code == .syncRoomInfoFailed {
            SVProgressHUD.showError(withStatus: "房间初始化信息失败，请关闭房间重新创建")
        }
    }
    
    func roomKVDidReady() {
        if currentUserRole() == .creator {
            enterSeat(index: 0)
        }
        roomInfoView.updateRoomUserNumber()
    }
    
    func roomInfoDidUpdate(_ roomInfo: RCVoiceRoomInfo) {
        kvRoomInfo = roomInfo
    }
    
    func seatInfoDidUpdate(_ seatInfolist: [RCVoiceSeatInfo]) {
        seatlist = seatInfolist
    }
    
    func userDidEnterSeat(_ seatIndex: Int, user userId: String) {
    }
    
    func userDidLeaveSeat(_ seatIndex: Int, user userId: String) {
    }
    
    func seatDidMute(_ index: Int, isMute: Bool) {
        let seatInfo = seatlist[index]
        if !isMute, seatInfo.userId == Environment.currentUserId {
            RCVoiceRoomEngine.sharedInstance().disableAudioRecording(roomState.isCloseSelfMic)
        }
    }
    
    func seatDidLock(_ index: Int, isLock: Bool) {
    }
    
    func userDidEnter(_ userId: String) {
        roomInfoView.updateRoomUserNumber()
        messageView.onUserEnter(userId)
    }
    
    func userDidExit(_ userId: String) {
        roomInfoView.updateRoomUserNumber()
    }
    
    func speakingStateDidChange(_ seatIndex: UInt, speakingState isSpeaking: Bool) {
        if seatIndex == 0 {
            ownerView.setSpeakingState(isSpeaking: isSpeaking)
        } else {
            if let cell = collectionView.cellForItem(at: IndexPath(item: Int(seatIndex - 1), section: 0)) as? VoiceRoomSeatCollectionViewCell {
                cell.setSpeakingState(isSpeaking: isSpeaking)
            }
        }
    }
    
    func messageDidReceive(_ message: RCMessage) {
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }
    
    func roomNotificationDidReceive(_ name: String, content: String) {
        guard let type = VoiceRoomNotification(rawValue: name) else {
            return
        }
        switch type {
        case .backgroundChanged:
            let url = URL(string: content)
            backgroundImageView.kf_setOnlyDiskCacheImage(url)
        case .mangerlistNeedRefresh:
            fetchManagerList()
        case .roomClosed:
            navigator(.voiceRoomAlert(title: "当前直播已结束", actions: [.confirm("确定")], alertType: alertTypeVideoAlreadyClose, delegate: self))
        case .rejectManagePick:
            if content == Environment.currentUserId {
                SVProgressHUD.showError(withStatus: "用户拒绝邀请")
            }
        case .agreeManagePick:
            if content == Environment.currentUserId {
                SVProgressHUD.showSuccess(withStatus: "用户连线成功")
            }
        }
    }
    
    func pickSeatDidReceive(by userId: String) {
        handleReceivePickSeat(from: userId)
    }
    
    func kickSeatDidReceive(_ seatIndex: UInt) {
        self.roomState.isCloseSelfMic = false
        SVProgressHUD.showSuccess(withStatus: "您已被抱下麦")
        if !(currentUserRole() == .creator) {
            self.roomState.connectState = .request
        }
    }
    
    func requestSeatDidAccept() {
        enterSeatIfAvailable()
    }
    
    func requestSeatDidReject() {
        SVProgressHUD.showError(withStatus: "您的连麦请求被拒绝")
    }
    
    func requestSeatListDidChange() {
        setupRequestStateAndMicOrderListState()
    }
    
    func invitationDidReceive(_ invitationId: String, from userId: String, content: String) {
    }
    
    func invitationDidAccept(_ invitationId: String) {
    }
    
    func invitationDidReject(_ invitationId: String) {
    }
    
    func invitationDidCancel(_ invitationId: String) {
    }
    
    func userDidKick(fromRoom targetId: String, byUserId userId: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: targetId) { targetUser in
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
                guard let self = self else { return }
                if targetId == Environment.currentUserId {
                    let managerUserList = self.managerlist.map(\.userId)
                    if managerUserList.contains(userId) {
                        SVProgressHUD.showInfo(withStatus: "您被管理员\(user.userName)踢出房间")
                    } else {
                        SVProgressHUD.showInfo(withStatus: "您被踢出房间")
                    }
                    
                    self.leaveRoom()
                }
                let event = RCChatroomKickOut()
                event.userId = user.userId
                event.userName = user.userName
                event.targetId = targetUser.userId
                event.targetName = targetUser.userName
                self.messageView.add(event)
            }
        }
        roomInfoView.updateRoomUserNumber()
    }
}

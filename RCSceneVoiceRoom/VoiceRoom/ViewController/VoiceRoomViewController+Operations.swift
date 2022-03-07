//
//  VoiceRoomViewController+Operations.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/30.
//

import UIKit
import SVProgressHUD

import RCSceneGift
import RCSceneChat
import RCSceneModular
import RCSceneMessage

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
    
    func operate(_ userId: String) {
        let role: SceneRoomUserType = {
            if voiceRoomInfo.userId == Environment.currentUserId {
                return .creator
            }
            if SceneRoomManager.shared.managers.contains(userId) {
                return .manager
            }
            return .audience
        }()
        let index = seatlist.firstIndex { seat in
            seat.userId == userId
        }
        let seat = seatlist.first { seat in
            seat.userId == userId
        }
        let lock: Bool = seat?.status == .locking
        let dependency = UserOperationDependency(room: voiceRoomInfo,
                                                 userId: userId,
                                                 userRole: role,
                                                 userSeatIndex: index,
                                                 userSeatMute: seat?.isMuted,
                                                 userSeatLock: lock)
        navigator(.manageUser(dependency: dependency, delegate: self))
    }
}

// MARK: - Owner Seat View Click Delegate
extension VoiceRoomViewController: VoiceRoomMasterViewProtocol {
    func masterViewDidClick() {
        guard currentUserRole() == .creator else { return }
        guard let index = seatIndex(), index == 0 else {
            return enterSeat(index: 0)
        }
        var disableRecording = false
        if let seatInfo = seatlist.first {
            disableRecording = seatInfo.disableRecording
        }
        let navigation = RCNavigation.masterSeatOperation(Environment.currentUserId, disableRecording, self)
        navigator(navigation)
    }
}

// MARK: - Owenr Seat Pop View Delegate
extension VoiceRoomViewController: VoiceRoomMasterSeatOperationProtocol {
    func didMasterSeatMuteButtonClicked(_ isMute: Bool) {
        RCVoiceRoomEngine.sharedInstance().disableAudioRecording(isMute)
        let seatInfo = RoomSeatInfoExtra(disableRecording: isMute)
        if let jsonString = seatInfo.toJsonString() {
            RCVoiceRoomEngine.sharedInstance().updateSeatInfo(0, withExtra: jsonString) {} error: { _, _ in }
        }
    }
    
    func didMasterLeaveButtonClicked() {
        if SceneRoomManager.shared.currentPlayingStatus == RCRTCAudioMixingState.mixingStatePlaying {
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
extension VoiceRoomViewController: UserOperationProtocol {
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
        RCVoiceRoomEngine.sharedInstance().kickUser(fromRoom: userId) {
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { targetUser in
                    let event = RCChatroomKickOut()
                    event.userId = user.userId
                    event.userName = user.userName
                    event.targetId = targetUser.userId
                    event.targetName = targetUser.userName
                    ChatroomSendMessage(event, messageView: self.messageView)
                }
            }
        } error: { code, msg in }
        UIApplication.shared.keyWindow()?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didSetManager(userId: String, isManager: Bool) {
        fetchmanagers()
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
            let event = RCChatroomAdmin()
            event.userId = user.userId
            event.userName = user.userName
            event.isAdmin = isManager
            ChatroomSendMessage(event, messageView: self.messageView)
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
        let vc = ChatViewController(.ConversationType_PRIVATE, userId: userId)
        vc.canCallComing = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickedSendGift(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedSendGift(userId: userId)
            }
            return
        }
         
        let seatUsers: [String] = seatlist.map { $0.userId ?? "" }
        let dependency = VoiceRoomGiftDependency(room: voiceRoomInfo,
                                                 seats: seatUsers,
                                                 userIds: [userId])
        navigator(.gift(dependency: dependency, delegate: self))
         
    }
    
    func didClickedInvite(userId: String) {
        inviteUserToSeat(userId: userId)
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { followUser in
            guard isFollow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                ChatroomSendMessage(message, messageView: self?.messageView)
            }
        }
    }
}

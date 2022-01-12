//
//  LiveVideoRoomHostController+User.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD

extension LiveVideoRoomHostController {
    @objc func liveVideoRequestDidClick() {
        switch micButton.micState {
        case .user:
            let controller = RCLVMicViewController()
            controller.delegate = self
            present(controller, animated: true)
        case .waiting:
            let controller = RCLVRCancelMicViewController(.invite, delegate: self)
            present(controller, animated: true)
        case .connecting:
            let controller = RCLVRCancelMicViewController(.connection, delegate: self)
            present(controller, animated: true)
        default: ()
        }
    }
}

extension LiveVideoRoomHostController: RCLiveVideoCancelDelegate {
    func didCancelLiveVideo(_ action: RCLVRCancelMicType) {
        switch action {
        case .request: ()
        case .invite:
            RCLiveVideoEngine.shared().getInvitations { code, userIds in
                guard let userId = userIds.first else { return }
                RCLiveVideoEngine.shared().cancelInvitation(userId) { _ in
                    /// code
                }
            }
            micButton.micState = .user
        case .connection:
            let seat = RCLiveVideoEngine.shared().currentSeats.last { $0.userId.count > 0 }
            guard
                let userId = seat?.userId,
                userId != Environment.currentUserId
            else { return }
            RCLiveVideoEngine.shared()
                .kickUser(fromSeat:userId, completion: { code in
                    debugPrint("kickUser \(code.rawValue)")
                })
            micButton.micState = .user
        }
    }
}

extension LiveVideoRoomHostController: RCLVMicViewControllerDelegate {
    func didAcceptSeatRequest(_ user: VoiceRoomUser) {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne:
            micButton.micState = .connecting
        default:
            micButton.micState = .user
        }
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.micButton.setBadgeCount(userIds.count)
        }
    }
    
    func didRejectRequest(_ user: VoiceRoomUser) {
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.micButton.setBadgeCount(userIds.count)
        }
    }
    
    func didSendInvitation(_ user: VoiceRoomUser) {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne:
            micButton.micState = .waiting
        default:
            micButton.micState = .user
        }
    }
    
    func didSwitchMixType(_ type: RCLiveVideoMixType) {
        if type != RCLiveVideoEngine.shared().currentMixType {
            roomMixTypeDidChange(type)
        }
//        let mixType: RCLiveVideoMixType = type == .gridThree ? .custom : type
        RCLiveVideoEngine.shared().setMixType(type) { [weak self] code in
            switch code {
            case .success:
                debugPrint("switch success")
                let message = RCTextMessage(content: "麦位布局已修改，请重新上麦")!
                message.extra = "mixTypeChange"
                RCLiveVideoEngine.shared().sendMessage(message) { code in
                    self?.chatroomView.messageView.addMessage(message)
                }
            case .mixSame: ()
            default: SVProgressHUD.showError(withStatus: "切换布局失败")
            }
        }
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension LiveVideoRoomHostController: VoiceRoomUserOperationProtocol {
    /// 踢出房间
    func kickoutRoom(userId: String) {
        presentedViewController?.dismiss(animated: true)
        RCLiveVideoEngine.shared().kickOutRoom(userId) { [weak self] code in
            self?.handleKickOutRoom(userId, by: Environment.currentUserId)
        }
    }
    
    /// 抱下麦
    func kickUserOffSeat(seatIndex: UInt) {
        presentedViewController?.dismiss(animated: true)
        let userId = SceneRoomManager.shared.seatlist[Int(seatIndex)].userId!
        RCLiveVideoEngine.shared().kickUser(fromSeat:userId) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "抱下麦成功")
            } else {
                SVProgressHUD.showError(withStatus: "抱下麦失败")
            }
        }
    }
    
    func didSetManager(userId: String, isManager: Bool) {
        let roomId = room.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
            let event = RCChatroomAdmin()
            event.userId = user.userId
            event.userName = user.userName
            event.isAdmin = isManager
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] mId in
                guard let self = self else { return }
                self.messageView.addMessage(event)
                if isManager {
                    self.managers.append(user)
                } else {
                    self.managers.removeAll(where: { $0.userId == userId })
                }
            } error: { errorCode, mId in }
        }
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
        SceneRoomManager.updateLiveSeatList()
        let dependency = VoiceRoomGiftDependency(room: room,
                                                 seats: SceneRoomManager.shared.seatlist,
                                                 userIds: [userId])
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        let roomId = room.roomId
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { followUser in
            guard isFollow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                RCChatroomMessageCenter.sendChatMessage(roomId, content: message) { mId in
                    print("send message seccuss: \(mId)")
                } error: { eCode, mId in
                    print("send message fail: \(mId), code: \(eCode.rawValue)")
                }
                self?.messageView.addMessage(message)
            }
        }
    }
    
    func didClickedInvite(userId: String) {
        RCLiveVideoEngine.shared().inviteLiveVideo(userId, at: -1) { [weak self] code in
            switch code {
            case .success:
                if RCLiveVideoEngine.shared().currentMixType == .oneToOne {
                    self?.micButton.micState = .waiting
                }
                SVProgressHUD.showSuccess(withStatus: "已邀请上麦")
            default:
                SVProgressHUD.showError(withStatus: "邀请失败")
            }
        }
    }
}

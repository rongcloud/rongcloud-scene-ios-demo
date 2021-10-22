//
//  LiveVideoRoomHostController+User.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD

extension LiveVideoRoomHostController {
    @objc func liveVideoRequestDidClick() {
        switch toolBarView.micState {
        case .request:
            let controller = RCLVMicViewController()
            controller.delegate = self
            controller.modalPresentationStyle = .overFullScreen
            present(controller, animated: true)
        case .waiting:
            let controller = RCLVRCancelMicViewController(.invite, delegate: self)
            present(controller, animated: true)
        case .connecting:
            let controller = RCLVRCancelMicViewController(.connection, delegate: self)
            present(controller, animated: true)
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
            toolBarView.micState = .request
        case .connection:
            let userId = RCLiveVideoEngine.shared().liveVideoUserIds.first
            if let currentUserId = userId {
                RCLiveVideoEngine.shared()
                    .finishLiveVideo(currentUserId, completion: { [weak self] _ in
                        self?.layoutLiveVideoView([:])
                    })
            }
            toolBarView.micState = .request
        }
    }
}

extension LiveVideoRoomHostController: RCLVMicViewControllerDelegate {
    func didAcceptSeatRequest(_ user: VoiceRoomUser) {
        toolBarView.micState = .connecting
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.toolBarView.update(users: userIds.count)
        }
    }
    
    func didRejectRequest(_ user: VoiceRoomUser) {
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.toolBarView.update(users: userIds.count)
        }
    }
    
    func didSendInvitation(_ user: VoiceRoomUser) {
        toolBarView.micState = .waiting
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension LiveVideoRoomHostController: VoiceRoomUserOperationProtocol {
    /// 踢出房间
    func kickoutRoom(userId: String) {
        presentedViewController?.dismiss(animated: true)
        RCLiveVideoEngine.shared().kickOutRoom(userId) { [weak self] code in
            self?.handleKickOutRoom(userId, by: Environment.currentUserId)
            self?.roomInfoView.updateRoomUserNumber()
        }
    }
    
    /// 抱下麦
    func kickUserOffSeat(seatIndex: UInt) {
        presentedViewController?.dismiss(animated: true)
        let userId = SceneRoomManager.shared.seatlist[Int(seatIndex)].userId!
        RCLiveVideoEngine.shared().finishLiveVideo(userId) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "发送下麦通知成功")
            } else {
                SVProgressHUD.showError(withStatus: "发送下麦通知失败")
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
                self.messageView.add(event)
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
        let dependency = VoiceRoomGiftDependency(room: room,
                                                 seats: [],
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
                self?.messageView.add(message)
            }
        }
    }
    
    func didClickedInvite(userId: String) {
        RCLiveVideoEngine.shared().inviteLiveVideo(userId, at: -1) { [weak self] code in
            switch code {
            case .success:
                self?.toolBarView.micState = .waiting
            case .invitationIsFull:
                SVProgressHUD.showError(withStatus: "上麦邀请队列已满")
            case .liveVideoIsFull:
                SVProgressHUD.showError(withStatus: "麦位已满")
            default:
                SVProgressHUD.showError(withStatus: "邀请失败")
            }
        }
    }
}

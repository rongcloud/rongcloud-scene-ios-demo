//
//  LiveVideoRoomViewController+User.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import UIKit
import RCSceneGift

let NotificationNameDidFollowUser = Notification.Name("NotificationNameDidFollowUser")

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewWillAppear(_:))
    private func users_viewWillAppear(_ animated: Bool) {
        m_viewWillDisappear(animated)
        fetchmanagers()
        if (needHandleFloatingBack) {
            needHandleFloatingBack = false
            floatingBack()
        }
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func message_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard let content = message.content else { return }
        if content.isKind(of: RCChatroomAdmin.self) {
            fetchmanagers()
        }
    }
    
    func fetchmanagers() {
        videoRoomService.roomManagers(roomId: room.roomId) { [weak self] result in
            switch result.map(managersWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managers = wrapper.data ?? []
                SceneRoomManager.shared.managers = self.managers.map { $0.userId }
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension LiveVideoRoomViewController: UserOperationProtocol {
    /// 踢出房间
    func kickoutRoom(userId: String) {
        RCLiveVideoEngine.shared().kickOutRoom(userId) { [weak self] _ in
            self?.handleKickOutRoom(userId, by: Environment.currentUserId)
            self?.roomCountingView.updateRoomUserNumber()
        }
    }
    
    /// 抱下麦
    func kickUserOffSeat(seatIndex: UInt) {
        let userId = SceneRoomManager.shared.seatlist[Int(seatIndex)]
        RCLiveVideoEngine.shared().kickUser(fromSeat:userId) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "抱下麦成功")
            } else {
                SVProgressHUD.showError(withStatus: "抱下麦失败")
            }
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
        videoRouter.trigger(.chat(userId: userId))
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
        videoRouter.trigger(.gift(dependency: dependency, delegate: self))
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { followUser in
            guard isFollow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                ChatroomSendMessage(message) { result in
                    switch result {
                    case .success:
                        self?.messageView.addMessage(message)
                    case .failure(let error):
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    }
                }
            }
        }
        NotificationNameDidFollowUser.post()
    }
    
    func didClickedInvite(userId: String) {
        RCLiveVideoEngine.shared().inviteLiveVideo(userId, at: -1) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "已邀请上麦")
            } else {
                SVProgressHUD.showError(withStatus: "邀请上麦失败")
            }
        }
    }
}

extension LiveVideoRoomViewController: RCLiveVideoCancelDelegate {
    func didCancelLiveVideo(_ action: RCLVRCancelMicType) {
        switch action {
        case .request:
            RCLiveVideoEngine.shared().cancelRequest { _ in }
            micButton.micState = .request
        case .invite: ()
        case .connection:
            RCLiveVideoEngine.shared()
                .leaveLiveVideo({ [weak self] _ in
                    self?.liveVideoDidFinish(.leave)
                })
            micButton.micState = .request
        }
    }
}

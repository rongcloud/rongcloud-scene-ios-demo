//
//  LiveVideoRoomViewController+User.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import SVProgressHUD
import RCVoiceRoomMessage

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewWillAppear(_:))
    private func users_viewWillAppear(_ animated: Bool) {
        m_viewWillDisappear(animated)
        fetchManagerList()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func message_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard let content = message.content else { return }
        if content.isKind(of: RCChatroomAdmin.self) {
            fetchManagerList()
        }
    }
    
    func fetchManagerList() {
        let api: RCNetworkAPI = .roomManagers(roomId: room.roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(ManagerListWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managers = wrapper.data ?? []
                SceneRoomManager.shared.managerlist = self.managers.map { $0.userId }
                if wrapper.code == 30001 {
                    self.didCloseRoom()
                }
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension LiveVideoRoomViewController: VoiceRoomUserOperationProtocol {
    /// 踢出房间
    func kickoutRoom(userId: String) {
        RCLiveVideoEngine.shared().kickOutRoom(userId) { [weak self] _ in
            self?.handleKickOutRoom(userId, by: Environment.currentUserId)
            self?.roomInfoView.updateRoomUserNumber()
        }
    }
    
    /// 抱下麦
    func kickUserOffSeat(seatIndex: UInt) {
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
        fetchManagerList()
        let roomId = room.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
            let event = RCChatroomAdmin()
            event.userId = user.userId
            event.userName = user.userName
            event.isAdmin = isManager
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] mId in
                guard let self = self else { return }
                self.messageView.add(event)
            } error: { errorCode, mId in }
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
}

extension LiveVideoRoomViewController: RCLiveVideoCancelDelegate {
    func didCancelLiveVideo(_ action: RCLVRCancelMicType) {
        switch action {
        case .request:
            RCLiveVideoEngine.shared().cancelRequest { _ in }
            toolBarView.micState = .request
        case .invite: ()
        case .connection:
            RCLiveVideoEngine.shared()
                .finishLiveVideo(Environment.currentUserId, completion: { [weak self] _ in
                    self?.layoutLiveVideoView([:])
                    self?.liveVideoDidFinish()
                })
            toolBarView.micState = .request
        }
    }
}

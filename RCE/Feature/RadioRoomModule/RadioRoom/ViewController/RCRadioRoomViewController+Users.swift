//
//  RCRadioRoomViewController+Users.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import SVProgressHUD

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewWillAppear(_:))
    private func users_viewWillAppear(_ animated: Bool) {
        m_viewWillDisappear(animated)
        fetchManagerList()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func users_handleReceivedMessage(_ message: RCMessage) {
        handleReceivedMessage(message)
        if message.content.isKind(of: RCChatroomAdmin.self) {
            return fetchManagerList()
        }
        if message.content.isKind(of: RCChatroomKickOut.self) {
            let content = message.content as! RCChatroomKickOut
            if content.targetId == Environment.currentUserId {
                on(content.userId, kickOut: content.targetId)
            }
        }
    }
    
    func fetchManagerList() {
        let api: RCNetworkAPI = .roomManagers(roomId: roomInfo.roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(ManagerListWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managerlist = wrapper.data ?? []
                SceneRoomManager.shared.managerlist = self.managerlist.map { $0.userId }
                if wrapper.code == 30001 {
                    self.didCloseRoom()
                }
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func on(_ userId: String, kickOut targetId: String) {
        guard targetId == Environment.currentUserId else { return }
        if managerlist.contains(where: { $0.userId == userId }) {
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
                SVProgressHUD.showInfo(withStatus: "您被管理员\(user.userName)踢出房间")
            }
        } else {
            SVProgressHUD.showInfo(withStatus: "您被踢出房间")
        }
        leaveRoom()
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension RCRadioRoomViewController: VoiceRoomUserOperationProtocol {
    /// 踢出房间
    func kickoutRoom(userId: String) {
        let roomId = roomInfo.roomId
        let ids = [Environment.currentUserId, userId]
        UserInfoDownloaded.shared.fetch(ids) { users in
            let event = RCChatroomKickOut()
            event.userId = users[0].userId
            event.userName = users[0].userName
            event.targetId = users[1].userId
            event.targetName = users[1].userName
            RCChatroomMessageCenter.sendChatMessage(roomId, content: event) { [weak self] _ in
                self?.messageView.add(event)
            } error: { _, _ in }
        }
    }
    
    func didSetManager(userId: String, isManager: Bool) {
        fetchManagerList()
        let roomId = roomInfo.roomId
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
        let dependency = VoiceRoomGiftDependency(room: roomInfo,
                                                 seats: [],
                                                 userIds: [userId])
        navigator(.gift(dependency: dependency, delegate: self))
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        let roomId = roomInfo.roomId
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

//
//  LiveVideoRoomViewController+Engine.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/24.
//

import SVProgressHUD
import CoreGraphics
import UIKit
import RCLiveVideoLib

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func gift_viewDidLoad() {
        m_viewDidLoad()
        RCLiveVideoEngine.shared().delegate = self
    }
}

extension LiveVideoRoomViewController: RCLiveVideoDelegate {
    
    func roomInfoDidSync() {
        roomInfoView.updateRoom(info: room)
    }
    
    func roomDidClosed() {
        let isFloating = RCRoomFloatingManager.shared.showing
        if isFloating { RCRoomFloatingManager.shared.hide() }
        
        let message = "当前直播已结束"
        let controller = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default) { _ in
            RCLiveVideoEngine.shared().leaveRoom { [weak self] _ in
                guard let self = self, isFloating == false else { return }
                self.navigationController?.popViewController(animated: true)
            }
        }
        controller.addAction(sureAction)
        UIApplication.shared.keyWindow()?
            .rootViewController?
            .present(controller, animated: true)
    }
    
    func liveVideoDidUpdate(_ userIds: [String]) {
        if userIds.contains(Environment.currentUserId) {
            toolBarView.micState = .connecting
        }
    }
    
    func liveVideoRequestDidAccept() {
        toolBarView.micState = .connecting
    }
    
    func liveVideoRequestDidReject() {
        SVProgressHUD.showInfo(withStatus: "房主拒绝了您的上麦申请")
        toolBarView.micState = .request
    }

    func liveVideoInvitationDidReceive() {
        let controller = RCLVRInvitationAlertViewController()
        view.addSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
    }
    
    func liveVideoInvitationDidCancel() {
        let controller = children.first { $0.isKind(of: RCLVRInvitationAlertViewController.self) }
        guard let alertController = controller as? RCLVRInvitationAlertViewController else { return }
        alertController.invitationDidCancel()
        SVProgressHUD.showInfo(withStatus: "已取消邀请")
    }

    func userDidEnter(_ userId: String) {
        handleUserEnter(userId)
        roomInfoView.updateRoomUserNumber()
    }
    
    func userDidExit(_ userId: String) {
        handleUserExit(userId)
        roomInfoView.updateRoomUserNumber()
    }
    
    func liveVideoDidBegin(_ code: RCLiveVideoErrorCode) {
        switch code {
        case .success:
            SVProgressHUD.showSuccess(withStatus: "连麦成功")
            role = .broadcaster
            toolBarView.micState = .connecting
            setupCapture()
        default:
            SVProgressHUD.showSuccess(withStatus: "连麦失败")
            role = .audience
            toolBarView.micState = .request
        }
        
    }
    
    func liveVideoDidFinish() {
        SVProgressHUD.showSuccess(withStatus: "连麦结束")
        role = .audience
        toolBarView.micState = .request
    }

    func userDidKickOut(_ userId: String, byOperator operatorId: String) {
        handleKickOutRoom(userId, by: operatorId)
        guard userId == Environment.currentUserId else { return }
        if managers.contains(where: { operatorId == $0.userId }) {
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
                SVProgressHUD.showInfo(withStatus: "您被管理员\(user.userName)踢出房间")
            }
        } else {
            SVProgressHUD.showError(withStatus: "您被踢出房间")
        }
        leaveRoom()
    }
    
    func roomInfoDidUpdate(_ key: String, value: String) {
        switch key {
        case "name":
            room.roomName = value
            roomInfoView.updateRoom(info: room)
        case "notice":
            room.notice = value
            messageView.add(RCTextMessage(content: "房间公告已更新")!)
        case "gift":
            roomGiftView.update(value)
        default: ()
        }
    }
    
    func messageDidReceive(_ message: RCMessage) {
        handleReceivedMessage(message)
    }
    
    func network(_ delay: Int) {
        roomInfoView.updateNetworking(rtt: delay)
    }
    
    func liveVideoUserDidClick(_ userId: String) {
        if userId == Environment.currentUserId {
            let controller = RCLVRCancelMicViewController(.connection, delegate: self)
            present(controller, animated: true)
        } else {
            let dependency = VoiceRoomUserOperationDependency(room: room,
                                                              presentUserId: userId)
            navigator(.manageUser(dependency: dependency, delegate: self))
        }
    }
    
    func liveVideoUserDidLayout(_ frameInfo: [String : NSValue]) {
        layoutLiveVideoView(frameInfo)
    }
}

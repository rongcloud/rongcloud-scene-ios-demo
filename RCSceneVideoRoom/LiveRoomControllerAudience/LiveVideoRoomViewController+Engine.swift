//
//  LiveVideoRoomViewController+Engine.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/24.
//

import CoreGraphics
import RCSceneMusic


extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func gift_viewDidLoad() {
        m_viewDidLoad()
        RCLiveVideoEngine.shared().delegate = self
        RCLiveVideoEngine.shared().mixDelegate = self
        RCLiveVideoEngine.shared().mixDataSource = self
    }
}

extension LiveVideoRoomViewController: RCLiveVideoDelegate {
    
    func roomInfoDidSync() {
        roomUserView.setRoom(room)
        SceneRoomManager.updateLiveSeatList()
    }
    
    func roomDidClosed() {
        let message = "当前直播已结束"
        let controller = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default) { [unowned self] _ in
            guard let fm = self.floatingManager, fm.showing else {
                navigationController?.popViewController(animated: true)
                DataSourceImpl.instance.clear()
                PlayerImpl.instance.clear()
                return
            }
            fm.hide()
        }
        controller.addAction(sureAction)
        UIApplication.shared.keyWindow()?
            .rootViewController?
            .present(controller, animated: true)
    }
    
    func liveVideoUserDidUpdate(_ userIds: [String]) {
        if userIds.contains(Environment.currentUserId) {
            role = .broadcaster
        } else {
            role = .audience
        }
        SceneRoomManager.updateLiveSeatList()
    }
    
    func liveVideoRequestDidChange() {
        /// 当前为连麦状态时，不会触发上麦申请
        /// 如果支持管理员处理上麦申请，在此添加逻辑
        if micButton.micState == .connecting {
            return
        }
        RCLiveVideoEngine.shared().getRequests { code, userIds in
            let request = userIds.contains(Environment.currentUserId)
            self.micButton.micState = request ? .waiting : .request
        }
    }
    
    func liveVideoRequestDidAccept() {
        micButton.micState = .connecting
    }
    
    func liveVideoRequestDidReject() {
        SVProgressHUD.showInfo(withStatus: "房主拒绝了您的上麦申请")
        micButton.micState = .request
    }

    func liveVideoInvitationDidReceive(_ inviter: String, at index: Int) {
        let controller = RCLVRInvitationAlertViewController(inviter, index:index)
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
    
    func liveVideoInvitationDidReject(_ invitee: String) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: invitee) { user in
            SVProgressHUD.showInfo(withStatus: "\(user.userName)拒绝上麦")
        }
    }

    func userDidEnter(_ userId: String, withUserCount count: Int) {
        handleUserEnter(userId)
        roomCountingView.update(count)
    }
    
    func userDidExit(_ userId: String, withUserCount count: Int) {
        roomCountingView.update(count)
    }
    
    func liveVideoDidBegin(_ code: RCLiveVideoCode) {
        switch code {
        case .success:
            SVProgressHUD.showSuccess(withStatus: "连麦成功")
            role = .broadcaster
            setupCapture()
        default:
            SVProgressHUD.showSuccess(withStatus: "连麦失败")
            role = .audience
        }
        SceneRoomManager.updateLiveSeatList()
        roomUserView.updateNetworkDelay(false)
    }
    
    func liveVideoDidFinish(_ reason: RCLiveVideoFinishReason) {
        switch reason {
        case .leave:
            SVProgressHUD.showSuccess(withStatus: "连麦结束")
        case .kick:
            SVProgressHUD.showSuccess(withStatus: "您被抱下麦")
        case .mix:
            SVProgressHUD.showSuccess(withStatus: "麦位切换模式，请重新上麦")
        default:
            SVProgressHUD.showSuccess(withStatus: "连麦结束")
        }
        role = .audience
        roomUserView.updateNetworkDelay(true)
    }

    func userDidKickOut(_ userId: String, byOperator operatorId: String) {
        if (role == .broadcaster) {
            RCLiveVideoEngine.shared().leaveLiveVideo { _ in}
        }
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
            roomUserView.setRoom(room)
        case "notice":
            room.notice = value
        case "shields":
            SceneRoomManager.shared.forbiddenWordlist = value.decode([])
        case "FreeEnterSeat":
            isSeatFreeEnter = value == "1"
        default: ()
        }
    }
    
    func messageDidReceive(_ message: RCMessage) {
        handleReceivedMessage(message)
    }
    
    func network(_ delay: Int) {
        roomUserView.updateNetworking(rtt: delay)
    }
    
    func roomMixTypeDidChange(_ mixType: RCLiveVideoMixType) {
        layoutLiveVideoView(mixType)
        if mixType == .gridTwo || mixType == .gridThree {
            RCLiveVideoEngine.shared().currentSeats.forEach {
                $0.enableTiny = false
            }
        }
        seatView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func seatDidLock(_ isLock: Bool, at index: Int) {
        debugPrint("seat did lock \(index)")
    }
}

extension LiveVideoRoomViewController: RCLiveVideoMixDataSource {
    func liveVideoPreviewSize() -> CGSize {
        return CGSize(width: 720, height: 720)
    }
    
    func liveVideoFrames() -> [NSValue] {
        return [
            NSValue(cgRect: CGRect(x: 0.2500, y: 0.0000, width: 0.5000, height: 0.5000)),
            NSValue(cgRect: CGRect(x: 0.0000, y: 0.5000, width: 0.5000, height: 0.5000)),
            NSValue(cgRect: CGRect(x: 0.5000, y: 0.5000, width: 0.5000, height: 0.5000)),
        ]
    }
}

extension LiveVideoRoomViewController: RCLiveVideoMixDelegate {
    func liveVideoDidLayout(_ seat: RCLiveVideoSeat, withFrame frame: CGRect) {
        if RCLiveVideoEngine.shared().pkInfo != nil { return }
        let tag = seat.index + 10000
        seatView.viewWithTag(tag)?.removeFromSuperview()
        if RCLiveVideoEngine.shared().currentMixType == .oneToOne {
            if seat.userId.count == 0 { return }
        }
        let view = RCLiveVideoSeatItemView(room, seatInfo: seat)
        seatView.addSubview(view)
        view.frame = frame
        view.tag = tag
    }
}

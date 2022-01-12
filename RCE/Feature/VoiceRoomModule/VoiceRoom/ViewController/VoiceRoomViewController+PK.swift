//
//  VoiceRoomViewController+PK.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/9.
//

import Foundation
import SVProgressHUD
import UIKit
import RCVoiceRoomLib

enum ClosePKReason {
    case remote
    case myown
    case beginFailed
    case timeEnd
}

enum PKAction {
    case invite
    case reject
    case agree
    case ignore
}

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupChatModule() {
        setupModules()
        pkView.delegate = self
        toolBarView.add(pk: self, action: #selector(handlePkButtonClick))
        roomState.pkConnectStateChanged = {
            [weak self] state in
            var image: UIImage?
            switch state {
            case .request:
                image = R.image.voiceroom_pk_button()
                self?.transitionViewState(isPK: false)
            case .connecting:
                image = R.image.pk_ongoing_icon()
                self?.transitionViewState(isPK: true)
            case .waiting:
                image = state.image
            }
            self?.toolBarView.pkButton.setImage(image, for: .normal)
        }
        roomState.mutePKStateChanged = {
            [weak self] isMute in
            self?.pkView.setupMuteState(isMute: isMute)
        }
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func chat_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        /// 同步最新礼物信息
        log.info("receive message in pk context")
        if let pkGiftMessage = message.content as? RCPKGiftMessage, let content = pkGiftMessage.content {
            pkView.updateGiftValue(content: content, currentRoomId: voiceRoomInfo.roomId)
        }
        /// 同步PK状态
        if let pkStatusContent = message.content as? RCPKStatusMessage, let content = pkStatusContent.content {
            guard let info = self.roomState.currentPKInfo else {
                return
            }
            if content.statusMsg == 0 {
                log.info("receive pk begin message", context: nil)
                self.roomState.pkConnectState = .connecting
                self.pkView.beginPK(info: info, timeDiff: content.timeDiff/1000, currentRoomOwnerId: self.voiceRoomInfo.userId, currentRoomId: self.voiceRoomInfo.roomId)
            }
            if content.statusMsg == 1 {
                log.info("receive pk punnishment message")
                self.pkView.beginPunishment(passedSeconds: content.timeDiff/1000)
            }
            if content.statusMsg == 2 {
                log.info("receive pk finished message")
                let reason: ClosePKReason = {
                    if let roomID = content.stopPkRoomId, !roomID.isEmpty {
                        if roomID == voiceRoomInfo.roomId {
                            return .myown
                        } else {
                            return .remote
                        }
                    } else {
                        return .timeEnd
                    }
                }()
                log.info("close pk reason \(reason)")
                self.showCloseReasonHud(reason: reason)
                // 如果是pk自然结束，由邀请者挂断pk
                if reason == .timeEnd, self.roomState.currentPKInfo?.currentUserRole() == .inviter {
                    log.info("invoke close pk method")
                    RCVoiceRoomEngine.sharedInstance().quitPK {
                        
                    } error: { _, _ in
                        
                    }
                }
                self.roomState.pkConnectState = .request
            }
        }
    }
    
    @objc private func handlePkButtonClick() {
        switch roomState.pkConnectState {
        case .connecting:
            showClosePKAlert()
        case .request:
            navigator(.onlineRooms(selectingUserId: roomState.lastInviteUserId, delegate: self))
        case .waiting:
            guard let userId = roomState.lastInviteUserId, let roomId = roomState.lastInviteRoomId else {
                return
            }
            showCancelPKAlert(roomId: roomId, userId: userId)
        }
    }
    
    private func showPKInvite(roomId: String, userId: String) {
        let vc = UIAlertController(title: "是否接受PK邀请(10)", message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "同意", style: .default, handler: { _ in
            RCVoiceRoomEngine.sharedInstance().responsePKInvitation(roomId, inviter: userId, responseType: .agree) {
                
            } error: { errorCode, msg in
                
            }
        }))
        vc.addAction(UIAlertAction(title: "拒绝", style: .cancel, handler: { _ in
            SVProgressHUD.showSuccess(withStatus: "已拒绝 PK 邀请")
            RCVoiceRoomEngine.sharedInstance().responsePKInvitation(roomId, inviter: userId, responseType: .reject) {
                
            } error: { errorCode, msg in
                
            }
            
        }))
        
        UIApplication.shared.topMostViewController()?.safe_presentViewController(vc: vc, animated: true, completion: {
            self.inviterCount = 10
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                [weak self] currentTimer in
                self?.inviteTimerDidCountdown(inviterRoomId: roomId, inviterId: userId)
            })
            RunLoop.main.add(self.timer!, forMode: .common)
        })
    }
    
    @objc func inviteTimerDidCountdown(inviterRoomId: String, inviterId: String) {
        inviterCount -= 1
        guard let alertController = UIApplication.shared.topMostViewController() as? UIAlertController else {
            timer?.invalidate()
            return
        }
        guard inviterCount > 0 else {
            log.info("response pk invite to ignore")
            RCVoiceRoomEngine.sharedInstance().responsePKInvitation(inviterRoomId, inviter: inviterId, responseType: .ignore) {
                DispatchQueue.main.async {
                    alertController.dismiss(animated: true, completion: nil)
                }
            } error: { _, _ in
                
            }
            timer?.invalidate()
            return
        }
        alertController.title = "是否接受PK邀请(\(inviterCount))"
    }
    
    private func showClosePKAlert() {
        let vc = UIAlertController(title: "挂断并结束本轮 PK 么？", message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "同意", style: .default, handler: { _ in
            self.quitPKConnectAndNotifyServer()
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        present(vc, animated: true, completion: nil)
    }
    
    private func showCancelPKAlert(roomId: String, userId: String) {
        let actions = [
            ActionDependency(action: {
                self.cancelPK(userId: userId, roomId: roomId)
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }, name: "撤回邀请"),
            ActionDependency(action: {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }, name: "取消")]
        let vc = OptionsViewController(dependency: PresentOptionDependency(title: "已发起PK邀请", actions: actions))
        safe_presentViewController(vc: vc, animated: true, completion: nil)
    }
    
    private func sendTextMessage(text: String) {
        let textMessage = RCTextMessage()
        textMessage.content = text
        RCVoiceRoomEngine.sharedInstance().sendMessage(textMessage) {
            [weak self] in
            self?.messageView.add(textMessage)
        } error: { code, text in
            
        }
    }
    /// RTC 已建立连接，向服务端请求PK开始
    private func sendPKRequest() {
        log.info("向服务器发送 pk 开始的请求")
        guard let info = roomState.currentPKInfo else {
            return
        }
        if let vc = presentedViewController as? OptionsViewController {
            vc.dismiss(animated: true, completion: nil)
        }
        let role = info.currentUserRole()
        switch role {
        case .inviter:
            forceLockOthers(isLock: true)
            sendAttendPKMessage(userId: info.inviteeId)
            SceneRoomManager.shared.setPKStatus(roomId: info.inviterRoomId, toRoomId: info.inviteeRoomId, status: .begin) { isSuccess in
                if !isSuccess {
                    self.quitPKConnectAndNotifyServer()
                }
            }
        case .invitee:
            forceLockOthers(isLock: true)
            sendAttendPKMessage(userId: info.inviterId)
        case .audience:
            ()
        }
    }
    
    private func forceLockOthers(isLock: Bool) {
        guard let seatCount = kvRoomInfo?.seatCount, seatCount >= 2 else {
            return
        }
        RCVoiceRoomEngine.sharedInstance().lockOtherSeats(isLock)
    }
    
    func getPKStatus() {
        /// 获取服务器PK最新信息
        log.info("获取服务器PK最新信息")
        SceneRoomManager.shared.getCurrentPKInfo(roomId: self.voiceRoomInfo.roomId) { [weak self] pkStatus in
            guard let statusModel = pkStatus, let self = self, statusModel.roomScores.count == 2 else {
                return
            }
            let pkInfo: VoiceRoomPKInfo = {
                let roomscore1 = statusModel.roomScores[0]
                let roomscore2 = statusModel.roomScores[1]
                if roomscore1.leader {
                    return VoiceRoomPKInfo(inviterId: roomscore1.userId, inviteeId: roomscore2.userId, inviterRoomId: roomscore1.roomId, inviteeRoomId: roomscore2.roomId)
                }
                return VoiceRoomPKInfo(inviterId: roomscore2.userId, inviteeId: roomscore1.userId, inviterRoomId: roomscore2.roomId, inviteeRoomId: roomscore1.roomId)
            }()
            self.roomState.currentPKInfo = pkInfo
            switch statusModel.statusMsg {
            case 0:
                self.roomState.pkConnectState = .connecting
                self.pkView.beginPK(info: pkInfo, timeDiff: statusModel.seconds, currentRoomOwnerId: self.voiceRoomInfo.userId, currentRoomId: self.voiceRoomInfo.roomId)
                if pkInfo.currentUserRole() != .audience {
                    self.resumePK()
                }
                self.pkView.updateGiftValue(content: PKGiftModel(roomScores: statusModel.roomScores), currentRoomId: self.voiceRoomInfo.roomId)
            case 1:
                self.roomState.pkConnectState = .connecting
                self.pkView.beginPunishment(passedSeconds: statusModel.seconds, info: pkInfo, currentRoomId: self.voiceRoomInfo.roomId)
                if pkInfo.currentUserRole() != .audience {
                    self.resumePK()
                }
                self.pkView.updateGiftValue(content: PKGiftModel(roomScores: statusModel.roomScores), currentRoomId: self.voiceRoomInfo.roomId)
            default:
                self.roomState.pkConnectState = .request
            }
        }
    }
    
    private func resumePK() {
        guard let pkInfo = roomState.currentPKInfo, pkInfo.currentUserRole() != .audience else {
            return
        }
        log.info("恢复 pk 连接")
        RCVoiceRoomEngine.sharedInstance().resumePK(with: RCVoicePKInfo(inviterId: pkInfo.inviterId, inviterRoomId: pkInfo.inviterRoomId, inviteeId: pkInfo.inviteeId, inviteeRoomId: pkInfo.inviteeRoomId)) {
            SVProgressHUD.showSuccess(withStatus: "恢复PK成功")
        } error: { _, _ in
            SVProgressHUD.showError(withStatus: "恢复PK 失败")
        }
    }
    
    private func sendAttendPKMessage(userId: String) {
        UserInfoDownloaded.shared.fetch([userId]) { list in
            guard let user = list.first else {
                return
            }
            self.sendTextMessage(text: "与 \(user.userName) 的 PK 即将开始")
            log.debug("pk即将开始 by \(user.userId)")
        }
    }
    
    private func quitPKConnectAndNotifyServer() {
        log.info("退出 pk 并通知 server")
        guard let info = roomState.currentPKInfo else {
            return
        }
        RCVoiceRoomEngine.sharedInstance().quitPK {
            SVProgressHUD.showSuccess(withStatus: "退出PK成功")
        } error: { _, _ in
            SVProgressHUD.showError(withStatus: "退出PK失败")
        }
        let roomId = voiceRoomInfo.roomId == info.inviterRoomId ? info.inviterRoomId : info.inviteeRoomId
        let toRoomId = voiceRoomInfo.roomId == info.inviterRoomId ? info.inviteeRoomId : info.inviterRoomId
        SceneRoomManager.shared.setPKStatus(roomId:roomId, toRoomId: toRoomId, status: .close)
    }
    
    private func showCloseReasonHud(reason: ClosePKReason) {
        switch reason {
        case .remote:
            SVProgressHUD.showSuccess(withStatus: "对方挂断，本轮PK结束")
        case .timeEnd:
            SVProgressHUD.showSuccess(withStatus: "本轮PK结束")
        case .myown:
            SVProgressHUD.showSuccess(withStatus: "我方挂断，本轮PK结束")
        case .beginFailed:
            SVProgressHUD.showError(withStatus: "开始PK失败，请重试")
        }
    }
    
    private func cancelPK(userId: String, roomId: String) {
        guard roomState.pkConnectState == .waiting else {
            return
        }
        RCVoiceRoomEngine.sharedInstance().cancelPKInvitation(roomId, invitee: userId) {
            self.roomState.pkConnectState = .request
            SVProgressHUD.showSuccess(withStatus: "已取消邀请")
        } error: { _, _ in
            SVProgressHUD.showError(withStatus: "撤回PK邀请失败，请重试")
        }
    }
    
    private func transitionViewState(isPK: Bool) {
        pkView.reset()
        if isPK {
            messageView.snp.remakeConstraints { make in
                make.bottom.equalTo(toolBarView.snp.top).offset(-8.resize)
                make.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(278.0 / 375)
                make.top.equalTo(pkView.snp.bottom).offset(20)
            }
            UIView.animate(withDuration: 0.3) {
                self.ownerView.alpha = 0
                self.collectionView.alpha = 0
                self.pkView.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else {
            messageView.snp.remakeConstraints {
                $0.left.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(278.0 / 375)
                $0.bottom.equalTo(toolBarView.snp.top).offset(-8.resize)
                $0.top.equalTo(collectionView.snp.bottom).offset(21.resize)
            }
            UIView.animate(withDuration: 0.3) {
                self.ownerView.alpha = 1
                self.collectionView.alpha = 1
                self.pkView.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension VoiceRoomViewController {
    func pkInvitationDidReceive(fromRoom inviterRoomId: String, byUser inviterUserId: String) {
        showPKInvite(roomId: inviterRoomId, userId: inviterUserId)
    }
    
    func pkOngoing(withInviterRoom inviterRoomId: String, withInviterUserId inviterUserId: String, withInviteeRoom inviteeRoomId: String, withInviteeUserId inviteeUserId: String) {
        roomState.currentPKInfo = VoiceRoomPKInfo(inviterId: inviterUserId, inviteeId: inviteeUserId, inviterRoomId: inviterRoomId, inviteeRoomId: inviteeRoomId)
        sendPKRequest()
    }
    
    func cancelPKInvitationDidReceive(fromRoom inviterRoomId: String, byUser inviterUserId: String) {
        if let presentVC = presentedViewController, presentVC.isKind(of: UIAlertController.self) {
            presentVC.dismiss(animated: true, completion: nil)
        }
        SVProgressHUD.showError(withStatus: "邀请已被取消")
    }
    
    func rejectPKInvitationDidReceive(fromRoom inviteeRoomId: String, byUser initeeUserId: String) {
        SVProgressHUD.showError(withStatus: "对方拒绝了您的PK邀请")
        self.roomState.pkConnectState = .request
    }
    
    func ignorePKInvitationDidReceive(fromRoom inviteeRoomId: String, byUser inviteeUserId: String) {
        SVProgressHUD.showError(withStatus: "对方无回应，PK发起失败")
        self.roomState.pkConnectState = .request
    }
    
    func pkDidFinish() {
        if self.currentUserRole() == .creator {
            forceLockOthers(isLock: false)
        }
    }
}

extension VoiceRoomViewController: OnlineRoomCreatorDelegate {
    func selectedUserDidClick(userId: String, from roomId: String) {
        showCancelPKAlert(roomId: roomId, userId: userId)
    }
    
    func userDidInvite(userId: String, from roomId: String) {
        networkProvider.request(RCNetworkAPI.isPK(roomId: roomId)) { result in
            switch result {
            case .success(let response):
                guard let status = try? JSONDecoder().decode(RoomPKStatus.self, from: response.data), !status.data else {
                    SVProgressHUD.showError(withStatus: "对方正在PK中")
                    return
                }
                RCVoiceRoomEngine.sharedInstance().sendPKInvitation(roomId, invitee: userId) {
                    self.roomState.pkConnectState = .waiting
                    self.roomState.lastInviteRoomId = roomId
                    self.roomState.lastInviteUserId = userId
                } error: { _, _ in
                    SVProgressHUD.showError(withStatus: "邀请PK失败")
                }

            case .failure(_):
                SVProgressHUD.showError(withStatus: "对方正在PK中")
            }
        }
        
    }
}

extension VoiceRoomViewController: VoiceRoomPKViewDelegate {
    func silenceButtonDidClick() {
        let isMute = !roomState.isMutePKUser
        let message = isMute ? "静音" : "取消静音"
        RCVoiceRoomEngine.sharedInstance().mutePKUser(isMute) {
            [weak self] in
            self?.roomState.isMutePKUser.toggle()
            SVProgressHUD.showSuccess(withStatus: "\(message) PK 成功")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "\(message) PK 失败，请重试")
        }
    }
}

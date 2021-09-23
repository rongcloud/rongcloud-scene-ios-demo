//
//  VoiceRoomViewController+PK.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/9.
//

import Foundation
import SVProgressHUD
import UIKit

enum ClosePKReason {
    case remote
    case myown
    case beginFailed
    case timeEnd
}

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupChatModule() {
        setupModules()
        pkView.delegate = self
        toolBarView.add(pk: self, action: #selector(handlePkButtonClick))
        roomState.pkConnectStateChanged = {
            [weak self] state in
            let image: UIImage? = {
                switch state {
                case .request:
                    return R.image.voiceroom_pk_button()
                case .connecting:
                    return R.image.pk_ongoing_icon()
                case .waiting:
                    return state.image
                }
            }()
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
        debugPrint("receive message \(String(describing: message.content))")
        if let pkGiftMessage = message.content as? RCPKGiftMessage, let content = pkGiftMessage.content {
            pkView.updateGiftValue(content: content, currentRoomId: voiceRoomInfo.roomId)
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
            guard self.roomState.isPKOngoing() == false else {
                RCVoiceRoomEngine.sharedInstance().responsePKInvitation(roomId, inviter: userId, responseType: .reject) {
                    self.roomState.pkConnectState = .connecting
                } error: { code, msg in
                    
                }
                SVProgressHUD.showError(withStatus: "请先退出当前 PK 后再接受邀请")
                return
            }
            //SVProgressHUD.showSuccess(withStatus: "已邀请PK，等待对方接受")
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
            self.closePK(reason: .myown)
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
    
    private func beginPK() {
        guard let info = roomState.currentPKInfo else {
            return
        }
        if let vc = presentedViewController as? OptionsViewController {
            vc.dismiss(animated: true, completion: nil)
        }
        roomState.pkConnectState = .connecting
        let role = info.currentUserRole()
        switch role {
        case .inviter:
            RCVoiceRoomEngine.sharedInstance().lockOtherSeats(true)
            sendAttendPKMessage(userId: info.inviteeId)
            VoiceRoomManager.shared.setPKStatus(roomId: info.inviterRoomId, toRoomId: info.inviteeRoomId, status: .begin) { isSuccess in
                if !isSuccess {
                    SVProgressHUD.showError(withStatus: "开始PK失败，请重试")
                    self.closePK(reason: .beginFailed)
                }
            }
        case .invitee:
            RCVoiceRoomEngine.sharedInstance().lockOtherSeats(true)
            sendAttendPKMessage(userId: info.inviterId)
        case .audience:
            ()
        }
        transitionViewState(isPK: true)
        self.pkView.pkViewBegin(info: info, currentRoomOwnerId: self.voiceRoomInfo.userId, currentRoomId: self.voiceRoomInfo.roomId) {
            [weak self] state, result in
            guard let self = self else { return }
            switch state {
            case .punishOngoing where (role == .inviter || role == .invitee):
                VoiceRoomManager.shared.setPKStatus(roomId: info.inviterRoomId, toRoomId: info.inviteeRoomId, status: .pause)
                self.sendTextMessage(text: result.desc)
            case .end:
                self.closePK(reason: .timeEnd)
            default:
                ()
            }
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
    
    private func closePK(reason: ClosePKReason) {
        guard let info = roomState.currentPKInfo else {
            return
        }
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
        if info.currentUserRole() == .invitee || info.currentUserRole() == .inviter {
            RCVoiceRoomEngine.sharedInstance().quitPK {
                
            } error: { errorCode, msg in
                SVProgressHUD.showError(withStatus: "挂断失败，请重新尝试")
            }
            VoiceRoomManager.shared.setPKStatus(roomId: info.inviterRoomId, toRoomId: info.inviteeRoomId, status: .close)
        }
        self.roomState.pkConnectState = .request
        self.transitionViewState(isPK: false)
    }
    
    private func cancelPK(userId: String, roomId: String) {
        guard roomState.pkConnectState == .waiting else {
            return
        }
        self.roomState.pkConnectState = .request
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
                make.left.right.equalToSuperview()
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
                $0.left.right.equalToSuperview()
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
        beginPK()
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
        guard pkView.pkState != .end else {
            return
        }
        closePK(reason: .remote)
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

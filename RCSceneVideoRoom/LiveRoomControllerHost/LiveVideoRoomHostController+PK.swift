//
//  LiveVideoRoomHostController+PK.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/28.
//

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

extension RCLiveVideoEngine {
    var canPK: Bool {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .default, .oneToOne: return currentSeats[1].userId.count == 0
        default: return false
        }
    }
}

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func PK_viewDidLoad() {
        m_viewDidLoad()
        RCLiveVideoEngine.shared().pkDelegate = self
        pkButton.pkState = .request
        pkButton.addTarget(self, action: #selector(handlePKButtonDidClick), for: .touchUpInside)
    }
    
    @objc func handlePKButtonDidClick() {
        switch pkButton.pkState {
        case .request:
            guard RCLiveVideoEngine.shared().canPK else {
                return SVProgressHUD.showError(withStatus: "连麦时不能发起 PK")
            }
            let controller = LiveVideoOthersViewController()
            controller.delegate = self
            controller.modalPresentationStyle = .overFullScreen
            present(controller, animated: true)
        case let .waiting(roomId, userId):
            showCancelPKAlert(roomId: roomId, userId: userId)
        case .connecting:
            showClosePKAlert()
        }
    }
    
    private func showPKInvite(roomId: String, userId: String) {
        let vc = UIAlertController(title: nil, message: "是否接受PK邀请(10)", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "同意", style: .default, handler: { _ in
            RCLiveVideoEngine.shared()
                .acceptPKInvitation(roomId, inviter: userId) { code in
                    if code == .success {
                        self.pkButton.pkState = .connecting(otherRoomId: roomId,
                                                            otherRoomUserId: userId)
                        self.didBeginPK(code)
                    } else {
                        RCLiveVideoEngine.shared().quitPK { code in }
                    }
                }
        })
        let rejectAction = UIAlertAction(title: "拒绝", style: .cancel, handler: { _ in
            SVProgressHUD.showSuccess(withStatus: "已拒绝 PK 邀请")
            RCLiveVideoEngine.shared()
                .rejectPKInvitation(roomId, inviter: userId, reason: "reject") { _ in }
        })
        vc.addAction(sureAction)
        vc.addAction(rejectAction)
        UIApplication.shared.topMostViewController()?.present(vc, animated: true)
        
        weak var controller = vc
        func countdown(_ value: Int) {
            guard let controller = controller else { return }
            if value <= 0 {
                RCLiveVideoEngine.shared()
                    .rejectPKInvitation(roomId, inviter: userId, reason: "ignore") { code in }
                return controller.dismiss(animated: true)
            }
            controller.message = "是否接受PK邀请(\(value))"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { countdown(value - 1) }
        }
        countdown(10)
    }
    
    private func showCancelPKAlert(roomId: String, userId: String) {
        let actions = [
            ActionDependency(action: {
                self.cancelPK(roomId: roomId, userId: userId)
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }, name: "撤回邀请"),
            ActionDependency(action: {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }, name: "取消")]
        let vc = OptionsViewController(dependency: PresentOptionDependency(title: "已发起PK邀请", actions: actions))
        safe_presentViewController(vc: vc, animated: true, completion: nil)
    }
    
    private func cancelPK(roomId: String, userId: String) {
        RCLiveVideoEngine.shared().cancelPKInvitation(roomId, invitee: userId) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "已取消邀请")
                self.pkButton.pkState = .request
            } else {
                SVProgressHUD.showError(withStatus: "撤回PK邀请失败，请重试")
            }
        }
    }
    
    private func showClosePKAlert() {
        let vc = UIAlertController(title: nil, message: "挂断并结束本轮 PK 么？", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.quitPKConnectAndNotifyServer()
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(vc, animated: true, completion: nil)
    }
    
    private func sendTextMessage(text: String) {
        let textMessage = RCTextMessage(content: text)!
        RCLiveVideoEngine.shared().sendMessage(textMessage) { [weak self] code in
            self?.messageView.addMessage(textMessage)
        }
    }
    
    private func sendAttendPKMessage(userId: String) {
        UserInfoDownloaded.shared.fetch([userId]) { list in
            guard let user = list.first else { return }
            self.sendTextMessage(text: "与 \(user.userName) 的 PK 即将开始")
        }
    }
    
    private func syncServerPKInfo(_ pkInfo: RCLiveVideoPK) {
        guard pkInfo.inviterUserId == room.userId else { return }
        videoRoomService.setPKStatus(roomId: pkInfo.inviterRoomId,
                                            toRoomId: pkInfo.inviteeRoomId,
                                            status: .begin) { isSuccess in
            if !isSuccess {
                self.quitPKConnectAndNotifyServer()
            }
        }
    }
    
    private func quitPKConnectAndNotifyServer() {
        guard let PK = RCLiveVideoEngine.shared().pkInfo else { return }
        RCLiveVideoEngine.shared().quitPK { code in
            if code == .success {
                self.hidePKView()
                self.showCloseReasonHud(reason: .myown)
            } else {
                SVProgressHUD.showError(withStatus: "退出PK失败")
            }
        }
        let roomId = room.roomId == PK.inviterRoomId ? PK.inviterRoomId : PK.inviteeRoomId
        let toRoomId = room.roomId == PK.inviterRoomId ? PK.inviteeRoomId : PK.inviterRoomId
        videoRoomService.setPKStatus(roomId:roomId, toRoomId: toRoomId, status: .close)
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
    
    private func PKDidPublish(_ content: PKStatusContent) {
        if content.roomScores.count != 2 { return }
        let roomScore1 = content.roomScores[0]
        let roomScore2 = content.roomScores[1]
        let scores: (Int, Int) = {
            if roomScore1.roomId == room.roomId {
                return (roomScore1.score, roomScore2.score)
            } else {
                return (roomScore2.score, roomScore1.score)
            }
        }()
        pkView.progressView.update(scores.0, right: scores.1)
        if scores.0 > scores.1 {
            sendTextMessage(text: "我方 PK 胜利")
        } else if scores.0 < scores.1 {
            sendTextMessage(text: "我方 PK 失败")
        } else {
            sendTextMessage(text: "平局")
        }
    }
}

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func PK_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        
        /// PK 礼物消息
        if let PKGiftMessage = message.content as? RCPKGiftMessage, let content = PKGiftMessage.content {
            return pkView.updateGiftValue(content: content)
        }
        
        /// 同步 PK 状态
        guard
            let PK = RCLiveVideoEngine.shared().pkInfo,
            let PKStatusMessage = message.content as? RCPKStatusMessage,
            let content = PKStatusMessage.content
        else { return }
        handlePKStatus(content, PK: PK)
    }
    
    private func handlePKStatus(_ statusModel: PKStatusContent, PK: RCLiveVideoPK) {
        switch statusModel.statusMsg {
        case 0:
            pkButton.pkState = .connecting(otherRoomId: PK.otherRoomId(),
                                           otherRoomUserId: PK.otherRoomUserId())
            pkView.begin(statusModel.seconds)
        case 1:
            pkButton.pkState = .connecting(otherRoomId: PK.otherRoomId(),
                                           otherRoomUserId: PK.otherRoomUserId())
            pkView.punish(statusModel.seconds)
            PKDidPublish(statusModel)
        case 2:
            pkButton.pkState = .request
            debugPrint("receive pk finished message")
            let reason: ClosePKReason = {
                guard let roomId = statusModel.stopPkRoomId, !roomId.isEmpty
                else { return .timeEnd }
                return roomId == room.roomId ? .myown : .remote
            }()
            showCloseReasonHud(reason: reason)
            /// 如果是 PK 自然结束，由邀请者挂断pk
            if reason == .timeEnd, PK.inviterUserId == Environment.currentUserId {
                debugPrint("invoke close pk method")
                RCLiveVideoEngine.shared().quitPK { code in
                    self.hidePKView()
                }
            }
        default: ()
        }
    }
}

extension LiveVideoRoomHostController {
    private func showPKView() {
        pkView.removeFromSuperview()
        pkView = LiveVideoRoomPKView()
        view.addSubview(pkView)
        pkView.snp.makeConstraints { make in
            make.edges.equalTo(seatView)
        }
    }
    
    private func hidePKView() {
        pkButton.pkState = .request
        pkView.removeFromSuperview()
    }
}

extension LiveVideoRoomHostController: LiveVideoOthersDelegate {
    func pkInvitationDidSend(userId: String, from roomId: String) {
        pkButton.pkState = .waiting(otherRoomId: roomId, otherRoomUserId: userId)
    }
    
    func pkInvitationDidCancel(userId: String, from roomId: String) {
        pkButton.pkState = .request
    }
}

extension LiveVideoRoomHostController: RCLiveVideoPKDelegate {
    func didReceivePKInvitation(fromRoom inviterRoomId: String, byUser inviterUserId: String) {
        let mixType = RCLiveVideoEngine.shared().currentMixType
        let isBusy: Bool = {
            if micButton.micState == .waiting {
                return true
            }
            guard mixType == .default || mixType == .oneToOne else {
                return true
            }
            return RCLiveVideoEngine.shared().currentSeats[1].userId.count > 0
        }()
        if isBusy {
            RCLiveVideoEngine.shared()
                .rejectPKInvitation(inviterRoomId,
                                    inviter: inviterUserId,
                                    reason: "busy",
                                    completion: { _ in })
        } else {
            showPKInvite(roomId: inviterRoomId, userId: inviterUserId)
        }
    }
    
    func didCancelPKInvitation(fromRoom inviterRoomId: String, byUser inviterUserId: String) {
        if let controller = topMostViewController() as? UIAlertController {
            controller.dismiss(animated: true)
        }
        SVProgressHUD.showInfo(withStatus: "对方取消 PK 邀请")
        RCLiveVideoEngine.shared().quitPK { _ in }
    }
    
    func didAcceptPKInvitation(fromRoom inviteeRoomId: String, byUser inviteeUserId: String) {
        pkButton.pkState = .connecting(otherRoomId: inviteeRoomId,
                                       otherRoomUserId: inviteeUserId)
    }
    
    func didRejectPKInvitation(fromRoom inviteeRoomId: String,
                               byUser inviteeUserId: String,
                               reason: String) {
        pkButton.pkState = .request
        switch reason {
        case "reject": SVProgressHUD.showError(withStatus: "对方拒绝了PK邀请")
        case "ignore": SVProgressHUD.showError(withStatus: "对方无回应，PK发起失败")
        case "busy": SVProgressHUD.showError(withStatus: "对方正忙")
        default: SVProgressHUD.showError(withStatus: "对方拒绝了PK邀请")
        }
    }
    
    func didBeginPK(_ code: RCLiveVideoCode) {
        guard
            code == .success,
            let pkInfo = RCLiveVideoEngine.shared().pkInfo
        else { return SVProgressHUD.showError(withStatus: "PK 开启失败") }
        
        /// 当前按钮状态
        /// 1.收到 PK 邀请后，己方同意，状态为 connecting
        /// 2.发起 PK 邀请后，对方同意，状态为 connecting
        switch pkButton.pkState {
        case .connecting:
            /// 发送 PK 开始消息
            sendAttendPKMessage(userId: pkInfo.otherRoomUserId())
            /// 添加 PK 视图
            showPKView()
            /// 同步服务器信息
            syncServerPKInfo(pkInfo)
        default:
            fetchServerPKInfo(pkInfo)
        }
    }
    
    func didFinishPK(_ code: RCLiveVideoCode) {
        hidePKView()
    }
    
    func fetchServerPKInfo(_ PK: RCLiveVideoPK) {
        /// 获取服务器PK最新信息
        videoRoomService.getCurrentPKInfo(roomId: room.roomId) { [weak self] pkStatus in
            guard let statusModel = pkStatus else {
                return RCLiveVideoEngine.shared().quitPK { code in
                    /// TODO Code
                }
            }
            
            guard
                let self = self,
                statusModel.roomScores.count == 2,
                [0, 1, 2].contains(statusModel.statusMsg)
            else { return }
            
            RCLiveVideoEngine.shared().resumePK(PK) { code in
                /// TODO code
            }
            
            self.showPKView()
            
            switch statusModel.statusMsg {
            case 0:
                self.pkButton.pkState = .connecting(otherRoomId: PK.otherRoomId(),
                                                    otherRoomUserId: PK.otherRoomUserId())
                self.pkView.begin(statusModel.seconds)
                self.pkView.updateGiftValue(content: PKGiftModel(roomScores: statusModel.roomScores))
            case 1:
                self.pkButton.pkState = .connecting(otherRoomId: PK.otherRoomId(),
                                                    otherRoomUserId: PK.otherRoomUserId())
                self.pkView.punish(statusModel.seconds)
                self.pkView.updateGiftValue(content: PKGiftModel(roomScores: statusModel.roomScores))
            default:
                self.pkButton.pkState = .request
            }
        }
    }
}

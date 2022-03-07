//
//  LiveVideoRoomViewController+PK.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/31.
//

import SVProgressHUD

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func PK_viewDidLoad() {
        m_viewDidLoad()
        RCLiveVideoEngine.shared().pkDelegate = self
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
}

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func PK_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        
        /// PK 礼物消息
        if let PKGiftMessage = message.content as? RCPKGiftMessage, let content = PKGiftMessage.content {
            return PKView.updateGiftValue(content: content)
        }
        
        /// 同步PK状态
        guard
            let PKStatusMessage = message.content as? RCPKStatusMessage,
            let content = PKStatusMessage.content
        else { return }
        
        switch content.statusMsg {
        case 0:
            PKView.begin(content.timeDiff/1000)
        case 1:
            PKView.punish(content.timeDiff/1000)
        case 2:
            let reason: ClosePKReason = {
                guard let roomId = content.stopPkRoomId, !roomId.isEmpty
                else { return .timeEnd }
                return roomId == room.roomId ? .myown : .remote
            }()
            showCloseReasonHud(reason: reason)
        default: ()
        }
    }
}

extension LiveVideoRoomViewController: RCLiveVideoPKDelegate {
    func didBeginPK(_ code: RCLiveVideoCode) {
        guard let PK = RCLiveVideoEngine.shared().pkInfo else { return }
        loadPKStatus(PK)
    }
    
    private func loadPKStatus(_ PK: RCLiveVideoPK) {
        /// 获取服务器PK最新信息
        videoRoomService.getCurrentPKInfo(roomId: room.roomId) { [weak self] pkStatus in
            guard
                let self = self,
                let statusModel = pkStatus,
                [0, 1].contains(statusModel.statusMsg),
                statusModel.roomScores.count == 2
            else { return }
            self.showPKView(statusModel)
        }
    }
    
    private func showPKView(_ statusModel: PKStatusModel) {
        PKView.removeFromSuperview()
        PKView = LiveVideoRoomPKView()
        view.addSubview(PKView)
        PKView.snp.makeConstraints { make in
            make.edges.equalTo(seatView)
        }
        seatView.isHidden = true
        
        switch statusModel.statusMsg {
        case 0:
            self.PKView.updateGiftValue(content: PKGiftModel(roomScores: statusModel.roomScores))
            self.PKView.begin(statusModel.seconds)
        case 1:
            self.PKView.updateGiftValue(content: PKGiftModel(roomScores: statusModel.roomScores))
            self.PKView.punish(statusModel.seconds)
        default: ()
        }
    }
    
    func didFinishPK(_ code: RCLiveVideoCode) {
        PKView.removeFromSuperview()
        seatView.isHidden = false
    }
}

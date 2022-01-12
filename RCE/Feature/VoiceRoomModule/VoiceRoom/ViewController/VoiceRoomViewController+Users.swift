//
//  VoiceRoomViewController+Users.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

import SVProgressHUD

extension RCVoiceSeatInfo {
    var isEmpty: Bool {
        return status == .empty && userId == nil
    }
}

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        toolBarView.add(users: self, action: #selector(handleMicOrderClick))
        toolBarView.add(requset: self, action: #selector(handleRequestSeat))
        roomState.connectStateChanged = {
           [weak self] state in
            self?.toolBarView.requestMicroButton.setImage(state.image, for: .normal)
            if state == .connecting {
                RCVoiceRoomEngine.sharedInstance().cancelRequestSeat {} error: { code, msg in }
            }
        }
    }
    
    @objc private func handleMicOrderClick() {
        guard !roomState.isPKOngoing() else {
            SVProgressHUD.showError(withStatus: "当前 PK 中，无法进行该操作")
            return
        }
        let navigation: RCNavigation = .requestOrInvite(roomId: voiceRoomInfo.roomId,
                                                        delegate: self,
                                                        showPage: 0,
                                                        onSeatUserIds: seatlist.compactMap(\.userId))
        navigator(navigation)
    }
    
    @objc private func handleRequestSeat() {
        guard !roomState.isPKOngoing() else {
            SVProgressHUD.showError(withStatus: "当前 PK 中，无法进行该操作")
            return
        }
        switch roomState.connectState {
        case .request:
            requestSeat()
        case .waiting:
            navigator(.requestSeatPop(delegate: self))
        default:
            ()
        }
    }
    
    func hasEmptySeat() -> Bool {
        return seatlist[1..<seatlist.count].contains { $0.isEmpty }
    }
    
    func setupRequestStateAndMicOrderListState() {
        RCVoiceRoomEngine.sharedInstance()
            .getRequestSeatUserIds { [weak self] userlist in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if self.currentUserRole() == .creator  {
                        self.toolBarView.update(users: userlist.count)
                    } else  {
                        if userlist.contains(Environment.currentUserId) {
                            self.roomState.connectState = .waiting
                        }
                        if self.isSitting() {
                            self.roomState.connectState = .connecting
                        }
                    }
                }
            } error: { code, msg in
                SVProgressHUD.showError(withStatus: "获取排麦列表失败")
            }
    }
}

// MARK: - Handle Seat Request Or Invite Delegate
extension VoiceRoomViewController: HandleRequestSeatProtocol {
    func acceptUserRequestSeat(userId: String) {
        guard hasEmptySeat() else {
            SVProgressHUD.showError(withStatus: "麦位已满")
            return
        }
        RCVoiceRoomEngine.sharedInstance().acceptRequestSeat(userId) {
            DispatchQueue.main.async {
                self.setupRequestStateAndMicOrderListState()
            }
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "同意请求失败")
        }
    }
    
    func inviteUserToSeat(userId: String) {
        if isSitting(userId) {
            return SVProgressHUD.showError(withStatus: "用户已经在麦位上了哦")
        }
        guard hasEmptySeat() else {
            SVProgressHUD.showError(withStatus: "麦位已满")
            return
        }
        RCVoiceRoomEngine.sharedInstance().pickUser(toSeat: userId) {
            SVProgressHUD.showSuccess(withStatus: "已邀请上麦")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "邀请连麦发送失败")
        }
    }
}

extension VoiceRoomViewController: RequestSeatPopProtocol {
    func cancelRequestSeatDidClick() {
        RCVoiceRoomEngine.sharedInstance().cancelRequestSeat {
            SVProgressHUD.showSuccess(withStatus: "已撤回连线申请")
            DispatchQueue.main.async {
                self.roomState.connectState = .request
            }
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "撤回连线申请失败")
        }
    }
}

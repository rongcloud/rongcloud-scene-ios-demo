//
//  VoiceRoomViewController+Users.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        toolBarView.add(users: self, action: #selector(handleMicOrderClick))
        toolBarView.add(requset: self, action: #selector(handleRequestSeat))
    }
    
    @objc private func handleMicOrderClick() {
        let navigation: RCNavigation = .requestOrInvite(roomId: voiceRoomInfo.roomId,
                                                        delegate: self,
                                                        showPage: 0,
                                                        onSeatUserIds: seatlist.compactMap(\.userId))
        navigator(navigation)
    }
    
    @objc private func handleRequestSeat() {
        switch roomState.connectState {
        case .request:
            requestSeat()
        case .waiting:
            navigator(.requestSeatPop(delegate: self))
        default:
            ()
        }
    }
    
    private func hasEmptySeat() -> Bool {
        return seatlist[1..<seatlist.count]
            .contains(where: { $0.status == .empty && $0.userId == nil })
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
        guard userSeatIndex(userId: userId) == nil else {
            SVProgressHUD.showError(withStatus: "用户已经在麦位上了哦")
            return
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
    func cancelReqeustSeatDidClick() {
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

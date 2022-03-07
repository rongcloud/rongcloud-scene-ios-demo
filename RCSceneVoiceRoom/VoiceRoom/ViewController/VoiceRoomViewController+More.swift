//
//  VoiceRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/22.
//

import UIKit
import SVProgressHUD

import RCSceneModular

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        moreButton.setImage(R.image.more_icon(), for: .normal)
        moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
    }
    
    //MARK: - Button Click Action
    @objc private func handleMoreButton() {
        navigator(.leaveAlert(isOwner: currentUserRole() == .creator, delegate: self))
    }
}

// MARK: - Leave View Click Delegate
extension VoiceRoomViewController: RCSceneLeaveViewProtocol {
    func quitRoomDidClick() {
        let currentRole = roomState.currentPKInfo?.currentUserRole() ?? .audience
        guard !roomState.isPKOngoing() || currentRole == .audience else {
            SVProgressHUD.showError(withStatus: "正在PK中， 无法进行该操作")
            return
        }
        leaveRoom()
    }
    
    func closeRoomDidClick() {
        var title = "确定结束本次直播么？"
        if roomState.isPKOngoing() {
            title = "正在进行 PK，" + title
        }

        let navigation: RCNavigation = .voiceRoomAlert(title: title,
                                                       actions: [.cancel("取消"), .confirm("确认")],
                                                       alertType: alertTypeConfirmCloseRoom,
                                                       delegate: self)

        navigator(navigation)
    }
    
    func scaleRoomDidClick() {
        guard !roomState.isPKOngoing() else {
            SVProgressHUD.showError(withStatus: "正在PK中， 无法进行该操作")
            return
        }
        guard let fm = self.floatingManager, let parent = parent else { return }
        fm.show(parent, superView: nil, animated: true)
        navigationController?.popViewController(animated: false)
    }
}

extension VoiceRoomViewController: VoiceRoomAlertProtocol {
    func cancelDidClick(alertType: String) {}
    
    func confirmDidClick(alertType: String) {
        switch alertType {
        case alertTypeConfirmCloseRoom:
            closeRoom()
        case alertTypeVideoAlreadyClose:
            leaveRoom()
        default:
            ()
        }
    }
}

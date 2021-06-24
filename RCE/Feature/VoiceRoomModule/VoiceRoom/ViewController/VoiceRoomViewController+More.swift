//
//  VoiceRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/22.
//

import UIKit

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        if currentUserRole() == .creator {
            moreButton.setImage(R.image.more_icon(), for: .normal)
        } else {
            moreButton.setImage(R.image.white_quite_icon(), for: .normal)
        }
        moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
    }
    
    //MARK: - Button Click Action
    @objc private func handleMoreButton() {
        if currentUserRole() == .creator  {
            navigator(.leaveAlert(self))
        } else {
            leaveRoom()
        }
    }
}

// MARK: - Leave View Click Delegate
extension VoiceRoomViewController: LeaveViewProtocol {
    func quitRoomDidClick() {
        leaveRoom()
    }
    
    func closeRoomDidClick() {
        let navigation: RCNavigation = .voiceRoomAlert(title: "确定结束本次直播么？",
                                                       actions: [.cancel("取消"), .confirm("确认")],
                                                       alertType: alertTypeConfirmCloseRoom,
                                                       delegate: self)
        navigator(navigation)
    }
}

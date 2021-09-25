//
//  VoiceRoomViewController+RoomNotice.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import Foundation
import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupSettingModule() {
        setupModules()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNoticeDidTap))
        roomNoticeView.addGestureRecognizer(tap)
    }
    
    @objc private func handleNoticeDidTap() {
        let notice = kvRoomInfo?.extra ?? "欢迎来到\(voiceRoomInfo.roomName)"
        navigator(.notice(notice: notice, delegate: self))
    }
}

extension VoiceRoomViewController: VoiceRoomNoticeDelegate {
    func noticeDidModfied(notice: String) {
        guard let kvRoom = kvRoomInfo else {
            return
        }
        kvRoom.extra = notice
        RCVoiceRoomEngine.sharedInstance().setRoomInfo(kvRoom) {
            SVProgressHUD.showSuccess(withStatus: "修改公告成功")
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "修改公告失败 \(msg)")
        }
        let textMessage = RCTextMessage()
        textMessage.content = "房间公告已更新"
        RCVoiceRoomEngine.sharedInstance().sendMessage(textMessage) {
            [weak self] in
            self?.messageView.add(textMessage)
        } error: { code, msg in
            
        }
    }
}

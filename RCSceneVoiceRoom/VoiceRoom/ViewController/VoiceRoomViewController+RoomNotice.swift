//
//  VoiceRoomViewController+RoomNotice.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import Foundation

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
    func noticeDidModified(notice: String) {
        LiveNoticeChecker.check(notice) { pass, msg in
            guard let kvRoom = self.kvRoomInfo, pass else {
                return SVProgressHUD.showError(withStatus: msg)
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
                DispatchQueue.main.async {
                    self?.messageView.addMessage(textMessage)
                }
            } error: { code, msg in
                
            }
        }
    }
}

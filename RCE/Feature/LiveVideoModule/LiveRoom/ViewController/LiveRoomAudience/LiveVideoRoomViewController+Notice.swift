//
//  LiveVideoRoomViewController+Notice.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/18.
//

import SVProgressHUD

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func notice_viewDidLoad() {
        m_viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNoticeDidTap))
        roomNoticeView.addGestureRecognizer(tap)
    }
    
    @objc private func handleNoticeDidTap() {
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        navigator(.notice(notice: notice, delegate: self))
    }
}

extension LiveVideoRoomViewController: VoiceRoomNoticeDelegate {
    func noticeDidModified(notice: String) {
    }
}

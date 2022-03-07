//
//  LiveVideoRoomViewController+Notice.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/18.
//

import UIKit
import RCSceneRoomSetting

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func notice_viewDidLoad() {
        m_viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNoticeDidTap))
        roomNoticeView.addGestureRecognizer(tap)
    }
    
    @objc private func handleNoticeDidTap() {
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        videoRouter.trigger(.notice(modify: false, notice: notice, delegate: self))
    }
}

extension LiveVideoRoomViewController: RCSceneRoomSettingProtocol {
    func eventDidTrigger(_ item: Item, extra: String?) {
        
    }
}

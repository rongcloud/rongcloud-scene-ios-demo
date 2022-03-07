//
//  LiveVideoRoomViewController+RoomInfo.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/15.
//

import UIKit

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func roomInfo_viewDidLoad() {
        m_viewDidLoad()
        roomUserView.setRoom(room)
    }
}

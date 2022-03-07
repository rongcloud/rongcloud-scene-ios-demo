//
//  VoiceRoomStatus.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/25.
//

import Foundation

enum VoiceRoomNotification: String {
    case backgroundChanged = "VoiceRoomBackgroundChanged"
    case mangerlistNeedRefresh = "VoiceRoomNeedRefreshmanagers"
    case rejectManagePick = "VoiceRoomRejectManagePick"
    case agreeManagePick = "VoiceRoomAgreeManagePick"
}

extension VoiceRoomNotification {
    func send(content: String) {
        RCVoiceRoomEngine.sharedInstance().notifyVoiceRoom(self.rawValue, content: content)
    }
}

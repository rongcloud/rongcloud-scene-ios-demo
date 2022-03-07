//
//  VoiceRoomNoticeDelegate.swift
//  RCSceneFoundation
//
//  Created by xuefeng on 2022/2/22.
//

import Foundation

public protocol VoiceRoomNoticeDelegate: AnyObject {
    func noticeDidModified(notice: String)
}

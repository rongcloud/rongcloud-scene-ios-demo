//
//  UMengEvent.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/22.
//

import Foundation

enum UMengEvent {
    case audioClick
    case videoClick
    case voiceRoomClick
    case sealTalkDownload
    case sealRTCDownload
    case sealMeetingDownload
    case sealLiveDownload
    case customServiceClick
    case onlineServiceClick
}

extension UMengEvent {
    var name: String {
        switch self {
        case .audioClick:
            return "RTC_AudioClick"
        case .videoClick:
            return "RTC_VideoClick"
        case .voiceRoomClick:
            return "RTC_TalkRoomClick"
        case .sealTalkDownload:
            return "RTC_TalkDownload"
        case .sealRTCDownload:
            return "RTC_RTCDownload"
        case .sealMeetingDownload:
            return "RTC_MeetingDownload"
        case .sealLiveDownload:
            return "RTC_LiveDownload"
        case .customServiceClick:
            return "RTC_ServiceTelClick"
        case .onlineServiceClick:
            return "RTC_OnlineServiceClick"
        }
    }
    
    func trigger() {
        MobClick.event(self.name)
    }
}

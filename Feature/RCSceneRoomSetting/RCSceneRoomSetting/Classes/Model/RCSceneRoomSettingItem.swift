//
//  RoomSettingView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/6.
//

import UIKit

public enum Item {
    case roomLock(Bool)
    case roomSuspend(Bool)
    case roomName(String)
    case roomNotice(String)
    case roomBackground
    
    case music
    case forbidden
    
    case seatMute(Bool)
    case seatLock(Bool)
    case seatFree(Bool)
    case seatCount(Int)
    
    case speaker(enable: Bool)
    
    case cameraSetting
    case cameraSwitch
    
    case beautyRetouch
    case beautySticker
    case beautyMakeup
    case beautyEffect
}

extension Item {
    var title: String {
        switch self {
        case let .roomLock(lock): return lock ? "房间上锁" : "房间解锁"
        case let .seatMute(mute): return mute ? "全麦锁麦" : "解锁全麦"
        case let .seatLock(lock): return lock ? "全麦锁座" : "解锁全座"
        case let .speaker(enable): return enable ? "静音" : "取消静音"
        case let .seatFree(free): return free ? "自由上麦" : "申请上麦"
        case .roomName: return "房间标题"
        case .roomBackground: return "房间背景"
        case let .seatCount(count): return count == 4 ? "设置4个座位" : "设置8个座位"
        case .music: return "音乐"
        case .cameraSetting: return "视频设置"
        case .forbidden: return "屏蔽词"
        case let .roomSuspend(suspend): return suspend ? "暂停直播" : "继续直播"
        case .roomNotice: return "房间公告"
        case .cameraSwitch: return "翻转"
        case .beautyRetouch: return "美颜"
        case .beautySticker: return "贴纸"
        case .beautyMakeup: return "美妆"
        case .beautyEffect: return "特效"
        }
    }
    
    var image: UIImage? {
        switch self {
        case let .roomLock(lock):
            return lock ? "room_lock_on".image : "room_lock_off".image
        case let .seatMute(mute):
            return mute ? "seat_mute_on".image : "seat_mute_off".image
        case let .seatLock(lock):
            return lock ? "seat_lock_on".image : "seat_lock_off".image
        case let .speaker(enable):
            return enable ? "speaker_mute_on".image : "speaker_mute_off".image
        case let .seatFree(free):
            return free ? "seat_mode_request".image : "seat_mode_free".image
        case .roomName: return "room_title".image
        case .roomBackground: return "room_background".image
        case let .seatCount(count):
            return count == 4 ? "seat_count_4".image : "seat_count_8".image
        case .music: return "room_music".image
        case .cameraSetting: return "camera_settings".image
        case .forbidden: return "room_forbidden".image
        case .roomSuspend:
            return "room_suspend".image
        case .roomNotice: return "room_notice".image
        case .cameraSwitch: return "camera_switch".image
        case .beautyRetouch: return "beauty_retouch".image
        case .beautySticker: return "beauty_sticker".image
        case .beautyMakeup: return "beauty_makeup".image
        case .beautyEffect: return "beauty_effect".image
        }
    }
}

//
//  RCRadioRoomKVState.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/16.
//

import UIKit
import RCSceneService

fileprivate let kRCRadioRoomKVRoomNameKey   = "RCRadioRoomKVRoomNameKey"
fileprivate let kRCRadioRoomKVSeatingKey    = "RCRadioRoomKVSeatingKey"
fileprivate let kRCRadioRoomKVSilentKey     = "RCRadioRoomKVSilentKey"
fileprivate let kRCRadioRoomKVSpeakingKey   = "RCRadioRoomKVSpeakingKey"
fileprivate let kRCRadioRoomKVNoticeKey     = "RCRadioRoomKVNoticeKey"
fileprivate let kRCRadioRoomKVBGNameKey     = "RCRadioRoomKVBGNameKey"
fileprivate let kRCRadioRoomKVSuspendKey    = "RCRadioRoomKVSuspendKey"

protocol RCRadioRoomKVDelegate: AnyObject {
    func roomKVDidChanged(roomName: String)
    func roomKVDidChanged(speaking: Bool)
    func roomKVDidChanged(seating: Bool)
    func roomKVDidChanged(mute: Bool)
    func roomKVDidChanged(notice: String)
    func roomKVDidChanged(background: String)
    func roomKVDidChanged(suspend: Bool)
    func roomKVDidSync()
}

extension RCRadioRoomKVDelegate {
    func roomKVDidChanged(roomName: String) {}
    func roomKVDidChanged(speaking: Bool) {}
    func roomKVDidChanged(seating: Bool) {}
    func roomKVDidChanged(mute: Bool) {}
    func roomKVDidChanged(notice: String) {}
    func roomKVDidChanged(background: String) {}
    func roomKVDidChanged(suspend: Bool) {}
    func roomKVDidSync() {}
}

class RCRadioRoomKVState: NSObject {
    private let room: VoiceRoom
    private(set) var roomName: String
    private(set) var seating: Bool = false
    private(set) var mute: Bool = false
    private(set) var speaking: Bool = false
    private(set) var notice: String = ""
    private(set) var roomBGName: String = ""
    private(set) var suspend: Bool = false
    
    private var isSynced: Bool = false
    
    weak var delegate: RCRadioRoomKVDelegate?
    
    init(_ room: VoiceRoom) {
        self.room = room
        self.roomName = room.roomName
        super.init()
    }
    
    private func syncIfNeeded() {
        if isSynced { return }
        isSynced.toggle()
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidSync()
        }
    }
}

extension RCRadioRoomKVState {
    func initKV() {
        setKV(kRCRadioRoomKVRoomNameKey, value: room.roomName)
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(roomName: room.roomName)
        }
    }
    
    func enterSeat() {
        seating = true
        setKV(kRCRadioRoomKVSeatingKey, value: "1")
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(seating: true)
        }
    }
    
    func leaveSeat() {
        seating = false
        setKV(kRCRadioRoomKVSeatingKey, value: "0")
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(seating: false)
        }
    }
    
    func speak(_ level: Int) {
        let isSpeaking = level > 0
        if mute { return }
        if isSpeaking == speaking && speaking == false { return }
        speaking = isSpeaking
        setKV(kRCRadioRoomKVSpeakingKey, value: isSpeaking ? "1" : "0")
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(speaking: speaking)
        }
    }
    
    func muteToggle() {
        mute = !mute
        setKV(kRCRadioRoomKVSilentKey, value: mute ? "1" : "0")
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(mute: mute)
        }
    }
    
    func update(notice: String) {
        self.notice = notice
        setKV(kRCRadioRoomKVNoticeKey, value: notice)
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(notice: notice)
        }
    }
    
    func update(roomName: String) {
        self.roomName = roomName
        setKV(kRCRadioRoomKVRoomNameKey, value: roomName)
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(roomName: roomName)
        }
    }
    
    func update(roomBGName: String) {
        self.roomBGName = roomBGName
        setKV(kRCRadioRoomKVBGNameKey, value: roomBGName)
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(background: roomBGName)
        }
    }
    
    func update(suspend: Bool) {
        self.suspend = suspend
        setKV(kRCRadioRoomKVSuspendKey, value: suspend ? "1" : "0")
        DispatchQueue.main.async { [unowned self] in
            delegate?.roomKVDidChanged(suspend: suspend)
        }
    }
}

extension RCRadioRoomKVState {
    private func setKV(_ key: String, value: String, autoDelete: Bool = false) {
        RCChatRoomClient.shared()
            .forceSetChatRoomEntry(room.roomId,
                                   key: key,
                                   value: value,
                                   sendNotification: false,
                                   autoDelete: autoDelete,
                                   notificationExtra: "",
                                   success: {},
                                   error: { _ in })
    }
    
    private func removeKV(_ key: String) {
        RCChatRoomClient.shared()
            .forceRemoveChatRoomEntry(room.roomId,
                                      key: key,
                                      sendNotification: false,
                                      notificationExtra: "",
                                      success: {},
                                      error: { _ in })
    }
}

extension RCRadioRoomKVState: RCChatRoomKVStatusChangeDelegate {
    func chatRoomKVDidSync(_ roomId: String!) {
        debugPrint("chatRoomKVDidSync: \(roomId!)")
    }
    
    func chatRoomKVDidUpdate(_ roomId: String!, entry: [String : String]!) {
        DispatchQueue.main.async { [unowned self] in
            if let roomName = entry[kRCRadioRoomKVRoomNameKey] {
                self.roomName = roomName
                delegate?.roomKVDidChanged(roomName: roomName)
            }
            if let seating = entry[kRCRadioRoomKVSeatingKey] {
                self.seating = seating == "1"
                delegate?.roomKVDidChanged(seating: self.seating)
            }
            if let mute = entry[kRCRadioRoomKVSilentKey] {
                self.mute = mute == "1"
                delegate?.roomKVDidChanged(mute: self.mute)
            }
            if let speaking = entry[kRCRadioRoomKVSpeakingKey] {
                self.speaking = speaking == "1"
                delegate?.roomKVDidChanged(speaking: self.speaking)
            }
            if let notice = entry[kRCRadioRoomKVNoticeKey] {
                self.notice = notice
                delegate?.roomKVDidChanged(notice: self.notice)
            }
            if let roomBGName = entry[kRCRadioRoomKVBGNameKey] {
                self.roomBGName = roomBGName
                delegate?.roomKVDidChanged(background: self.roomBGName)
            }
            if let suspend = entry[kRCRadioRoomKVSuspendKey] {
                self.suspend = suspend == "1"
                delegate?.roomKVDidChanged(suspend: self.suspend)
            }
            
            syncIfNeeded()
        }
    }
    
    func chatRoomKVDidRemove(_ roomId: String!, entry: [String : String]!) {
        debugPrint("rm \(roomId!) entry: \(entry!)")
    }
}

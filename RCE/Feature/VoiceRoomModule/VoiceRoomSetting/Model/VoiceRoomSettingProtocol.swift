//
//  VoiceRoomSettingProtocol.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import UIKit

protocol VoiceRoomSettingProtocol: AnyObject {
    func lockRoomDidClick(isLock: Bool)
    func freeMicDidClick(isFree: Bool)
    func lockAllSeatDidClick(isLock: Bool)
    func silenceSelfDidClick(isSilence: Bool)
    func muteAllSeatDidClick(isMute: Bool)
    func lessSeatDidClick(isLess: Bool)
    func modifyRoomTitleDidClick()
    func modifyRoomBackgroundDidClick()
    func musicDidClick()
    func forbiddenDidClick()
    func suspendDidClick()
    func noticeDidClick()
    func switchCameraDidClick()
    func retouchDidClick()
    func stickerDidClick()
    func makeupDidClick()
    func effectDidClick()
}

extension VoiceRoomSettingProtocol {
    func lockRoomDidClick(isLock: Bool) {}
    func freeMicDidClick(isFree: Bool) {}
    func lockAllSeatDidClick(isLock: Bool) {}
    func silenceSelfDidClick(isSilence: Bool) {}
    func muteAllSeatDidClick(isMute: Bool) {}
    func lessSeatDidClick(isLess: Bool) {}
    func modifyRoomTitleDidClick() {}
    func modifyRoomBackgroundDidClick() {}
    func musicDidClick() {}
    func forbiddenDidClick() {}
    func suspendDidClick() {}
    func noticeDidClick() {}
    func switchCameraDidClick() {}
    func retouchDidClick() {}
    func stickerDidClick() {}
    func makeupDidClick() {}
    func effectDidClick() {}
}

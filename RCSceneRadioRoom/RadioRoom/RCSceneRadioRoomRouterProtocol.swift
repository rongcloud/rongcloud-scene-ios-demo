//
//  RCSceneRadioRoomRouterProtocol.swift
//  RCSceneRadioRoom
//
//  Created by xuefeng on 2022/2/23.
//

import Foundation
import RCSceneFoundation
import RCSceneGift

protocol RCSceneRadioRoomRouterProtocol {
    func inputPassword(type: PasswordViewType, delegate: InputPasswordProtocol?)
    func userList(room: VoiceRoom, delegate: UserOperationProtocol)
    func notice(modify: Bool, notice: String, delegate: VoiceRoomNoticeDelegate)
    func manageUser(dependency: Any?, delegate: UserOperationProtocol?)
    func gift(dependency: Any?, delegate: VoiceRoomGiftViewControllerDelegate)
    func messageList()
    func privateChat(userId: String)
    func masterSeatOperation(userid: String, isMute: Bool, delegate: VoiceRoomMasterSeatOperationProtocol)
    func forbiddenList(roomId: String)
    func voiceRoomAlert(title: String, actions: [VoiceRoomAlertAction], alertType: String, delegate: VoiceRoomAlertProtocol?)
}

extension RCSceneRadioRoomRouterProtocol {
    func inputPassword(type: PasswordViewType, delegate: InputPasswordProtocol?) {}
    func userList(dependency: Any?, delegate: UserOperationProtocol) {}
    func notice(modify: Bool, notice: String, delegate: VoiceRoomNoticeDelegate) {}
    func manageUser(dependency: Any?, delegate: UserOperationProtocol?) {}
    func gift(dependency: Any?, delegate: VoiceRoomGiftViewControllerDelegate) {}
    func messageList() {}
    func privateChat(userId: String) {}
    func masterSeatOperation(userid: String, isMute: Bool, delegate: VoiceRoomMasterSeatOperationProtocol) {}
    func forbiddenList(roomId: String) {}
    func voiceRoomAlert(title: String, actions: [VoiceRoomAlertAction], alertType: String, delegate: VoiceRoomAlertProtocol?) {}
}

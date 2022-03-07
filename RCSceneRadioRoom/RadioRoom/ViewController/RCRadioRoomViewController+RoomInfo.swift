//
//  RCRadioRoomViewController+RoomInfo.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import RCSceneMessage
import RCSceneService
import RCSceneFoundation

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func roomInfo_viewDidLoad() {
        m_viewDidLoad()
        roomInfoView.delegate = self
        fetchRoomStatus()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func roomInfo_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        if message.content.isKind(of: RCChatroomEnter.self) || message.content.isKind(of: RCChatroomLeave.self) {
            roomInfoView.updateRoomUserNumber()
        }
    }
    
    func fetchRoomStatus() {
        radioRoomService.roomInfo(roomId: roomInfo.roomId) { [weak self] result in
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(model):
                if model.data?.stop == true {
                    self?.roomDidSuspend()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateRoomInfo(info: RCVoiceRoomInfo) {
        roomInfo.roomName = info.roomName
        roomInfoView.updateRoom(info: roomInfo)
    }
}

extension RCRadioRoomViewController: RoomInfoViewClickProtocol {
    func roomInfoDidClick() {
        radioRouter.trigger(.userList(room: roomInfo, delegate: self))
    }
    
    func didFollowRoomUser(_ follow: Bool) {
        UserInfoDownloaded.shared.refreshUserInfo(userId: roomInfo.userId) { followUser in
            guard follow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                ChatroomSendMessage(message, messageView: self?.messageView)
            }
        }
    }
}


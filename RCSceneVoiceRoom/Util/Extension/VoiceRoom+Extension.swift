//
//  VoiceRoom+Extension.swift
//  RCSceneVoiceRoom
//
//  Created by shaoshuai on 2022/2/24.
//

import RCSceneService

extension VoiceRoomUser {
    var rcUser: RCUserInfo {
        return RCUserInfo(userId: userId, name: userName, portrait: portraitUrl)
    }
}

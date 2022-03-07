//
//  OnlineList.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/9.
//

import Foundation
import RCSceneService

struct OnlineRoomList: Codable {
    let code: Int
    let data: [VoiceRoom]
}

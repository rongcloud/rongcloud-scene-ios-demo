//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation
import RCSceneRoom

extension HomeItem {
    var umengEvent: UMengEvent {
        switch self {
        case .audioRoom: return .VoiceRoom
        case .radioRoom: return .RadioRoom
        case .audioCall: return .AudioCall
        case .videoCall: return .VideoCall
        case .liveVideo: return .LiveVideo
        }
    }
}

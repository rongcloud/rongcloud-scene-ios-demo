//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import RCSceneModular

extension HomeItem {
    var image: UIImage? {
        switch self {
        case .audioRoom:
            return R.image.voice_room_background()
        case .videoCall:
            return R.image.video_live_room_background()
        case .audioCall:
            return R.image.voice_call_room_background()
        case .radioRoom:
            return R.image.home_radio_room()
        case .liveVideo:
            return R.image.live_video_home_bg()
        }
    }
}

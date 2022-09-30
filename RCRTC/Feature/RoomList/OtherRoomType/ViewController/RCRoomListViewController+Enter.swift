//
//  RCRoomListViewController+Enter.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import Foundation
import RCSceneVideoRoom

extension RCRoomListViewController {
    
    func enter(_ room: RCSceneRoom) {
        enter([room], index: 0)
    }
    
    func enter(_ rooms: [RCSceneRoom], index: Int) {
        
        setLiveCDN(rooms, index: index)
        
        /// 隐藏浮窗
        RCRoomFloatingManager.shared.hide()
        let controller = RCRoomContainerViewController(rooms, index: index, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setLiveCDN(_ rooms: [RCSceneRoom], index: Int) {
        guard let scene = RCRoomType(rawValue: SceneRoomManager.scene) else {
            return
        }
        switch scene {
        case .liveVideo:
            let room = rooms[index]
            if room.userId != Environment.currentUserId {
                /// 观众使用选择的CDN
                kCDNType = self.audienceCDNType
            } else {
                /// 主播默认推流到三方 CDN
                kCDNType = .CDN(RCSLiveThirdCDN.shared)
            }
            default: ()
        }
    }
    
    func create(_ room: RCSceneRoom) {
        
    }
}

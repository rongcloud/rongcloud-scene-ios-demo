//
//  RCRoomListViewController+Enter.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import Foundation
import RCSceneService

extension RCRoomListViewController {
    func enter(_ room: VoiceRoom) {
        enter([room], index: 0)
    }
    
    func enter(_ rooms: [VoiceRoom], index: Int) {
        /// 隐藏浮窗
        RCRoomFloatingManager.shared.hide()
        let controller = RCRoomContainerViewController(rooms, index: index, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func create(_ room: VoiceRoom) {
        
    }
}

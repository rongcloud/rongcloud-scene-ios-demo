//
//  RCRoomListViewController+Enter.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import Foundation


extension RCRoomListViewController {
    func enter(_ room: RCSceneRoom) {
        enter([room], index: 0)
    }
    
    func enter(_ rooms: [RCSceneRoom], index: Int) {
        /// 隐藏浮窗
        RCRoomFloatingManager.shared.hide()
        let controller = RCRoomContainerViewController(rooms, index: index, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func create(_ room: RCSceneRoom) {
        
    }
}

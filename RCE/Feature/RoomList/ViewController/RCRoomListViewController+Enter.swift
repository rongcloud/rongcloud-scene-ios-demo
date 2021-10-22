//
//  RCRoomListViewController+Enter.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import Foundation

extension RCRoomListViewController {
    func enter(_ room: VoiceRoom) {
        enter([room], index: 0)
    }
    
    func enter(_ rooms: [VoiceRoom], index: Int) {
        let controller = RCRoomContainerViewController(rooms, index: index, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func create(_ room: VoiceRoom) {
        
    }
}

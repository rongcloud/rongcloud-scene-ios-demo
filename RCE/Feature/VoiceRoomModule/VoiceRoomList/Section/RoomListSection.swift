//
//  RoomListSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/28.
//

import Foundation
import RxDataSources

struct VoiceRoomSection {
    var items: [VoiceRoom]
}

extension VoiceRoomSection: Equatable {
    
}

extension VoiceRoomSection: SectionModelType {
    typealias Item = VoiceRoom
    
    init(original: VoiceRoomSection, items: [VoiceRoom]) {
        self = original
        self.items = items
    }
}

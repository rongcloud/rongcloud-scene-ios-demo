//
//  MusicSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import Foundation
import RxDataSources

struct VoiceRoomMusicItem {
    let music: VoiceRoomMusic
    var state: MusicListState
}

struct VoiceRoomMusicSection {
    var items: [VoiceRoomMusicItem]
}

extension VoiceRoomMusicSection: SectionModelType {
    typealias Item = VoiceRoomMusicItem
    
    init(original: VoiceRoomMusicSection, items: [VoiceRoomMusicItem]) {
        self = original
        self.items = items
    }
}

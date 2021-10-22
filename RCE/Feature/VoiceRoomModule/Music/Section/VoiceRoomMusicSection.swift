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

struct MusicChannelSection: Codable, Equatable {
    var items: [MusicChannel]
}

extension MusicChannelSection: SectionModelType {
    typealias Item = MusicChannel
    init(original: MusicChannelSection, items: [MusicChannel]) {
        self = original
        self.items = items
    }
}

struct MusicRecordItem {
    let record: MusicRecord
    var state: MusicListState
}

struct MusicRecordSection {
    var items: [MusicRecordItem]
}

extension MusicRecordSection {
    typealias Item = MusicRecordItem
    init(original: MusicRecordSection, items: [MusicRecordItem]) {
        self = original
        self.items = items
    }
}

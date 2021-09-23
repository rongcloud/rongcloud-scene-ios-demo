//
//  VoiceRoomSoundEffectSection.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import Foundation
import RxDataSources

enum AudioEffect: CaseIterable, Equatable {
    case intro
    case clap
    case cheering
    
    var id: Int {
        switch self {
        case .intro:
            return 1
        case .clap:
            return 2
        case .cheering:
            return 3
        }
    }
    
    var name: String {
        switch self {
        case .intro:
            return "进场"
        case .clap:
            return "鼓掌"
        case .cheering:
            return "欢呼"
        }
    }
    
    var filePath: String? {
        switch self {
        case .intro:
            return Bundle.main.path(forResource: "intro_effect", ofType: "mp3")
        case .clap:
            return Bundle.main.path(forResource: "clap_effect", ofType: "mp3")
        case .cheering:
            return Bundle.main.path(forResource: "cheering_effect", ofType: "mp3")
        }
    }
}

struct VoiceRoomSoundEffectSection {
    var items: [AudioEffect]
}

extension VoiceRoomSoundEffectSection: SectionModelType {
    typealias Item = AudioEffect
    
    init(original: VoiceRoomSoundEffectSection, items: [AudioEffect]) {
        self = original
        self.items = items
    }
}

extension VoiceRoomSoundEffectSection: Equatable {
    
}

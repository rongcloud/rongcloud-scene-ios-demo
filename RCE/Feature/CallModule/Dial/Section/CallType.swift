//
//  CallType.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import Foundation

enum CallType {
    case audio
    case video
    
    var mediaType: RCCallMediaType {
        switch self {
        case .audio: return .audio
        case .video: return .video
        }
    }
}

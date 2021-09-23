//
//  VoiceRoomForbiddenWord.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/3.
//

import Foundation

struct VoiceRoomForbiddenResponse: Codable {
    let code: Int
    let data: [VoiceRoomForbiddenWord]?
}

struct VoiceRoomForbiddenWord: Codable, Identifiable {
    let id: Int
    let name: String
    let createDt: TimeInterval
}

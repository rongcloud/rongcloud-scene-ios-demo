//
//  VoiceRoomForbiddenWord.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/3.
//

import Foundation

public struct VoiceRoomForbiddenResponse: Codable {
    public let code: Int
    public let data: [VoiceRoomForbiddenWord]?
}

public struct VoiceRoomForbiddenWord: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let createDt: TimeInterval
    public init(id: Int, name: String, createDt: TimeInterval) {
        self.id = id
        self.name = name
        self.createDt = createDt
    }
}

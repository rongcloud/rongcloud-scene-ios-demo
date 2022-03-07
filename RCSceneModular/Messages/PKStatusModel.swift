//
//  PKStatusModel.swift
//  RCE
//
//  Created by zangqilong on 2021/10/28.
//

import Foundation

public struct PKStatusModel: Codable {
    public let statusMsg: Int
    public var timeDiff: Int
    public var seconds: Int {
        return timeDiff/1000
    }
    public let roomScores: [PKStatusRoomScore]
}

public struct PKGiftModel: Codable {
    public let roomScores: [PKStatusRoomScore]
    
    public init(roomScores: [PKStatusRoomScore]) {
        self.roomScores = roomScores
    }
}

public struct PKStatusRoomScore: Codable {
    public let leader: Bool
    public let userId: String
    public let roomId: String
    public let score: Int
    public let userInfoList: [PKSendGiftUser]
}

public struct PKSendGiftUser: Codable {
    public let userId: String
    public let userName: String
    public let portrait: String
}

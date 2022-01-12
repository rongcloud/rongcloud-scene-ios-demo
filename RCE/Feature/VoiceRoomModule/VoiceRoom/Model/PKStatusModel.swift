//
//  PKStatusModel.swift
//  RCE
//
//  Created by zangqilong on 2021/10/28.
//

import Foundation

struct PKStatusModel: Codable {
    let statusMsg: Int
    var timeDiff: Int
    var seconds: Int {
        return timeDiff/1000
    }
    let roomScores: [PKStatusRoomScore]
}

struct PKGiftModel: Codable {
    let roomScores: [PKStatusRoomScore]
}

struct PKStatusRoomScore: Codable {
    let leader: Bool
    let userId: String
    let roomId: String
    let score: Int
    let userInfoList: [PKSendGiftUser]
}

struct PKSendGiftUser: Codable {
    let userId: String
    let userName: String
    let portrait: String
}

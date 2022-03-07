//
//  RCPKStatusMessage.swift
//  RCE
//
//  Created by zangqilong on 2021/10/28.
//

import UIKit

public struct PKStatusContent: Codable {
    public let stopPkRoomId: String?
    public let statusMsg: Int
    public let timeDiff: Int
    public var seconds: Int {
        return timeDiff/1000
    }
    public let roomScores: [PKRoomScore]
}

public struct PKRoomScore: Codable {
    public let userId: String?
    public let roomId: String
    public let score: Int
}

public class RCPKStatusMessage: RCMessageContent {
    public var content: PKStatusContent?
    
    public override func encode() -> Data! {
        guard let content = content else { return Data() }
        do {
            let data = try JSONEncoder().encode(content)
            return data
        } catch {
            fatalError("RCPKStatus encode failed")
        }
    }
    
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(PKStatusContent.self, from: data)
        } catch {
            fatalError("RCPKStatus decode failed: \(error.localizedDescription)")
        }
    }
    
    public override class func getObjectName() -> String! { "RCMic:chrmPkStatusMsg" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
    
    public override func getSearchableWords() -> [String]! {
        return []
    }
}

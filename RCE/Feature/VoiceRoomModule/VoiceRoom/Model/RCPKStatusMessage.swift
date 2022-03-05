//
//  RCPKStatusMessage.swift
//  RCE
//
//  Created by zangqilong on 2021/10/28.
//

import UIKit

struct PKStatusContent: Codable {
  let stopPkRoomId: String?
  let statusMsg: Int
  let timeDiff: Int
    var seconds: Int {
        return timeDiff/1000
    }
  let roomScores: [PKRoomScore]
}

struct PKRoomScore: Codable {
  let userId: String?
  let roomId: String
  let score: Int
}

class RCPKStatusMessage: RCMessageContent {
  var content: PKStatusContent?
  
  override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCPKStatus encode failed")
      }
  }
  
  override func decode(with data: Data!) {
      do {
          content = try JSONDecoder().decode(PKStatusContent.self, from: data)
      } catch {
          fatalError("RCPKStatus decode failed: \(error.localizedDescription)")
      }
  }
  
  override class func getObjectName() -> String! { "RCMic:chrmPkStatusMsg" }
  override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
  override func getSearchableWords() -> [String]! {
      return []
  }
}

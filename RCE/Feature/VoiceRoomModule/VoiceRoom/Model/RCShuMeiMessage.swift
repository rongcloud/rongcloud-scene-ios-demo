//
//  RCShuMeiMessage.swift
//  RCE
//
//  Created by xuefeng on 2022/1/24.
//

import UIKit

struct RCShuMeiContent: Codable {
  let userId: String?
  let message: String?
  let status: Int
}

class RCShuMeiMessage: RCMessageContent {
    
  var content: RCShuMeiContent?
  
  override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCShuMeiMessage encode failed")
      }
  }
  
    override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCShuMeiContent.self, from: data)
        } catch {
            fatalError("RCPKStatus decode failed: \(error.localizedDescription)")
        }
    }
  
  override class func getObjectName() -> String! { "RCMic:shumeiAuditFreezeMsg" }
  override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
  override func getSearchableWords() -> [String]! {
      return []
  }
}

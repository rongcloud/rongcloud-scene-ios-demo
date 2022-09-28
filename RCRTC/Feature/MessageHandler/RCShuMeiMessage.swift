//
//  RCShuMeiMessage.swift
//  RCE
//
//  Created by xuefeng on 2022/1/24.
//

import UIKit

public struct RCShuMeiContent: Codable {
    public let userId: String?
    public let message: String?
    public let status: Int
}

public class RCShuMeiMessage: RCMessageContent {
    
    public var content: RCShuMeiContent?
  
    public override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCShuMeiMessage encode failed")
      }
  }
  
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCShuMeiContent.self, from: data)
        } catch {
            fatalError("RCPKStatus decode failed: \(error.localizedDescription)")
        }
    }
  
    public override class func getObjectName() -> String { "RCMic:shumeiAuditFreezeMsg" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
    public override func getSearchableWords() -> [String]! {
      return []
  }
}

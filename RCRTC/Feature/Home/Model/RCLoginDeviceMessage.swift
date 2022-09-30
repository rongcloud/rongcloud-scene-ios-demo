//
//  RCLoginDeviceMessage.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/1/27.
//

import Foundation
 
struct RCLoginDeviceContent: Codable {
  let userId: String?
  let platform: String?
}

class RCLoginDeviceMessage: RCMessageContent {
    
  var content: RCLoginDeviceContent?
  
  override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCLoginDeviceMessage encode failed")
      }
  }
  
    override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCLoginDeviceContent.self, from: data)
        } catch {
            fatalError("RCLoginDeviceMessage decode failed: \(error.localizedDescription)")
        }
    }
  
  override class func getObjectName() -> String { "RCMic:loginDeviceMsg" }
  override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
  override func getSearchableWords() -> [String]! {
      return []
  }
}

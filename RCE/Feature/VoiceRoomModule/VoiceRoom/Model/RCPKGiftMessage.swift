//
//  RCPKGiftMessage.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/19.
//

import UIKit

class RCPKGiftMessage: RCMessageContent {
    
    var content: PKGiftModel?
    
    override func encode() -> Data! {
        guard let content = content else { return Data() }
        do {
            let data = try JSONEncoder().encode(content)
            return data
        } catch {
            fatalError("RCPKGift encode failed")
        }
    }
    
    override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(PKGiftModel.self, from: data)
        } catch {
            fatalError("RCPKGift decode failed: \(error.localizedDescription)")
        }
    }
    
    override class func getObjectName() -> String! { "RCMic:chrmPkNewMsg" }
    override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
    
    override func getSearchableWords() -> [String]! {
        return []
    }
}

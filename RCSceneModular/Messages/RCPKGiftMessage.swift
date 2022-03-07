//
//  RCPKGiftMessage.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/19.
//

import UIKit

public class RCPKGiftMessage: RCMessageContent {
    
    public var content: PKGiftModel?
    
    public override func encode() -> Data! {
        guard let content = content else { return Data() }
        do {
            let data = try JSONEncoder().encode(content)
            return data
        } catch {
            fatalError("RCPKGift encode failed")
        }
    }
    
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(PKGiftModel.self, from: data)
        } catch {
            fatalError("RCPKGift decode failed: \(error.localizedDescription)")
        }
    }
    
    public override class func getObjectName() -> String! { "RCMic:chrmPkNewMsg" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
    
    public override func getSearchableWords() -> [String]! {
        return []
    }
}

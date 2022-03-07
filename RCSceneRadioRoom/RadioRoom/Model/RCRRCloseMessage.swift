//
//  RCRRCloseMessage.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/16.
//

import UIKit

class RCRRCloseMessage: RCMessageContent {
    override func encode() -> Data! { Data() }
    override func decode(with data: Data!) {}
    override class func getObjectName() -> String! { "RC:RCRRCloseMsg" }
    override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
}

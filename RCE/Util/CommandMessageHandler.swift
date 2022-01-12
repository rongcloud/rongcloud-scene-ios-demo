//
//  CommandMessageHandler.swift
//  RCE
//
//  Created by xuefeng on 2021/12/27.
//

import Foundation

class CommandMessageHandler {
    static func handleMessage(_ message: RCMessage, _ avg: AnyObject?...) {
        guard let commandMessage = message.content as? RCCommandMessage else {
            return
        }
        switch commandMessage.name {
        case "RCVoiceSyncMusicInfoKey":
            if let bubbleView = avg.first as? RCMusicInfoBubbleView {
                SyncMusicInfoMessageHandler.handleMessage(commandMessage, bubbleView)
            }
        default: break
        }
    }
}

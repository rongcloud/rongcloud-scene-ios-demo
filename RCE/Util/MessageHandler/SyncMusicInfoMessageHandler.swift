//
//  SyncMusicInfoMessageHandler.swift
//  RCE
//
//  Created by xuefeng on 2021/12/27.
//

import Foundation

class SyncMusicInfoMessageHandler: RoomMessageHandlerProtocol {
    static func handleMessage(message: RCMessage, object: AnyObject?) {
        guard let syncMusicInfoMessage = message.content as? RCCommandMessage,
                syncMusicInfoMessage.name == SyncMusicInfoMessageHandlerName,
                let bubbleView = object as? RCMusicInfoBubbleView,
                let data = syncMusicInfoMessage.data else {
            return
        }
        
        if (data.intValue == 0) {
            DispatchQueue.main.async {
                bubbleView.info = nil
            }
            return
        }
        
        DataSourceImpl.instance.fetchCollectMusics { infos in
            guard let infos = infos else {
                DispatchQueue.main.async {
                    bubbleView.info = nil
                }
                return
            }
            var result: MusicInfo?
            for info in infos {
                guard let info = info as? MusicInfo else {
                    continue
                }
                if (info.id == data.intValue) {
                    result = info
                    break
                }
            }
            DispatchQueue.main.async {
                bubbleView.info = result
            }
        }
    }
}

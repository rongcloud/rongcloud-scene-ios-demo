//
//  SystemMessageHandler.swift
//  RCE
//
//  Created by xuefeng on 2022/1/24.
//

import Foundation
import SVProgressHUD

import RCSceneCallKit

class ShuMeiMessageHandler {
    static func handleMessage(message: RCMessage?, object: AnyObject?) {
        guard
            let tmp = message?.content as? RCShuMeiMessage,
            let content = tmp.content
        else {
            return debugPrint("System Message Data invalid <ShuMei>")
        }
        
        if (content.status == 2) {
            let tmpSession: RCCallSession? = RCCall.shared().currentCallSession
            if let session = tmpSession, session.callStatus == .active {
                RCCall.shared().currentCallSession.hangup()
            }
             RCCoreClient.shared().disconnect(true)
            
            UserDefaults.standard.clearLoginStatus()

            DispatchQueue.main.async {
                NotificationNameShuMeiKickOut.post()
            }
        }
        
        if (content.message != nil) {
            let time = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                SVProgressHUD.setMinimumDismissTimeInterval(5)
                SVProgressHUD.setMaximumDismissTimeInterval(5)
                SVProgressHUD.showError(withStatus: content.message)
            })
            let reset = DispatchTime.now() + 6.5
            DispatchQueue.main.asyncAfter(deadline: reset, execute: {
                SVProgressHUD.setMinimumDismissTimeInterval(2)
                SVProgressHUD.setMaximumDismissTimeInterval(2)
            })
        }
    }
}
 

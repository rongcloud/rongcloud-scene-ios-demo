//
//  HomeViewController+IM.swift
//  RCE
//
//  Created by shaoshuai on 2022/5/11.
//

import RongIMLib

extension HomeViewController: RCIMConnectionStatusDelegate {
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        print("status: \(status.rawValue)")
        switch status {
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            SVProgressHUD.showInfo(withStatus: "您已下线，请重新登录")
            UserDefaults.standard.clearLoginStatus()
            onLogout()
        default: ()
        }
    }
}


extension HomeViewController: RCIMClientReceiveMessageDelegate {
    func onReceived(_ message: RCMessage, left: Int32, object: Any) {
        if let loginDeviceMessage = message.content as? RCLoginDeviceMessage,
           let content = loginDeviceMessage.content,
           content.platform != "mobile" {
            SVProgressHUD.showInfo(withStatus: "您已下线，请重新登录")
            UserDefaults.standard.clearLoginStatus()
            RCCoreClient.shared().disconnect(true)
            DispatchQueue.main.async {
                self.onLogout()
            }
        } else if let _ = message.content as? RCShuMeiMessage {
            ShuMeiMessageHandler.handleMessage(message: message, object: nil)
        }
    }
}

extension HomeViewController: RCMessageBlockDelegate {
    func messageDidBlock(_ info: RCBlockedMessageInfo) {
        let string = "发送的消息(消息类型:\(info.type) 会话id:\(info.targetId) 消息id:\(info.blockedMsgUId) 拦截原因:\(info.blockType) 附加信息:\(info.extra))遇到敏感词被拦截"
        let controller = UIAlertController(title: "提示", message: string, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
    }
}
